import 'dart:convert';
import '../models/therapy_workshop.dart';
import '../models/therapy_coloring.dart';
import '../models/therapy_review.dart';
import '../models/user_drawing.dart';
import 'package:cartas/core/services/api_service.dart';

class ArtTherapyService {
  Future<List<TherapyWorkshop>> getWorkshops() async {
    final response = await ApiService.get('/art-therapy/workshops');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['data'] != null) {
        return (jsonResponse['data'] as List)
            .map((e) => TherapyWorkshop.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to load workshops');
    }
  }

  Future<List<TherapyColoring>> getColorings() async {
    final response = await ApiService.get('/art-therapy/colorings');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['data'] != null) {
        return (jsonResponse['data'] as List)
            .map((e) => TherapyColoring.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to load colorings');
    }
  }

  Future<List<TherapyReview>> getReviews() async {
    final response = await ApiService.get('/art-therapy/reviews');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['data'] != null) {
        return (jsonResponse['data'] as List)
            .map((e) => TherapyReview.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to load reviews');
    }
  }
  Future<void> reserveWorkshop(int workshopId, String userEmail) async {
    final response = await ApiService.post('/art-therapy/workshops/reserve', {
      'workshopId': workshopId,
      'userEmail': userEmail,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to reserve workshop');
    }
  }

  Future<List<UserDrawing>> getUserGallery(String email) async {
    final response = await ApiService.get('/art-therapy/gallery?email=$email');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['data'] != null) {
        return (jsonResponse['data'] as List)
            .map((e) => UserDrawing.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw Exception('Failed to load gallery');
    }
  }

  Future<void> saveUserDrawing(UserDrawing drawing) async {
    final response = await ApiService.post('/art-therapy/gallery/save', drawing.toJson());
    if (response.statusCode != 200) {
      throw Exception('Failed to save drawing');
    }
  }

  Future<void> addReview(TherapyReview review) async {
    final response = await ApiService.post('/art-therapy/add-review', review.toJson());
    if (response.statusCode != 200) {
      throw Exception('Failed to submit review: ${response.statusCode} - ${response.body}');
    }
  }
}
