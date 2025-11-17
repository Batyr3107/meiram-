// lib/screens/sellers_screen.dart
import 'package:flutter/material.dart';
import '../api/seller_api.dart';
import 'seller_products_screen.dart';

class SellersScreen extends StatefulWidget {
  const SellersScreen({super.key});

  @override
  State<SellersScreen> createState() => _SellersScreenState();
}

class _SellersScreenState extends State<SellersScreen> {
  final List<SellerResponse> _allSellers = [];
  List<SellerResponse> _filteredSellers = [];
  bool _loading = true;
  String _error = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSellers();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredSellers = _allSellers
          .where((s) => s.organizationName.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _loadSellers() async {
    try {
      const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
      final sellerApi = SellerApi(baseUrl);
      final response = await sellerApi.getActiveSellers(page: 0, size: 100);
      setState(() {
        _allSellers.addAll(response.content);
        _filteredSellers = List.from(_allSellers);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar УДАЛЁН — теперь только в MainScreen
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Поиск продавцов...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Результаты поиска
          if (_searchCtrl.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Найдено ${_filteredSellers.length} продавцов',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),

          // Список продавцов
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSellers.length,
              itemBuilder: (context, i) => _buildSellerCard(_filteredSellers[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(SellerResponse seller) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green[50],
            child: const Icon(Icons.store_rounded, color: Colors.green),
          ),
          title: Text(
            seller.organizationName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            seller.description.isNotEmpty ? seller.description : 'Без описания',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SellerProductsScreen(seller: seller),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}