import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000';
  static String? _token; // Alınan token burada saklanacak

  // Dışarıdan token'a erişmek isteyenler için getter
  static String? get token => _token;

  // Kayıt işlemi
  static Future<bool> register(String email, String password, int age) async {
    final url = Uri.parse('$baseUrl/auth/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'age': age,
        }),
      );

      if (response.statusCode == 201) {
        print("✅ Kayıt başarılı: ${response.body}");
        return true;
      } else {
        print("❌ Kayıt hatası: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("🔴 Kayıt istisnası: $e");
      return false;
    }
  }

  // Giriş işlemi ve token saklama
  static Future<String?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/token');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Token'ı kontrol etme ve saklama
        if (json.containsKey('access_token') && json['access_token'] != null) {
          _token = json['access_token']; // Token saklanıyor
          print("✅ Giriş başarılı. Token alındı: $_token");

          // Token'ı SharedPreferences'e kaydedelim
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', _token!);

          return _token; // Token'ı geri döndürüyoruz
        } else {
          print("❌ Token alınamadı.");
          return null;
        }
      } else {
        print("❌ Giriş hatası: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("🔴 Giriş istisnası: $e");
      return null;
    }
  }

  // Diğer yerlerden kullanılmak üzere yetkili header döner
  static Map<String, String> getAuthHeaders() {
    if (_token == null) {
      print("❌ Token mevcut değil.");
      return {
        'Content-Type': 'application/json',
      };
    } else {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',  // Bearer token ekliyoruz
      };
    }
  }

  // SharedPreferences'ten token'ı alarak _token'ı güncelleme
  static Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('access_token');
      if (_token != null) {
        print("✅ Token yüklendi: $_token");
      } else {
        print("❌ Token bulunamadı.");
      }
    } catch (e) {
      print("🔴 Token yükleme hatası: $e");
    }
  }

  // Token'ı kaldırma
  static Future<void> logout() async {
    try {
      // Token'ın olup olmadığını kontrol etmeden önce kullanıcının login durumunu kontrol et
      if (_token == null) {
        print("❌ Token bulunamadı, çıkış yapılamaz.");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      _token = null;
      print("✅ Çıkış yapıldı. Token silindi.");
    } catch (e) {
      print("🔴 Çıkış hatası: $e");
    }
  }

}
