import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shop_app/core/di/injection.dart';
import 'package:shop_app/core/utils/responsive_helper.dart';
import 'package:shop_app/domain/usecases/get_products_usecase.dart';
import '../api/seller_api.dart';
import '../api/product_api.dart';
import '../services/cart_service.dart';
import '../api/cart_api.dart';
import 'cart_screen.dart';
import '../utils/unit_utils.dart';
import '../cache/product_cache.dart';
import '../services/auth_service.dart';

class SellerProductsScreen extends StatefulWidget {
  final SellerResponse seller;
  const SellerProductsScreen({super.key, required this.seller});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  bool _loading = true;
  String _error = '';
  final List<ProductResponse> _all = [];
  List<ProductResponse> _filtered = [];
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  late final GetProductsUseCase _getProductsUseCase;
  late CartResponse _currentCart;
  final Map<String, bool> _loadingProducts = {};
  late StreamSubscription<CartResponse> _cartSubscription;

  @override
  void initState() {
    super.initState();
    // Получаем GetProductsUseCase через DI
    _getProductsUseCase = getIt<GetProductsUseCase>();
    _currentCart = CartResponse.empty(sellerId: widget.seller.id);
    _loadData();
    _setupCartSubscription();

    _searchCtrl.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 250), () {
        final q = _searchCtrl.text.trim().toLowerCase();
        setState(() {
          _filtered = q.isEmpty
              ? List.from(_all)
              : _all
              .where((p) =>
          p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q))
              .toList();
        });
      });
    });
  }

  // === ОСНОВНАЯ ЗАГРУЗКА С КЭШЕМ ===
  Future<void> _loadData() async {
    final userId = AuthService.userId;
    if (userId == null) {
      setState(() {
        _error = 'Не авторизован';
        _loading = false;
      });
      return;
    }

    final cached = ProductCache.get(userId, widget.seller.id);

    if (cached != null) {
      setState(() {
        _all
          ..clear()
          ..addAll(cached);
        _filtered = List.from(_all);
        _loading = false;
      });
      unawaited(_refreshProductsInBackground(userId));
    } else {
      setState(() => _loading = true);
      await Future.wait([
        _refreshProductsInBackground(userId),
        _loadSellerCart(),
      ]);
    }
  }

  // === ФОНОВАЯ ЗАГРУЗКА ТОВАРОВ ===
  Future<void> _refreshProductsInBackground(String userId) async {
    try {
      // Используем GetProductsUseCase вместо прямого API вызова
      final data = await _getProductsUseCase.execute(widget.seller.id);
      ProductCache.set(userId, widget.seller.id, data);

      if (mounted) {
        setState(() {
          _all
            ..clear()
            ..addAll(data);
          _filtered = List.from(_all);
        });
      }
    } catch (e) {
      if (mounted && _all.isEmpty) {
        setState(() {
          _error = 'Не удалось загрузить товары: $e';
          _loading = false;
        });
      }
    }
  }

  // === КОРЗИНА ===
  Future<void> _loadSellerCart() async {
    try {
      final cart = await CartService.getSellerCart(widget.seller.id);
      if (mounted) {
        setState(() {
          _currentCart = cart;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _setupCartSubscription() {
    _cartSubscription = CartService.watchSellerCart(widget.seller.id).listen((cart) {
      if (mounted) {
        setState(() => _currentCart = cart);
      }
    });
  }

  // === ДОБАВЛЕНИЕ В КОРЗИНУ ===
  Future<void> _addToCart(ProductResponse product) async {
    final quantity = await _showQuantityDialog(product);
    if (quantity == null || quantity <= 0) return;

    setState(() => _loadingProducts[product.id] = true);
    try {
      await CartService.addToSellerCart(
        sellerId: widget.seller.id,
        productId: product.id,
        quantity: quantity,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} добавлен в корзину'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingProducts.remove(product.id));
      }
    }
  }

  Future<double?> _showQuantityDialog(ProductResponse product) async {
    final controller = TextEditingController(
      text: product.minOrderQty > 0 ? product.minOrderQty.toString() : '1',
    );
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Количество: ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Цена: ${product.price.toStringAsFixed(0)} ₸ / ${product.unit}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (product.minOrderQty > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Минимум: ${product.minOrderQty.toStringAsFixed(2)} ${product.unit}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Количество (${product.unit})',
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final qty = double.tryParse(controller.text);
                if (qty == null || qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Введите корректное количество')),
                  );
                  return;
                }
                if (product.minOrderQty > 0 && qty < product.minOrderQty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Минимальное количество: ${product.minOrderQty.toStringAsFixed(2)} ${product.unit}',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, qty);
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  // === НИЖНЯЯ ПАНЕЛЬ ===
  Widget _buildCartSummary() {
    if (_currentCart.items.isEmpty) {
      return Text(
        'Корзина пуста',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    final int itemCount = _currentCart.items.length;
    final String productWord = getRussianProductWord(itemCount);
    return Text(
      '$itemCount $productWord',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        top: false,
        child: _currentCart.items.isEmpty
            ? Row(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Корзина пуста',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCartSummary(),
                  Text(
                    '${_currentCart.totalAmount.toStringAsFixed(0)} ₸',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartScreen(cart: _currentCart)),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Перейти к корзине'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _cartSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.seller.organizationName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        // КНОПКА ОЧИСТКИ КЭША УДАЛЕНА
      ),
      body: _loading && _all.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? _ErrorState(message: _error, onRetry: _loadData)
          : Column(
        children: [
          // Инфо о продавце
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.seller.organizationName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.seller.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.seller.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (widget.seller.minOrderAmount > 0)
                      Text(
                        'Минимальный заказ: ${widget.seller.minOrderAmount.toStringAsFixed(0)} ₸',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Поиск
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Поиск по товарам...',
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
          ),
          // СПИСОК С PULL-TO-REFRESH
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: _filtered.isEmpty
                  ? const _EmptyState(
                title: 'Товары не найдены',
                subtitle: 'Попробуйте изменить запрос.',
              )
                  : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _ProductTile(
                  p: _filtered[i],
                  onAddToCart: () => _addToCart(_filtered[i]),
                  loading: _loadingProducts[_filtered[i].id] == true,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }
}

// === ВИДЖЕТЫ (без изменений) ===
class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.p,
    required this.onAddToCart,
    required this.loading,
  });

  final ProductResponse p;
  final VoidCallback onAddToCart;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: ResponsiveHelper.iconSize(context, 56),
              height: ResponsiveHelper.iconSize(context, 56),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (p.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      p.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${p.price.toStringAsFixed(0)} ₸ / ${p.unit}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (p.minOrderQty > 0)
                        Text(
                          'Мин: ${p.minOrderQty.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            loading
                ? SizedBox(
              width: ResponsiveHelper.iconSize(context, 52),
              height: ResponsiveHelper.iconSize(context, 52),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
                : FilledButton.tonal(
              onPressed: onAddToCart,
              style: FilledButton.styleFrom(
                minimumSize: Size(ResponsiveHelper.iconSize(context, 56), ResponsiveHelper.iconSize(context, 56)),
                maximumSize: Size(ResponsiveHelper.iconSize(context, 56), ResponsiveHelper.iconSize(context, 56)),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Icon(Icons.add_shopping_cart_rounded, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}