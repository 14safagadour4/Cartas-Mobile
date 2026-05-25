import 'dart:convert';
import 'package:cartas/core/services/api_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getFavorites() async {
    final response = await ApiService.get('/users/profile/favorites');
    if (response.body.isEmpty) return {'success': false, 'data': [], 'message': 'Réponse vide'};
    try {
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'data': data['data']};
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'Erreur de décodage'};
    }
  }

  static Future<Map<String, dynamic>> getRecipes() async {
    final response = await ApiService.get('/users/profile/recipes');
    if (response.body.isEmpty) return {'success': false, 'data': [], 'message': 'Réponse vide'};
    try {
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'data': data['data']};
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'Erreur de décodage'};
    }
  }

  static Future<Map<String, dynamic>> getHistory() async {
    final response = await ApiService.get('/users/profile/history');
    if (response.body.isEmpty) return {'success': false, 'data': [], 'message': 'Réponse vide'};
    try {
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'data': data['data']};
    } catch (e) {
      return {'success': false, 'data': [], 'message': 'Erreur de décodage'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updates) async {
    final response = await ApiService.patch('/users/profile', updates);
    if (response.body.isEmpty) return {'success': false, 'message': 'Réponse vide du serveur'};
    try {
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'data': data['data'], 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de décodage du profil'};
    }
  }

  static Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    final response = await ApiService.patch('/users/profile/password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
    if (response.body.isEmpty) return {'success': false, 'message': 'Réponse vide du serveur'};
    try {
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Erreur de décodage'};
    }
  }
}
