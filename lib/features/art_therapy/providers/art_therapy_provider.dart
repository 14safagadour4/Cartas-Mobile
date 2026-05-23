import 'package:flutter/material.dart';
import '../models/therapy_workshop.dart';
import '../models/therapy_coloring.dart';
import '../models/therapy_review.dart';
import '../models/user_drawing.dart';
import '../services/art_therapy_service.dart';

class ArtTherapyProvider extends ChangeNotifier {
  final ArtTherapyService _service = ArtTherapyService();

  List<TherapyWorkshop> _workshops = [];
  List<TherapyColoring> _colorings = [];
  List<TherapyReview> _reviews = [];
  List<UserDrawing> _userGallery = [];

  bool _isLoading = false;
  String? _error;

  List<TherapyWorkshop> get workshops => _workshops;
  List<TherapyColoring> get colorings => _colorings;
  List<TherapyReview> get reviews => _reviews;
  List<UserDrawing> get userGallery => _userGallery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getWorkshops(),
        _service.getColorings(),
        _service.getReviews(),
      ]);

      _workshops = results[0] as List<TherapyWorkshop>;
      _colorings = results[1] as List<TherapyColoring>;
      _reviews = results[2] as List<TherapyReview>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> bookWorkshop(int workshopId, String userEmail) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.reserveWorkshop(workshopId, userEmail);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGallery(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userGallery = await _service.getUserGallery(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveDrawing(UserDrawing drawing) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.saveUserDrawing(drawing);
      // Refresh gallery
      await fetchGallery(drawing.userEmail);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> submitReview(TherapyReview review) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.addReview(review);
      // Refresh reviews
      _reviews = await _service.getReviews();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
