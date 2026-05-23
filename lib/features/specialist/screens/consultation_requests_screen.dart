import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../../consultation/providers/consultation_provider.dart';
import '../../consultation/models/consultation_model.dart';
import 'package:intl/intl.dart';

class ConsultationRequestsScreen extends StatefulWidget {
  const ConsultationRequestsScreen({super.key});

  @override
  State<ConsultationRequestsScreen> createState() => _ConsultationRequestsScreenState();
}

class _ConsultationRequestsScreenState extends State<ConsultationRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationProvider>().fetchSpecialistConsultations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.sage),
        title: Text('Demandes en attente', style: AppTextStyles.title(18, AppColors.sage)),
      ),
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.sage));
          }
          final pendingRequests = provider.specialistConsultations
              .where((c) => c.status == 'PENDING')
              .toList();

          if (pendingRequests.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: pendingRequests.length,
            itemBuilder: (context, index) {
              return _buildRequestCard(pendingRequests[index], index);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: AppColors.sagePale),
          const SizedBox(height: 20),
          Text('Aucune demande en attente', style: AppTextStyles.body(16, AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ConsultationModel req, int index) {
    final dt = DateTime.tryParse(req.dateTime);
    final dateStr = dt != null ? DateFormat('dd MMM yyyy').format(dt) : req.dateTime;
    final timeStr = dt != null ? DateFormat('HH:mm').format(dt) : '';
    final name = req.patientFullName.isNotEmpty ? req.patientFullName : 'Patiente Anonyme';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.sagePale,
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: AppTextStyles.title(16, AppColors.sage)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.body(16, AppColors.textPrimary, weight: FontWeight.bold)),
                    Text('$dateStr à $timeStr', style: AppTextStyles.body(12, AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: AppColors.sagePale),
          const SizedBox(height: 10),
          Text('Motif :', style: AppTextStyles.body(12, AppColors.textMuted)),
          Text(req.report ?? 'Aucun motif', style: AppTextStyles.body(14, AppColors.textPrimary)),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRefusalDialog(req.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.roseMid),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Refuser', style: AppTextStyles.body(12, AppColors.roseMid)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptRequest(req.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sageTendre,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Accepter', style: AppTextStyles.body(12, Colors.white, weight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
  }

  Future<void> _acceptRequest(int consultationId) async {
    final provider = context.read<ConsultationProvider>();
    final success = await provider.updateConsultationStatus(consultationId, 'CONFIRMED');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation acceptée !'), backgroundColor: AppColors.sage),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${provider.error ?? "Vérifiez votre connexion ou les logs serveur."}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRefusalDialog(int consultationId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Motif du refus', style: AppTextStyles.title(18, AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Expliquez brièvement pourquoi...',
            hintStyle: AppTextStyles.body(14, AppColors.textMuted),
            filled: true,
            fillColor: AppColors.cream,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: AppTextStyles.body(14, AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              final success = await context.read<ConsultationProvider>().updateConsultationStatus(consultationId, 'REJECTED');
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demande refusée.'), backgroundColor: AppColors.roseMid),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseMid),
            child: const Text('Confirmer le refus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
