import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final ageText = _ageController.text.trim();

    if (email.isEmpty || password.isEmpty || ageText.isEmpty) {
      _showMessage("Lütfen tüm alanları doldurun.");
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      _showMessage("Geçerli bir yaş girin.");
      return;
    }

    final success = await AuthService.register(email, password, age);

    if (success) {
      _showMessage("✅ Kayıt başarılı! Giriş ekranına yönlendiriliyorsunuz...");
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      _showMessage("❌ Kayıt başarısız. Lütfen bilgilerinizi kontrol edin.");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white70,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/kitchen_bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: _inputDecoration('Email'),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: _inputDecoration('Şifre'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Yaş'),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Kayıt Ol', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Zaten hesabın var mı? Giriş yap',
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
          ),
        ],
      ),
    );
  }
}
