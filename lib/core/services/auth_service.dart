import 'dart:convert';
import 'package:cartas/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['data']['accessToken']);
        await prefs.setString('refreshToken', data['data']['refreshToken']);
        await prefs.setString('userRole', data['data']['user']['role']);
        await prefs.setString('firstName', data['data']['user']['firstName']);
        if (data['data']['user']['id'] != null) {
          await prefs.setString('userId', data['data']['user']['id'].toString());
        }
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Erreur lors de la connexion'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connexion impossible. Vérifiez votre réseau ou le serveur.'};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiService.get('/users/profile');
    
    if (response.body.isEmpty) {
      return {'success': false, 'message': 'Le serveur a renvoyé une réponse vide (Status: ${response.statusCode})'};
    }

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Erreur de récupération du profil'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur de lecture des données du serveur'};
    }
  }

  static Future<Map<String, dynamic>> registerMobile(Map<String, dynamic> userData, {String? filePath}) async {
    // Map all values to strings for MultipartRequest fields
    final fields = userData.map((key, value) => MapEntry(key, value.toString()));
    
    final response = await ApiService.postMultipart('/auth/mobile/register', fields, filePath, 'document');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Erreur lors de l’inscription'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userRole');
    await prefs.remove('userId');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('accessToken');
  }
}
