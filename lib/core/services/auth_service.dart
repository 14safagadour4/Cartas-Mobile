import 'dart:convert';
import 'package:cartas/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
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
      await prefs.setString('userId', data['data']['user']['id'].toString());
      
      // Sauvegarder les identifiants par rôle pour le pré-remplissage correct
      String role = data['data']['user']['role'].toString().toLowerCase();
      
      // Détection robuste du rôle
      String roleKey = 'user';
      if (role.contains('special')) {
        roleKey = 'specialist';
      } else if (role.contains('art')) {
        roleKey = 'art_therapist';
      }
      
      await prefs.setString('${roleKey}_savedEmail', email);
      await prefs.setString('${roleKey}_savedPassword', password);
      
      return {'success': true, 'data': data['data']};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Erreur lors de la connexion'};
    }
  }

  static Future<Map<String, dynamic>> registerMobile(Map<String, dynamic> userData, {String? filePath}) async {
    final fields = userData.map((key, value) => MapEntry(key, value.toString()));
    final response = await ApiService.postMultipart('/auth/mobile/register', fields, filePath, 'document');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      
      // Déterminer le rôle pour la clé de sauvegarde
      String roleRaw = userData['role']?.toString().toLowerCase() ?? 'user';
      String roleKey = 'user';
      if (roleRaw.contains('special')) {
        roleKey = 'specialist';
      } else if (roleRaw.contains('art')) {
        roleKey = 'art_therapist';
      }

      if (userData['email'] != null) {
        await prefs.setString('${roleKey}_savedEmail', userData['email'].toString());
      }
      if (userData['password'] != null) {
        await prefs.setString('${roleKey}_savedPassword', userData['password'].toString());
      }
      return {
        'success': true, 
        'message': data['message'],
        'userId': data['data']?.toString() 
      };
    } else {
      return {'success': false, 'message': data['message'] ?? 'Erreur lors de l\'inscription'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userRole');
    await prefs.remove('userId');
    await prefs.remove('firstName');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('accessToken');
  }
}
