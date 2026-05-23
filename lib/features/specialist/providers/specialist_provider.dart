import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cartas/core/services/api_service.dart';
import '../models/specialist_model.dart';

class SpecialistProvider with ChangeNotifier {
  SpecialistModel? _profile;
  bool _isLoading = false;

  SpecialistModel? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('DEBUG: Récupération du profil à /specialists/me...');
      final response = await ApiService.get('/specialists/me');
      print('DEBUG: Réponse /me - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: Données profil reçues: ${data['data']}');
        _profile = SpecialistModel.fromJson(data['data']);
        notifyListeners();
      } else {
        print('DEBUG: Échec fetchProfile - Body: ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Erreur fatale fetchProfile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(SpecialistModel updatedData) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('DEBUG: Mise à jour profil Specialist - Payload: ${updatedData.toJson()}');
      final response = await ApiService.patch('/specialists/me', updatedData.toJson());
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _profile = SpecialistModel.fromJson(data['data']);
        print('DEBUG: Profil mis à jour avec succès');
        notifyListeners();
        return true;
      } else {
        print('DEBUG: Échec mise à jour - Status: ${response.statusCode}');
        print('DEBUG: Corps de la réponse: ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Erreur fatale updateProfile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}
