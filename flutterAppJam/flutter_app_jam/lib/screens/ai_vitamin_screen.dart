import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app_jam/services/auth_service.dart'; // Bu satırı ekliyoruz

class SuggestVitaminProductsScreen extends StatefulWidget {
  const SuggestVitaminProductsScreen({Key? key}) : super(key: key);

  @override
  State<SuggestVitaminProductsScreen> createState() =>
      _SuggestVitaminProductsScreenState();
}

class _SuggestVitaminProductsScreenState
    extends State<SuggestVitaminProductsScreen> {
  String _suggestions = '';
  bool _isLoading = false;

  Future<void> _fetchSuggestions() async {
    setState(() {
      _isLoading = true;
      _suggestions = '';
    });

    try {
      // Token'ı AuthService'den alıyoruz
      final token = AuthService.token;
      if (token == null) {
        throw Exception('Token bulunamadı');
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/products/ai/suggest-products-from-kitchen'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _suggestions = data['suggestions'] ?? 'Öneri bulunamadı.';
          _isLoading = false;
        });
      } else {
        throw Exception('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitamin Bazlı Ürün Önerisi',
            style: TextStyle(fontFamily: 'NotoSans')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _fetchSuggestions,
              child: const Text('Önerileri Al', style: TextStyle(fontFamily: 'NotoSans')),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _suggestions,
                  style: const TextStyle(fontFamily: 'NotoSans'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
