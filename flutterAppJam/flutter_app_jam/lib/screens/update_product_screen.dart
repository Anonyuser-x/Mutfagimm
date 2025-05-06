import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_jam/services/auth_service.dart';

class UpdateProductScreen extends StatefulWidget {
  const UpdateProductScreen({super.key});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late int productId;
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> product =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    productId = product['id'];
    _nameController = TextEditingController(text: product['name']);
    _categoryController = TextEditingController(text: product['category']);
    _quantityController =
        TextEditingController(text: product['quantity'].toString());
    _priceController =
        TextEditingController(text: product['price'].toString());
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/products/$productId'),
      headers: {
        'Content-Type': 'application/json',
        ...AuthService.getAuthHeaders(),
      },
      body: jsonEncode({
        'name': _nameController.text,
        'category': _categoryController.text,
        'quantity': double.tryParse(_quantityController.text) ?? 0,
        'price': double.tryParse(_priceController.text) ?? 0,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // Güncelleme başarılı, geri dön
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ürün güncellenemedi!')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürünü Güncelle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ürün Adı'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Boş bırakılamaz' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Boş bırakılamaz' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Miktar'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Boş bırakılamaz' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Boş bırakılamaz' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProduct,
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
