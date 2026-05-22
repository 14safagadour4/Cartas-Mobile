import 'dart:convert';
import 'package:cartas/core/services/api_service.dart';

class PhytoLabService {
  static Future<Map<String, dynamic>> analyzeCombination({
    required List<int> plantIds,
    required int goal,
  }) async {
    final response = await ApiService.post('/phyto-lab/analyze', {
      'plantIds': plantIds,
      'goal': goal,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ BACKEND ERROR [${response.statusCode}]: ${response.body}");
      throw Exception('Erreur lors de l\'analyse ML');
    }
  }

  static Future<Map<String, dynamic>> saveRemedy(Map<String, dynamic> remedyData) async {
    final response = await ApiService.post('/phyto-lab/save', remedyData);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de l\'enregistrement du remède');
    }
  }
}
