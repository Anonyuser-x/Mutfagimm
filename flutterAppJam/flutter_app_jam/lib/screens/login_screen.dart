import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';
  bool isLoading = false;

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Eğer email ya da şifre boşsa hata mesajı göster
    if (email.isEmpty || password.isEmpty) {
      setState(() => error = 'Lütfen tüm alanları doldurun.');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    // AuthService üzerinden login işlemini başlat
    final token = await AuthService.login(email, password);

    setState(() {
      isLoading = false;
    });

    // Eğer token alınmışsa, başarılı giriş yap ve ana sayfaya git
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Hata mesajı göster
      setState(() => error = 'Giriş başarısız. Bilgileri kontrol edin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka planda mutfak resmi
          Positioned.fill(
            child: Image.asset(
              'assets/kitchen_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Yarı saydam koyu katman
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Login ekranının içeriği
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'YourKitchenAI',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // E-posta alanı
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    // Şifre alanı
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Şifre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    // Giriş Yap butonu
                    ElevatedButton(
                      onPressed: isLoading ? null : _login, // Buton yükleniyorsa tıklanamaz
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Giriş Yap'),
                    ),
                    const SizedBox(height: 12),
                    // Hata mesajı
                    if (error.isNotEmpty)
                      Text(error, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    // Kayıt olma linki
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: const Text(
                        'Hesabınız yok mu? Kayıt Ol',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
