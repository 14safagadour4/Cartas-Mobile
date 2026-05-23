import 'package:flutter/material.dart';
import '../services/learning_service.dart';
import '../models/learning_models.dart';

class LearningProvider extends ChangeNotifier {
  // Données dynamiques venant du serveur
  List<LearningCategory> _categories = [];
  List<LearningModule> _modules = [];

  bool _hasFetchedData = false;
  
  List<LearningCategory> get categories => _hasFetchedData ? _categories : LearningMockData.categories;
  List<LearningModule> get modules => _hasFetchedData ? _modules : LearningMockData.modules;

  List<LearningModule> getFilteredModules(String? type) {
    if (type == null || type == 'ALL') {
      return modules;
    }
    return modules.where((m) => m.contentType == type).toList();
  }

  /// Charge toutes les données depuis le serveur
  Future<void> loadAllData() async {
    final fetchedCategories = await LearningService.fetchCategories();
    final fetchedModules = await LearningService.fetchModules();

    _categories = fetchedCategories;
    _modules = fetchedModules;
    _hasFetchedData = true;

    notifyListeners();
  }

  // Map of moduleId to number of completed lessons
  final Map<String, int> _moduleCompletedLessons = {};
  
  // Set of completed quiz IDs
  final Set<String> _completedQuizIds = {};

  // Espace Maman-Enfant Score (interaction progress)
  int _mamanEnfantScore = 0;

  // Points de réduction gagnés
  int _earnedPoints = 0;

  // Liste des IDs de modules récompensés pour éviter les doublons
  final Set<String> _rewardedModuleIds = {};

  int getCompletedLessons(String moduleId) => _moduleCompletedLessons[moduleId] ?? 0;
  Set<String> get completedQuizIds => _completedQuizIds;
  int get mamanEnfantScore => _mamanEnfantScore;
  int get earnedPoints => _earnedPoints;

  /// Initialise les points depuis la base de données au démarrage
  Future<void> initializePoints() async {
    // Charger aussi les données de contenu
    loadAllData();
    
    final points = await LearningService.fetchUserPoints();
    if (points != null) {
      _earnedPoints = points;
      notifyListeners();
    }
  }

  // Mark a lesson as completed
  bool completeLesson(String moduleId, int totalLessons) {
    int currentCompleted = getCompletedLessons(moduleId);
    
    // Si la leçon n'était pas déjà complétée (simplification: on incrémente juste)
    _moduleCompletedLessons[moduleId] = currentCompleted + 1;
    
    bool justFinishedModule = false;
    // Vérifier si le module vient d'être achevé
    if (_moduleCompletedLessons[moduleId] == totalLessons && !_rewardedModuleIds.contains(moduleId)) {
      _rewardedModuleIds.add(moduleId);
      _addPoints(50); // Récompense de 50 points
      justFinishedModule = true;
    }
    
    notifyListeners();
    return justFinishedModule;
  }

  // Mark a quiz as completed
  void completeQuiz(String quizId) {
    if (!_completedQuizIds.contains(quizId)) {
      _completedQuizIds.add(quizId);
      addQuizPoints();
    }
  }

  void addQuizPoints() {
    _addPoints(10); // +10 pts pour un quiz réussi
  }

  // Add points to Maman-Enfant score
  void addMamanEnfantScore(int points) {
    _mamanEnfantScore += points;
    _addPoints(points); // Score pour les jeux interactifs
  }

  void _addPoints(int amount) {
    _earnedPoints += amount;
    notifyListeners();
    
    // Synchronisation asynchrone avec le backend (BD)
    LearningService.syncPoints(_earnedPoints);
  }

  // Calculate module progress (0.0 to 1.0)
  double calculateModuleProgress(String moduleId, int totalLessons) {
    if (totalLessons == 0) return 0.0;
    final completed = getCompletedLessons(moduleId);
    // Limit progress to 1.0 maximum
    return (completed / totalLessons).clamp(0.0, 1.0);
  }
}

