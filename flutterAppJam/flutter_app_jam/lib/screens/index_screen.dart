import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_jam/services/auth_service.dart';

class IndexScreen extends StatefulWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final token = AuthService.token;
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/products/'),
      headers: AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      throw Exception('Failed to load products');
    }
  }

  Future<void> _deleteProduct(int productId) async {
    final token = AuthService.token;
    if (token == null) return;

    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/products/$productId'),
      headers: AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      setState(() {
        _products.removeWhere((product) => product['id'] == productId);
      });
    }
  }

  void _navigateToUpdateProduct(Map<String, dynamic> product) {
    Navigator.pushNamed(context, '/updateProduct', arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ürün Listem',
          style: TextStyle(
            fontFamily: 'NotoSans',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(
        child: Text(
          'Hiç ürün eklenmemiş.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kategori: ${product['category']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'Fiyat: ${product['price']} ₺   |   Miktar: ${product['quantity']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.deepOrange),
                      onPressed: () => _navigateToUpdateProduct(product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await _deleteProduct(product['id']);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () => Navigator.pushNamed(context, '/addProduct'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
