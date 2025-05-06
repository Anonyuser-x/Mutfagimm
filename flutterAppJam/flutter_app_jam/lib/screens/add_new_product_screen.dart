import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_jam/services/auth_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  Future<void> _addProduct() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final price = double.tryParse(_priceController.text) ?? 0.0;

    final token = AuthService.token;

    if (token == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/products/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'category': category,
        'quantity': quantity,
        'price': price,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ürün Başarıyla Eklendi')),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.1),
            offset: const Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Yeni Ürün Ekle',
          style: TextStyle(fontFamily: 'NotoSans'),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Ürün bilgilerini girin',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(controller: _nameController, label: 'Ürün Adı'),
            _buildTextField(controller: _categoryController, label: 'Kategori'),
            _buildTextField(
              controller: _quantityController,
              label: 'Miktar',
              inputType: TextInputType.number,
            ),
            _buildTextField(
              controller: _priceController,
              label: 'Fiyat (₺)',
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Ürünü Kaydet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
