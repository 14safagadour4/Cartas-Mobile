import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/art_therapy_models.dart';

class ArtTherapyService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Emulator URL

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<ArtTherapist?> getProfile() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/art-therapists/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ArtTherapist.fromJson(data['data']);
    }
    return null;
  }

  Future<List<Workshop>> getMyWorkshops() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/workshops/my-workshops'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return [];
        return (data['data'] as List).map((w) => Workshop.fromJson(w)).toList();
      }
    } catch (e) {
      // Log simple en cas d'erreur réelle
      print('Erreur getMyWorkshops: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/workshops/stats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    return {
      'activeWorkshops': 0,
      'totalParticipants': 0,
      'averageRating': 0.0,
      'growth': '0%',
    };
  }

  Future<List<WorkshopRegistration>> getRegistrations() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/workshops/registrations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((r) => WorkshopRegistration.fromJson(r)).toList();
    }
    return [];
  }

  Future<bool> createWorkshop(Workshop w) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/workshops'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': w.title,
        'description': w.description,
        'date': w.date.toIso8601String(),
        'price': w.price,
        'maxParticipants': w.maxParticipants,
        'currentParticipants': 0,
        'status': 'UPCOMING',
      }),
    ).timeout(const Duration(seconds: 5));

    return response.statusCode == 200;
  }
  Future<bool> createWorkshopFromMap(Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/workshops'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    ).timeout(const Duration(seconds: 5));

    return response.statusCode == 200;
  }

  Future<bool> updateWorkshop(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/workshops/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur updateWorkshop: $e');
      return false;
    }
  }

  Future<bool> deleteWorkshop(int id) async {
    final token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/workshops/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode != 200) {
        print('ERREUR DELETE ${response.statusCode}: ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur deleteWorkshop: $e');
      return false;
    }
  }

  Future<List<Review>> getReviews() async {
    // Simulé pour la démo
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      Review(
        id: 1,
        userName: 'Yasmine B.',
        userInitial: 'YB',
        workshopTitle: 'Mandala & Méditation',
        rating: 5.0,
        comment: 'L\'atelier mandala m\'a vraiment aidée à gérer mon anxiété. Sihem est incroyable, douce et bienveillante. 🌸',
        date: 'il y a 2 jours',
      ),
      Review(
        id: 2,
        userName: 'Salma K.',
        userInitial: 'SK',
        workshopTitle: 'Aquarelle Botanique',
        rating: 4.0,
        comment: 'Super pédagogue ! J\'ai appris énormément sur les plantes tunisiennes. Je recommande à 100%.',
        date: 'il y a 1 semaine',
      ),
      Review(
        id: 3,
        userName: 'Mariem H.',
        userInitial: 'MH',
        workshopTitle: 'Atelier Argile & Plantes',
        rating: 4.5,
        comment: 'Très belle expérience en présentiel. Ambiance chaleureuse, juste un peu court à mon goût.',
        date: 'il y a 2 semaines',
      ),
    ];
  }
}
