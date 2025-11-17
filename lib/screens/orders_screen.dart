import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/order_api.dart';
import 'main_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;
  String _error = '';
  final List<BuyerOrderResponse> _orders = [];

  static const _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  late final OrderApi _orderApi;

  @override
  void initState() {
    super.initState();
    _orderApi = OrderApi(_baseUrl);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response = await _orderApi.getBuyerOrders(page: 0, size: 50);
      setState(() {
        _orders
          ..clear()
          ..addAll(response.content);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить заказы: $e';
        _loading = false;
      });
    }
  }

  void _showOrderDetails(String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final details = await _orderApi.getOrderDetails(orderId);

      if (!mounted) return;
      Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _OrderDetailSheet(details: details),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки деталей: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заказы'),
        backgroundColor: Colors.green[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            // Вернуться на главный экран со всеми табами
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          },
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? _ErrorState(message: _error, onRetry: _loadOrders)
          : _orders.isEmpty
          ? const _EmptyState()
          : RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _OrderCard(
            order: _orders[i],
            onTap: () => _showOrderDetails(_orders[i].orderId),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final BuyerOrderResponse order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя строка: Номер заказа и сумма
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Заказ №${order.orderId.substring(0, 8)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} ₸',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Строка со статусом
              _StatusChip(status: order.status),
              const SizedBox(height: 12),

              // Информация: дата и количество товаров
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateFormat.format(order.createdAt),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        '${order.itemsCount} ${_pluralizeItem(order.itemsCount)}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _pluralizeItem(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'товар';
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'товара';
    }
    return 'товаров';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(color: config.color, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  ({Color color, IconData icon, String label}) _getStatusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return (color: Colors.orange, icon: Icons.schedule_rounded, label: 'Ожидание подтверждения');
      case 'SUBMITTED':
        return (color: Colors.green, icon: Icons.task_alt_rounded, label: 'Принят');
      case 'CONFIRMED':
        return (color: Colors.blue, icon: Icons.check_circle_outline_rounded, label: 'Подтвержден');
      case 'PROCESSING':
        return (color: Colors.purple, icon: Icons.sync_rounded, label: 'Обрабатывается');
      case 'SHIPPED':
        return (color: Colors.cyan, icon: Icons.local_shipping_rounded, label: 'Отправлен');
      case 'DELIVERED':
        return (color: Colors.green, icon: Icons.check_circle_rounded, label: 'Доставлен');
      case 'CANCELLED':
        return (color: Colors.red, icon: Icons.cancel_rounded, label: 'Отменен');
      default:
        return (color: Colors.grey, icon: Icons.help_outline_rounded, label: status);
    }
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final BuyerOrderDetailResponse details;
  const _OrderDetailSheet({required this.details});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Детали заказа',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _InfoCard(
                      children: [
                        _InfoRow(label: 'Номер заказа', value: details.orderId.substring(0, 8)),
                        _InfoRow(label: 'Дата', value: dateFormat.format(details.createdAt)),
                        _InfoRow(label: 'Статус', value: '', widget: _StatusChip(status: details.status)),
                        if (details.comment != null && details.comment!.isNotEmpty)
                          _InfoRow(label: 'Комментарий', value: details.comment!),
                        if (details.deliveryAddress != null && details.deliveryAddress!.isNotEmpty)
                          _InfoRow(label: 'Адрес доставки', value: details.deliveryAddress!),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Товары', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...details.items.map((item) => _OrderItemTile(item: item)),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Итого:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          '${details.totalAmount.toStringAsFixed(0)} ₸',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: cs.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? widget;
  const _InfoRow({required this.label, required this.value, this.widget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          Expanded(child: widget ?? Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItemDetail item;
  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: cs.outlineVariant.withOpacity(0.5))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: cs.primaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.shopping_bag_rounded, size: 24, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item.sellerName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${item.quantity.toStringAsFixed(2)} ${item.unit} × ${item.price.toStringAsFixed(0)} ₸', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Text('${item.subtotal.toStringAsFixed(0)} ₸', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: cs.outline),
          const SizedBox(height: 16),
          Text('Заказов пока нет', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Ваши заказы появятся здесь после оформления', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Повторить')),
        ],
      ),
    );
  }
}