import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../models/specialist_public_model.dart';
import '../models/consultation_model.dart';

class ConsultationProvider extends ChangeNotifier {
  List<SpecialistPublicModel> specialists = [];
  List<ConsultationModel> myConsultations = [];
  List<ConsultationModel> specialistConsultations = []; // Pour l'espace spécialiste
  bool isLoading = false;
  String? error;

  // ── Charger la liste des spécialistes actifs ──
  Future<void> fetchSpecialists() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.get('/consultations/specialists');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List;
        specialists = list.map((e) => SpecialistPublicModel.fromJson(e)).toList();
      } else {
        error = 'Impossible de charger les spécialistes.';
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  // ── Charger mes consultations ──
  Future<void> fetchMyConsultations() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.get('/consultations/my');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List;
        myConsultations = list.map((e) => ConsultationModel.fromJson(e)).toList();
      } else {
        error = 'Impossible de charger vos consultations.';
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  // ── Charger les consultations d'un spécialiste (Espace Spécialiste) ──
  Future<void> fetchSpecialistConsultations() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.get('/consultations/specialist/my');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body['data'] as List;
        specialistConsultations = list.map((e) => ConsultationModel.fromJson(e)).toList();
      } else {
        error = 'Impossible de charger vos demandes.';
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  // ── Accepter ou Refuser un rendez-vous (Espace Spécialiste) ──
  Future<bool> updateConsultationStatus(int consultationId, String newStatus) async {
    try {
      print("Updating status for $consultationId to $newStatus");
      final res = await ApiService.patch(
        '/consultations/specialist/$consultationId/status',
        {'status': newStatus},
      );
      print("Response status: ${res.statusCode}");
      print("Response body: ${res.body}");
      
      if (res.statusCode == 200) {
        await fetchSpecialistConsultations();
        return true;
      }
      error = "Erreur serveur (${res.statusCode})";
      notifyListeners();
      return false;
    } catch (e) {
      print("Error updating status: $e");
      error = "Erreur réseau : $e";
      notifyListeners();
      return false;
    }
  }

  // ── Réserver une consultation ──
  Future<bool> bookConsultation(int specialistId, String dateTime, String reason) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/consultations/book', {
        'specialistId': specialistId,
        'dateTime': dateTime,
        'reason': reason,
      });
      isLoading = false;
      notifyListeners();
      return res.statusCode == 200;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Créer un PaymentIntent Stripe (Hold) ──
  Future<Map<String, dynamic>?> createPaymentIntent(int consultationId) async {
    try {
      final res = await ApiService.post('/payments/create-intent/$consultationId', {});
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      error = "Erreur création paiement (${res.statusCode})";
      notifyListeners();
      return null;
    } catch (e) {
      error = "Erreur réseau : $e";
      notifyListeners();
      return null;
    }
  }

  // ── Confirmer le paiement (après Stripe Payment Sheet) ──
  Future<bool> confirmPayment(int consultationId) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/payments/confirm/$consultationId', {});
      if (res.statusCode == 200) {
        await fetchMyConsultations();
        isLoading = false;
        notifyListeners();
        return true;
      }
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Annuler un rendez-vous (utilisatrice) avec frais ──
  Future<Map<String, dynamic>?> cancelConsultationWithFees(int consultationId) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/payments/user-cancel/$consultationId', {});
      isLoading = false;
      if (res.statusCode == 200) {
        await fetchMyConsultations();
        notifyListeners();
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      error = "Erreur annulation (${res.statusCode})";
      notifyListeners();
      return null;
    } catch (e) {
      error = "Erreur réseau : $e";
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ── Filtrer les spécialistes localement ──
  List<SpecialistPublicModel> filtered(String? specialty, String query) {
    return specialists.where((s) {
      final matchSpecialty = specialty == null || specialty == 'Tous' ||
          (s.specialty?.toLowerCase().contains(specialty.toLowerCase()) ?? false);
      final matchQuery = query.isEmpty ||
          s.fullName.toLowerCase().contains(query.toLowerCase()) ||
          (s.specialty?.toLowerCase().contains(query.toLowerCase()) ?? false);
      return matchSpecialty && matchQuery;
    }).toList();
  }
}
