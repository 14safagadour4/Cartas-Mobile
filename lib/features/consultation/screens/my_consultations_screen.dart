import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/consultation_model.dart';
import '../providers/consultation_provider.dart';

class MyConsultationsScreen extends StatefulWidget {
  const MyConsultationsScreen({super.key});

  @override
  State<MyConsultationsScreen> createState() => _MyConsultationsScreenState();
}

class _MyConsultationsScreenState extends State<MyConsultationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationProvider>().fetchMyConsultations();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      appBar: AppBar(
        backgroundColor: AppColors.petalCream,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.roseDeep),
          ),
        ),
        title: Text('Mes Rendez-vous', style: AppTextStyles.title(18, AppColors.roseDeep)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.roseDeep,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.roseDeep,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'À venir'),
            Tab(text: 'En attente'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.rose));
          }
          final upcoming = provider.myConsultations
              .where((c) => c.status == 'CONFIRMED' || c.status == 'ACCEPTED_PENDING_PAYMENT').toList();
          final pending = provider.myConsultations
              .where((c) => c.status == 'PENDING').toList();
          final history = provider.myConsultations
              .where((c) => c.status == 'COMPLETED' || c.status == 'CANCELLED' || c.status == 'REJECTED')
              .toList();

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _buildList(upcoming, 'Aucun rendez-vous confirmé', Icons.event_available_outlined),
              _buildList(pending, 'Aucune demande en attente', Icons.hourglass_empty_outlined),
              _buildList(history, 'Aucun historique', Icons.history_outlined),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/consultation'),
        backgroundColor: AppColors.roseDeep,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Nouveau RDV',
            style: AppTextStyles.body(13, Colors.white, weight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildList(List<ConsultationModel> items, String emptyMsg, IconData emptyIcon) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 56, color: AppColors.textDim),
            const SizedBox(height: 16),
            Text(emptyMsg, style: AppTextStyles.body(14, AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _ConsultationCard(consultation: items[i]),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final ConsultationModel consultation;
  const _ConsultationCard({required this.consultation});

  Color get _statusColor {
    switch (consultation.status) {
      case 'CONFIRMED': return const Color(0xFF388E3C);
      case 'ACCEPTED_PENDING_PAYMENT': return AppColors.roseDeep;
      case 'PENDING': return const Color(0xFFF57F17);
      case 'COMPLETED': return AppColors.textMuted;
      case 'CANCELLED':
      case 'REJECTED': return AppColors.roseVif;
      default: return AppColors.textMuted;
    }
  }

  Color get _statusBg {
    switch (consultation.status) {
      case 'CONFIRMED': return const Color(0xFFE8F5E9);
      case 'ACCEPTED_PENDING_PAYMENT': return AppColors.rosePale;
      case 'PENDING': return const Color(0xFFFFF8E1);
      case 'COMPLETED': return const Color(0xFFF5F5F5);
      case 'CANCELLED':
      case 'REJECTED': return const Color(0xFFFFEBEE);
      default: return const Color(0xFFF5F5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dt = _parseDate(consultation.dateTime);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.rosePale, AppColors.rose.withOpacity(0.3)],
                  ),
                ),
                child: Center(
                  child: Text(consultation.specialist?.initials ?? '?',
                      style: AppTextStyles.body(14, AppColors.roseDeep, weight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(consultation.specialist?.fullName ?? 'Spécialiste',
                        style: AppTextStyles.body(14, AppColors.roseDeep, weight: FontWeight.w700)),
                    if (consultation.specialist?.specialty != null)
                      Text(consultation.specialist!.specialty!,
                          style: AppTextStyles.body(12, AppColors.rose)),
                  ],
                ),
              ),
              // Badge statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(consultation.statusLabel,
                    style: AppTextStyles.body(11, _statusColor, weight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date et heure
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.petalCream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text(dt, style: AppTextStyles.body(12, AppColors.textPrimary, weight: FontWeight.w600)),
              ],
            ),
          ),
          // Motif
          if (consultation.report != null && consultation.report!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Motif : ${consultation.report}',
                style: AppTextStyles.body(12, AppColors.textMuted),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          // Actions selon le statut
          if (consultation.status == 'CONFIRMED') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (consultation.videoLink != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(consultation.videoLink!),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.videocam_outlined, size: 16),
                      label: const Text('Rejoindre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roseDeep,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (consultation.videoLink != null) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelWarning(context),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Annuler'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.roseDeep,
                      side: const BorderSide(color: AppColors.roseDeep),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // Bouton Paiement si accepté
          if (consultation.status == 'ACCEPTED_PENDING_PAYMENT') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/consultation/payment', extra: consultation),
                icon: const Icon(Icons.payment_outlined, size: 16),
                label: const Text('Payer pour confirmer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseDeep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Text('Annulation', style: AppTextStyles.title(18, AppColors.roseDeep)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Êtes-vous sûr(e) de vouloir annuler ce rendez-vous ?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Des frais d\'annulation de 10 DT seront retenus sur votre remboursement.',
                      style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette mesure protège le temps réservé par nos spécialistes.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retour', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await context.read<ConsultationProvider>().cancelConsultationWithFees(consultation.id);
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rendez-vous annulé. Remboursement : ${result['refundAmount']} DT'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.roseDeep,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirmer l\'annulation', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _parseDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}
