import 'dart:convert';
import 'package:cartas/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_models.dart';

class LearningService {
  /// Récupère toutes les catégories et leurs modules validés
  static Future<List<LearningCategory>> fetchCategories() async {
    try {
      final response = await ApiService.get('/learning/categories');
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> list;
        if (decoded is Map && decoded.containsKey('data')) {
          list = decoded['data'];
        } else if (decoded is List) {
          list = decoded;
        } else {
          return [];
        }
        return list.map((c) => LearningCategory.fromJson(c)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur fetchCategories: $e');
      return [];
    }
  }

  /// Récupère tous les modules publiés
  static Future<List<LearningModule>> fetchModules() async {
    try {
      final response = await ApiService.get('/learning/modules');
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> list;
        if (decoded is Map && decoded.containsKey('data')) {
          list = decoded['data'];
        } else if (decoded is List) {
          list = decoded;
        } else {
          return [];
        }
        return list.map((m) => LearningModule.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur fetchModules: $e');
      return [];
    }
  }

  /// Synchronise les points de l'utilisateur avec le backend Spring Boot.
  static Future<bool> syncPoints(int points) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) return false;

      final response = await ApiService.patch('/users/$userId/points', {
        'earnedPoints': points,
      });

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors de la synchronisation des points: $e');
      return false;
    }
  }

  /// Récupère les points actuels de l'utilisateur depuis la BD au démarrage.
  static Future<int?> fetchUserPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) return null;

      final response = await ApiService.get('/users/$userId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['earnedPoints'] as int?;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération des points: $e');
      return null;
    }
  }
}
