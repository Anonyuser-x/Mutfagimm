import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/index_screen.dart'; // <-- Liste ekranı
import 'screens/add_new_product_screen.dart';
import 'screens/ai_suggestions_screen.dart';
import 'screens/update_product_screen.dart'; // <-- Güncelleme ekranı
import 'screens/ai_vitamin_screen.dart'; // <-- Vitamin önerisi ekranı

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.loadToken(); // Token'ı yükle
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn =
        AuthService.token != null && AuthService.token!.isNotEmpty;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YourKitchenAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'NotoSans', // Türkçe karakter desteği sağlamak için fontu değiştirdik
            color: Colors.black,
            fontSize: 18,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'NotoSans', // Türkçe karakter desteği sağlamak için fontu değiştirdik
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/addProduct': (context) => const AddProductScreen(),
        '/suggestRecipe': (context) => const SuggestRecipeScreen(),
        '/updateProduct': (context) => const UpdateProductScreen(),
        '/productList': (context) => IndexScreen(), // <-- Burada const kullanılmaz
        '/vitaminSuggestions': (context) => SuggestVitaminProductsScreen(), // AiVitaminScreen'i SuggestVitaminProductsScreen olarak güncelledik.
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonItems = [
      {'label': 'Yeni Ürün Ekle', 'icon': Icons.add, 'route': '/addProduct'},
      {'label': 'Tarif Önerisi Al', 'icon': Icons.fastfood, 'route': '/suggestRecipe'},
      {'label': 'Ürün Listem', 'icon': Icons.list, 'route': '/productList'},
      {'label': 'Çıkış Yap', 'icon': Icons.exit_to_app, 'route': '/login'},
      {'label': 'Vitamin Önerisi Al', 'icon': Icons.health_and_safety, 'route': '/vitaminSuggestions'},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text(
          'YourKitchenAI',
          style: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoş geldin 👋',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bugün mutfağında neler var?',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: buttonItems.map((item) {
                  return GestureDetector(
                    onTap: () {
                      if (item['label'] == 'Çıkış Yap') {
                        _logout(context);
                      } else {
                        Navigator.pushNamed(context, item['route'] as String);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['label'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
