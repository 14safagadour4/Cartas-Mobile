import 'specialist_public_model.dart';

class ConsultationModel {
  final int id;
  final SpecialistPublicModel? specialist; // can be null if parsing from specialist perspective where they don't need their own details
  final String? patientFirstName;
  final String? patientLastName;
  final String dateTime;
  final String status;
  final String? report;
  final String? videoLink;
  final String? paymentId;
  final String? createdAt;

  ConsultationModel({
    required this.id,
    this.specialist,
    this.patientFirstName,
    this.patientLastName,
    required this.dateTime,
    required this.status,
    this.report,
    this.videoLink,
    this.paymentId,
    this.createdAt,
  });

  String get statusLabel {
    switch (status) {
      case 'PENDING': return 'En attente';
      case 'ACCEPTED_PENDING_PAYMENT': return 'Accepté (Paiement Requis)';
      case 'CONFIRMED': return 'Confirmé';
      case 'REJECTED': return 'Refusé';
      case 'COMPLETED': return 'Terminé';
      case 'CANCELLED': return 'Annulé';
      default: return status;
    }
  }

  String get patientFullName => '${patientFirstName ?? ''} ${patientLastName ?? ''}'.trim();

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id: json['id'] as int,
      specialist: json['specialist'] != null ? SpecialistPublicModel.fromJson(json['specialist'] as Map<String, dynamic>) : null,
      patientFirstName: json['user']?['firstName'],
      patientLastName: json['user']?['lastName'],
      dateTime: json['dateTime'] ?? '',
      status: json['status'] ?? 'PENDING',
      report: json['report'],
      videoLink: json['videoLink'],
      paymentId: json['paymentId'],
      createdAt: json['createdAt'],
    );
  }
}
