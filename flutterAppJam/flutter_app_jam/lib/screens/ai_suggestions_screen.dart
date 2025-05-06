import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SuggestRecipeScreen extends StatefulWidget {
  const SuggestRecipeScreen({Key? key}) : super(key: key);

  @override
  State<SuggestRecipeScreen> createState() => _SuggestRecipeScreenState();
}

class _SuggestRecipeScreenState extends State<SuggestRecipeScreen> {
  final _ingredientsController = TextEditingController();
  List<dynamic> _recipes = [];
  bool _isLoading = false;

  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });

    final ingredients = _ingredientsController.text.split(',').map((e) => e.trim()).toList();
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/products/ai/suggest-recipes'),
      body: json.encode({'ingredients': ingredients}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 ile çözümleme

      if (data['suggested_recipes'] is List) {
        setState(() {
          _recipes = data['suggested_recipes'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Beklenen "suggested_recipes" verisi liste türünde değil.');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Tarifler alınırken hata oluştu.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarif Önerisi', style: TextStyle(fontFamily: 'NotoSans')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Malzemeler (virgülle ayırın)',
              ),
              style: const TextStyle(fontFamily: 'NotoSans'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchRecipes,
              child: const Text('Tarifleri Göster', style: TextStyle(fontFamily: 'NotoSans')),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  String recipeName = recipe['title'] ?? recipe['name'] ?? 'Bilinmeyen Tarif';
                  String instructions = recipe['instructions'] ?? 'Talimat bulunamadı.';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        recipeName,
                        style: const TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        instructions,
                        style: const TextStyle(fontFamily: 'NotoSans'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
