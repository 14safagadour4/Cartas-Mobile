import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cartas/core/services/api_service.dart';
import 'package:cartas/features/phyto_lab/services/phyto_lab_service.dart';

class PhytoLabProvider extends ChangeNotifier {
  // --- Patient Profile Variables (14 Variables) ---
  int age = 25;
  bool hasHypertension = false;
  bool hasDiabetes = false;
  bool hasKidneyDisease = false;
  bool isPregnant = false;
  int medicationsCount = 0;
  bool usesAnticoagulants = false;
  
  // Potential extra variables for better analysis
  double weight = 65.0;
  String currentGoal = 'Energy'; // Energy, Sleep, Digestion, Immunity, Pain, Stress

  // --- Selection State ---
  List<dynamic> selectedPlants = [];
  bool isLoading = false;
  Map<String, dynamic>? analysisResult;

  int _getGoalInt(String goal) {
    switch (goal) {
      case 'Energy': return 0;
      case 'Sleep': return 1;
      case 'Digestion': return 2;
      case 'Immunity': return 3;
      case 'Pain': return 4;
      case 'Stress': return 5;
      default: return 0;
    }
  }

  Future<void> runAnalysis() async {
    isLoading = true;
    notifyListeners();

    try {
      List<int> ids = selectedPlants.map((p) => (p.id as int)).toList();
      analysisResult = await PhytoLabService.analyzeCombination(
        plantIds: ids,
        goal: _getGoalInt(currentGoal),
      );
    } catch (e) {
      debugPrint("Error during analysis: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateAge(int value) {
    age = value;
    notifyListeners();
  }

  void toggleHypertension(bool value) {
    hasHypertension = value;
    notifyListeners();
  }

  void toggleDiabetes(bool value) {
    hasDiabetes = value;
    notifyListeners();
  }

  void toggleKidneyDisease(bool value) {
    hasKidneyDisease = value;
    notifyListeners();
  }

  void togglePregnancy(bool value) {
    isPregnant = value;
    notifyListeners();
  }

  void updateMedicationsCount(int value) {
    medicationsCount = value;
    notifyListeners();
  }

  void toggleAnticoagulants(bool value) {
    usesAnticoagulants = value;
    notifyListeners();
  }

  void updateGoal(String goal) {
    currentGoal = goal;
    notifyListeners();
  }

  void togglePlantSelection(dynamic plant) {
    if (selectedPlants.contains(plant)) {
      selectedPlants.remove(plant);
    } else {
      if (selectedPlants.length < 4) {
        selectedPlants.add(plant);
      }
    }
    notifyListeners();
  }

  Future<bool> saveAnalysisAsRemedy(int? specialistId) async {
    if (analysisResult == null) return false;

    isLoading = true;
    notifyListeners();

    try {
      final result = analysisResult!;
      final recipe = result['recipe'] ?? {};
      final effects = result['effects'] ?? {};

      final data = {
        'title': recipe['title'] ?? "Mon Infusion",
        'description': recipe['dosage'] ?? "",
        'ingredients': recipe['ingredients'] ?? "",
        'preparation': recipe['preparation'] ?? "",
        'goal': currentGoal,
        'overallScore': (result['overall_score'] ?? 0.0).toDouble(),
        'energyEffect': (effects['energy_effect'] ?? 0.0).toDouble(),
        'sleepEffect': (effects['sleep_effect'] ?? 0.0).toDouble(),
        'digestionEffect': (effects['digestion_effect'] ?? 0.0).toDouble(),
        'immunityEffect': (effects['immunity_effect'] ?? 0.0).toDouble(),
        'painEffect': (effects['pain_effect'] ?? 0.0).toDouble(),
        'stressEffect': (effects['stress_effect'] ?? 0.0).toDouble(),
        'specialistId': specialistId,
      };

      await PhytoLabService.saveRemedy(data);
      return true;
    } catch (e) {
      print("❌ ERREUR SAUVEGARDE : $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> pendingRemedies = [];
  List<dynamic> myRemedies = [];

  Future<void> fetchMyRemedies() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/phyto-lab/my-remedies');
      if (res.statusCode == 200) {
        myRemedies = jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("Error fetching my remedies: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> aiStats = {'totalValidated': 0, 'averageError': 0.0, 'accuracy': 100.0};

  Future<void> fetchAIStats() async {
    try {
      final res = await ApiService.get('/phyto-lab/stats');
      if (res.statusCode == 200) {
        aiStats = jsonDecode(res.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching AI stats: $e");
    }
  }

  Future<void> fetchPendingRemedies() async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/phyto-lab/pending');
      if (res.statusCode == 200) {
        pendingRemedies = jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("Error fetching pending remedies: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> validateRemedy(int id, double score, String feedback) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.patch('/phyto-lab/$id/validate', {
        'specialistScore': score,
        'feedback': feedback,
      });
      if (res.statusCode == 200) {
        await fetchPendingRemedies();
        return true;
      }
    } catch (e) {
      debugPrint("Error validating remedy: $e");
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> rejectRemedy(int id, String reason) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.patch('/phyto-lab/$id/reject', {
        'reason': reason,
      });
      if (res.statusCode == 200) {
        await fetchPendingRemedies();
        return true;
      }
    } catch (e) {
      debugPrint("Error rejecting remedy: $e");
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> warmupIA() async {
    try {
      await ApiService.get('/phyto-lab/warmup');
    } catch (e) {
      // Silent
    }
  }
}
