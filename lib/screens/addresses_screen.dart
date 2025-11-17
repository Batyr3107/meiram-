import 'package:flutter/material.dart';
import '../api/address_api.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  bool _loading = true;
  String _error = '';
  final List<AddressResponse> _addresses = [];

  static const _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  late final AddressApi _addressApi;

  @override
  void initState() {
    super.initState();
    _addressApi = AddressApi(_baseUrl);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final addresses = await _addressApi.getAllAddresses();
      setState(() {
        _addresses
          ..clear()
          ..addAll(addresses);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить адреса: $e';
        _loading = false;
      });
    }
  }

  Future<void> _createAddress() async {
    final controller = TextEditingController();
    final address = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить адрес'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Адрес',
            hintText: 'Введите адрес доставки',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );

    if (address == null || address.isEmpty) return;

    setState(() => _loading = true);

    try {
      await _addressApi.createAddress(address);
      await _loadAddresses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Адрес добавлен'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  Future<void> _editAddress(AddressResponse address) async {
    final controller = TextEditingController(text: address.address);
    final newAddress = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить адрес'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Адрес',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (newAddress == null || newAddress.isEmpty) return;

    setState(() => _loading = true);

    try {
      await _addressApi.updateAddress(address.id, newAddress);
      await _loadAddresses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Адрес обновлен'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  Future<void> _deleteAddress(AddressResponse address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить адрес?'),
        content: Text('Удалить адрес: ${address.address}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
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
      await _addressApi.deleteAddress(address.id);
      await _loadAddresses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Адрес удален'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои адреса'),
        backgroundColor: Colors.green[100],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadAddresses,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
            ),
          ],
        ),
      )
          : _addresses.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on_outlined, size: 80, color: cs.outline),
            const SizedBox(height: 16),
            const Text('Адресов еще нет'),
            const SizedBox(height: 8),
            Text(
              'Добавьте свой первый адрес доставки',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _createAddress,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Добавить адрес'),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _AddressTile(
          address: _addresses[i],
          onEdit: () => _editAddress(_addresses[i]),
          onDelete: () => _deleteAddress(_addresses[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAddress,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressResponse address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressTile({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: cs.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.address,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  color: Colors.blue,
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: onDelete,
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