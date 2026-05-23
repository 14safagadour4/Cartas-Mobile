import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cartas/core/services/api_service.dart';
import '../models/plant.dart';

class PlantProvider extends ChangeNotifier {
  List<Plant> _plants = [];
  bool _isLoading = false;
  String _error = '';

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchPlants() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.get('/plants');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _plants = data.map((json) => Plant.fromJson(json)).toList();
      } else {
        _error = 'Failed to load: HTTP ${response.statusCode}\n${response.body}';
      }
    } catch (e) {
      _error = 'Error parsing: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
