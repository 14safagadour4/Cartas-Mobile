import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';

class MyRemediesScreen extends StatefulWidget {
  const MyRemediesScreen({super.key});

  @override
  State<MyRemediesScreen> createState() => _MyRemediesScreenState();
}

class _MyRemediesScreenState extends State<MyRemediesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PhytoLabProvider>(context, listen: false).fetchMyRemedies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final phytoProvider = Provider.of<PhytoLabProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F2),
      appBar: AppBar(
        title: const Text('Mes Remèdes Perso', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4E342E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: phytoProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.sage))
          : phytoProvider.myRemedies.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: phytoProvider.myRemedies.length,
                  itemBuilder: (context, index) {
                    final remedy = phytoProvider.myRemedies[index];
                    return _RemedyUserCard(remedy: remedy)
                        .animate()
                        .fadeIn(delay: (index * 100).ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text("Vous n'avez pas encore de remèdes.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sage, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: const Text("Créer mon premier remède", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _RemedyUserCard extends StatelessWidget {
  final dynamic remedy;

  const _RemedyUserCard({required this.remedy});

  @override
  Widget build(BuildContext context) {
    final status = remedy['status'] as String;
    final isPending = status == 'PENDING';
    final isValidated = status == 'VALIDATED';
    final isRejected = status == 'REJECTED';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          // Header with Status
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(status),
                    Text(
                      remedy['createdAt'] != null ? "Créé le ${remedy['createdAt'].toString().substring(0, 10)}" : "",
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(remedy['title'] ?? 'Mon Remède', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                const SizedBox(height: 5),
                Text(remedy['ingredients'] ?? "", style: TextStyle(color: Colors.brown[300], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),

          // Comparison Section (AI vs Expert)
          if (!isPending)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isValidated ? AppColors.sage.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreColumn("Analyse IA", "${(remedy['aiScore'] as double).toStringAsFixed(1)}%", Icons.auto_awesome, AppColors.sage),
                      const Icon(Icons.compare_arrows, color: Colors.grey),
                      _buildScoreColumn(
                        isValidated ? "Validation Expert" : "Décision Expert",
                        isValidated ? "${(remedy['specialistScore'] as double).toStringAsFixed(1)}%" : "Refusé",
                        isValidated ? Icons.verified_user_outlined : Icons.report_gmailerrorred_outlined,
                        isValidated ? AppColors.sage : Colors.red,
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  if (isValidated && remedy['specialistFeedback'] != null) ...[
                    const Text("💡 Note de l'expert :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.sage)),
                    const SizedBox(height: 8),
                    Text(remedy['specialistFeedback'], style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4, fontStyle: FontStyle.italic)),
                  ],
                  if (isRejected && remedy['rejectionReason'] != null) ...[
                    const Text("⚠️ Raison du refus :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                    const SizedBox(height: 8),
                    Text(remedy['rejectionReason'], style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4)),
                  ],
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.05), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text("En attente de validation par l'expert...", style: TextStyle(color: Colors.orange[800], fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    String text = "EN ATTENTE";
    if (status == 'VALIDATED') {
      color = AppColors.sage;
      text = "VALIDÉ";
    } else if (status == 'REJECTED') {
      color = Colors.red;
      text = "REFUSÉ";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildScoreColumn(String label, String score, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(score, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
