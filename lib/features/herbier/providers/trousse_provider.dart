import 'package:flutter/material.dart';
import '../models/plant.dart';

class TrousseProvider with ChangeNotifier {
  // Les catégories de la trousse personnalisée
  final Map<String, List<Plant>> _trousse = {
    'Stress': [],
    'Digestion': [],
    'Sommeil': [],
    'Règles': [],
  };

  Map<String, List<Plant>> get trousse => _trousse;

  int get totalItems => _trousse.values.fold(0, (sum, list) => sum + list.length);

  void addToTrousse(String category, Plant plant) {
    if (_trousse.containsKey(category)) {
      if (!_trousse[category]!.any((p) => p.id == plant.id)) {
        _trousse[category]!.add(plant);
        notifyListeners();
      }
    }
  }

  void removeFromTrousse(String category, int plantId) {
    if (_trousse.containsKey(category)) {
      _trousse[category]!.removeWhere((p) => p.id == plantId);
      notifyListeners();
    }
  }

  bool isInTrousse(int plantId) {
    return _trousse.values.any((list) => list.any((p) => p.id == plantId));
  }
}
