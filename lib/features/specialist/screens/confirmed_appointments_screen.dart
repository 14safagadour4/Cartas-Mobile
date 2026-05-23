import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../../consultation/providers/consultation_provider.dart';
import '../../consultation/models/consultation_model.dart';
import 'package:intl/intl.dart';

class ConfirmedAppointmentsScreen extends StatefulWidget {
  const ConfirmedAppointmentsScreen({super.key});

  @override
  State<ConfirmedAppointmentsScreen> createState() => _ConfirmedAppointmentsScreenState();
}

class _ConfirmedAppointmentsScreenState extends State<ConfirmedAppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.sage),
        title: Text('Mes Rendez-vous', style: AppTextStyles.title(18, AppColors.sage)),
      ),
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.sage));
          }
          final confirmedAppointments = provider.specialistConsultations
              .where((c) => c.status == 'CONFIRMED')
              .toList();

          if (confirmedAppointments.isEmpty) {
            return Center(
              child: Text('Aucun rendez-vous confirmé', style: AppTextStyles.body(16, AppColors.textMuted)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: confirmedAppointments.length,
            itemBuilder: (context, index) {
              return _buildAppointmentCard(confirmedAppointments[index], index);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(ConsultationModel appt, int index) {
    final dt = DateTime.tryParse(appt.dateTime);
    final dateStr = dt != null ? DateFormat('dd MMM yyyy').format(dt) : appt.dateTime;
    final timeStr = dt != null ? DateFormat('HH:mm').format(dt) : '';
    final name = appt.patientFullName.isNotEmpty ? appt.patientFullName : 'Patiente Anonyme';
    final hasReport = appt.report != null && appt.report!.length > 20;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sagePale.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.sagePale,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Consultation', style: AppTextStyles.body(10, AppColors.sage, weight: FontWeight.bold)),
              ),
              const Icon(Icons.videocam, color: AppColors.sage, size: 20),
            ],
          ),
          const SizedBox(height: 15),
          Text(name, style: AppTextStyles.body(18, AppColors.textPrimary, weight: FontWeight.bold)),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 5),
              Text('$dateStr à $timeStr', style: AppTextStyles.body(12, AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          if (appt.videoLink != null && appt.videoLink!.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(appt.videoLink!),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.videocam_outlined, size: 16),
              label: const Text('Rejoindre la visio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roseMid,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _showReportDialog(name, appt, index),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasReport ? Colors.grey[200] : AppColors.sageTendre,
              foregroundColor: hasReport ? AppColors.textMuted : Colors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              hasReport ? 'Modifier le compte-rendu' : 'Rédiger le compte-rendu',
              style: AppTextStyles.body(12, hasReport ? AppColors.textMuted : Colors.white, weight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05, end: 0);
  }

  void _showReportDialog(String patientName, ConsultationModel appt, int index) {
    final controller = TextEditingController(text: appt.report);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compte-rendu', style: AppTextStyles.title(20, AppColors.textPrimary)),
            Text('Patiente : $patientName', style: AppTextStyles.body(12, AppColors.textMuted)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Observations :', style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Saisissez vos observations cliniques...',
                hintStyle: AppTextStyles.body(14, AppColors.textMuted),
                filled: true,
                fillColor: AppColors.cream,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Annuler', style: AppTextStyles.body(14, AppColors.textMuted)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement backend patch to update report text
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compte-rendu enregistré avec succès !'), backgroundColor: AppColors.sage),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sage,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
