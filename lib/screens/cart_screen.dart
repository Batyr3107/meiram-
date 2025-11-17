import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../api/order_api.dart';
import '../api/address_api.dart';
import 'orders_screen.dart';
import 'main_screen.dart';
import '../api/cart_api.dart';

class CartScreen extends StatefulWidget {
  final CartResponse cart;

  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartResponse _cart;
  bool _loading = false;
  String? _successOrderId;
  final _commentCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  List<AddressResponse> _addresses = [];
  String? _selectedAddressId;
  bool _showManualInput = false;

  static const _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  late final OrderApi _orderApi;
  late final AddressApi _addressApi;

  @override
  void initState() {
    super.initState();
    _cart = widget.cart;
    _orderApi = OrderApi(_baseUrl);
    _addressApi = AddressApi(_baseUrl);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _addressApi.getAllAddresses();
      if (mounted) {
        setState(() {
          _addresses = addresses;
          // Если ничего не выбрано и есть адреса — выберем первый
          if (_selectedAddressId == null && addresses.isNotEmpty) {
            _selectedAddressId = addresses.first.id;
            _addressCtrl.text = addresses.first.address;
          }
        });
      }
    } catch (e) {
      print('Error loading addresses: $e');
      // При ошибке показываем ручной ввод
      setState(() => _showManualInput = true);
    }
  }

  Future<void> _refreshCart() async {
    setState(() => _loading = true);
    try {
      final updatedCart = await CartService.getSellerCart(_cart.sellerId);
      if (mounted) {
        setState(() {
          _cart = updatedCart;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки корзины: $e')),
        );
      }
    }
  }

  Future<void> _removeItem(CartItemResponse item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: Text('Удалить "${item.productName}" из корзины?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    try {
      await CartService.removeItemFromCart(_cart.sellerId, item.itemId);
      await _refreshCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар удален из корзины'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _updateQuantity(CartItemResponse item) async {
    final controller = TextEditingController(text: item.quantity.toString());
    final newQuantity = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Изменить количество: ${item.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Количество (${item.unit})',
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final qty = double.tryParse(controller.text);
              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите корректное количество')),
                );
                return;
              }
              Navigator.pop(context, qty);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (newQuantity == null || newQuantity == item.quantity) return;

    setState(() => _loading = true);

    try {
      await CartService.updateItemQuantity(
        sellerId: _cart.sellerId,
        itemId: item.itemId,
        quantity: newQuantity,
      );
      await _refreshCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Количество обновлено'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  Future<void> _submitOrder() async {
    if (_cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Корзина пуста')));
      return;
    }

    print('🛒 === SUBMIT ORDER DEBUG ===');
    print('🛒 Cart ID: "${_cart.cartId}"');
    print('🛒 Seller ID: "${_cart.sellerId}"');
    print('🛒 Items count: ${_cart.items.length}');
    print('🛒 Total amount: ${_cart.totalAmount}');
    print('🛒 === END DEBUG ===');

    setState(() => _loading = true);

    try {
      final result = await _orderApi.submitOrder(
        cartId: _cart.cartId,
        comment: _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
        deliveryAddress: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      );

      if (!mounted) return;

      await CartService.clearSellerCart(_cart.sellerId);

      setState(() {
        _successOrderId = result.orderId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      print('❌ Order submission error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка оформления: $e')),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _clearCart() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить корзину?'),
        content: const Text('Все товары будут удалены из корзины.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await CartService.clearSellerCart(_cart.sellerId);
      await _refreshCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Корзина очищена'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка очистки корзины: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_successOrderId != null) {
      return _buildSuccessScreen();
    }

    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Корзина'),
          backgroundColor: Colors.green[100],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: cs.outline),
              const SizedBox(height: 16),
              Text('Корзина пуста', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Добавьте товары из каталога', style: textTheme.bodyMedium),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Вернуться к товарам'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        backgroundColor: Colors.green[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refreshCart,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _loading ? null : _clearCart,
            tooltip: 'Очистить корзину',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.store_rounded, color: cs.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _cart.items.isNotEmpty ? _cart.items.first.sellerName : 'Продавец',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                ..._cart.items.map((item) => _CartItemTile(
                  item: item,
                  onRemove: () => _removeItem(item),
                  onEdit: () => _updateQuantity(item),
                )),

                const SizedBox(height: 16),

                TextField(
                  controller: _commentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Комментарий к заказу (необязательно)',
                    hintText: 'Например: позвоните перед доставкой',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  maxLength: 500,
                ),
                const SizedBox(height: 12),

                // Блок выбора адреса доставки
                _buildAddressSelector(),

              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Итого:', style: textTheme.titleLarge),
                      Text(
                        '${_cart.totalAmount.toStringAsFixed(0)} ₸',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _submitOrder,
                      icon: _loading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.check_circle_rounded),
                      label: Text(_loading ? 'Оформление...' : 'Оформить заказ'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Виджет выбора адреса доставки
  Widget _buildAddressSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Адрес доставки',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        if (!_showManualInput && _addresses.isNotEmpty)
          Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAddressId,
                decoration: const InputDecoration(
                  labelText: 'Выберите адрес доставки',
                  border: OutlineInputBorder(),
                  hintText: 'Выберите из сохранённых',
                ),
                isExpanded: true,
                items: _addresses.map((addr) => DropdownMenuItem(
                  value: addr.id,
                  child: Text(
                    addr.address,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                )).toList(),
                onChanged: (id) {
                  final selected = _addresses.firstWhere((a) => a.id == id);
                  _addressCtrl.text = selected.address;
                  setState(() => _selectedAddressId = id);
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showManualInput = true;
                      _addressCtrl.clear();
                    });
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Ввести адрес вручную'),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Адрес доставки',
                  hintText: 'Введите адрес',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                maxLength: 500,
              ),
              if (_addresses.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() => _showManualInput = false);
                    },
                    icon: const Icon(Icons.list, size: 16),
                    label: const Text('Выбрать из сохраненных адресов'),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    final addressText = _addressCtrl.text.trim();
                    if (addressText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Введите адрес для сохранения')),
                      );
                      return;
                    }

                    try {
                      final newAddr = await _addressApi.createAddress(addressText);
                      await _loadAddresses();
                      setState(() {
                        _selectedAddressId = newAddr.id;
                        _showManualInput = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Адрес сохранён'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка сохранения адреса: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Сохранить адрес'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Экран успешного оформления
  Widget _buildSuccessScreen() {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Заказ успешно оформлен!',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Номер заказа: ${_successOrderId!.substring(0, 8)}',
                style: textTheme.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Вскоре продавец подтвердит ваш заказ',
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const OrdersScreen()),
                          );
                        },
                        icon: const Icon(Icons.list_rounded),
                        label: const Text('Посмотреть мои заказы'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const MainScreen()),
                          );
                        },
                        icon: const Icon(Icons.store_rounded),
                        label: const Text('Вернуться к продавцам'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemResponse item;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const _CartItemTile({
    required this.item,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag_rounded, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(0)} ₸ / ${item.unit}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Количество: ${item.quantity.toStringAsFixed(2)} ${item.unit}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onEdit,
                        child: Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.subtotal.toStringAsFixed(0)} ₸',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: Colors.red,
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}