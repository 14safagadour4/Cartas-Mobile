import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/features/phyto_lab/providers/phyto_lab_provider.dart';

class RemedyValidationScreen extends StatefulWidget {
  const RemedyValidationScreen({super.key});

  @override
  State<RemedyValidationScreen> createState() => _RemedyValidationScreenState();
}

class _RemedyValidationScreenState extends State<RemedyValidationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PhytoLabProvider>(context, listen: false).fetchPendingRemedies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final phytoProvider = Provider.of<PhytoLabProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Validation Scientifique', style: AppTextStyles.title(18, AppColors.sage)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.sage),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: phytoProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.sage))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remèdes proposés par les utilisatrices',
                    style: AppTextStyles.body(14, AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: phytoProvider.pendingRemedies.isEmpty
                        ? const Center(child: Text("Aucun remède à valider pour le moment."))
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: phytoProvider.pendingRemedies.length,
                            itemBuilder: (context, index) {
                              final remedy = phytoProvider.pendingRemedies[index];
                              return _RemedyValidationCard(
                                title: remedy['title'] ?? 'Sans titre',
                                user: remedy['user'] != null ? "${remedy['user']['firstName']} ${remedy['user']['lastName']}" : 'Anonyme',
                                date: 'À examiner',
                                onDetails: () => _showRemedyDetails(context, remedy),
                                onValidate: () => _showValidationDialog(context, remedy),
                                onReject: () => _showRejectionDialog(context, remedy),
                              ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showRemedyDetails(BuildContext context, dynamic remedy) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFFBF7F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(remedy['title'] ?? 'Remède Personnalisé', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Colors.brown),
                        const SizedBox(width: 8),
                        Text("${remedy['user']['firstName']} ${remedy['user']['lastName']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailSection(
                      icon: Icons.auto_awesome,
                      title: "Analyse de l'IA Virtual Phyto Lab",
                      color: AppColors.sage,
                      child: Row(
                        children: [
                          const Icon(Icons.analytics_outlined, color: AppColors.sage),
                          const SizedBox(width: 12),
                          Text("Score IA : ${((remedy['aiScore'] ?? 0.0) as double).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.sage)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailSection(
                      icon: Icons.eco_outlined,
                      title: "Plantes Sélectionnées",
                      color: Colors.green[700]!,
                      child: Text(remedy['ingredients'] ?? "", style: TextStyle(fontSize: 15, color: Colors.brown[800], height: 1.5)),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailSection(
                      icon: Icons.menu_book_outlined,
                      title: "Mode de Préparation",
                      color: Colors.orange[800]!,
                      child: Text(remedy['preparation'] ?? "", style: TextStyle(fontSize: 14, color: Colors.brown[800], height: 1.5)),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.sage, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0),
                        child: const Text("Fermer l'aperçu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({required IconData icon, required String title, required Color color, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 20, color: color), const SizedBox(width: 10), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))]),
        const SizedBox(height: 12),
        Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]), child: child),
      ],
    );
  }

  void _showValidationDialog(BuildContext context, dynamic remedy) {
    final scoreController = TextEditingController(text: (remedy['aiScore'] as double).toStringAsFixed(1));
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Valider ce remède", style: TextStyle(color: AppColors.sage, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Ajustez le score de synergie si nécessaire et donnez votre feedback scientifique."),
              const SizedBox(height: 20),
              TextField(
                controller: scoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Score Expert (%)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: InputDecoration(labelText: "Feedback détaillé pour l'IA", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), hintText: "Pourquoi ce mélange est-il efficace ?"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final score = double.tryParse(scoreController.text) ?? remedy['aiScore'];
              final success = await Provider.of<PhytoLabProvider>(context, listen: false).validateRemedy(remedy['id'], score, feedbackController.text);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Remède validé avec succès ! ✅"), backgroundColor: Colors.green));
              }
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sage),
            child: const Text("Confirmer la validation", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context, dynamic remedy) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Refuser ce remède", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Veuillez expliquer pourquoi vous refusez cette analyse. Ce feedback est crucial pour améliorer le modèle."),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(labelText: "Raison du refus", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), hintText: "Contre-indication, toxicité, etc."),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("La raison est obligatoire pour le refus.")));
                return;
              }
              final success = await Provider.of<PhytoLabProvider>(context, listen: false).rejectRemedy(remedy['id'], reasonController.text);
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Remède refusé."), backgroundColor: Colors.orange));
              }
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Confirmer le refus", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }
}

class _RemedyValidationCard extends StatelessWidget {
  final String title;
  final String user;
  final String date;
  final VoidCallback onDetails;
  final VoidCallback onValidate;
  final VoidCallback onReject;

  const _RemedyValidationCard({
    required this.title, required this.user, required this.date, required this.onDetails, required this.onValidate, required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)), child: const Text('À EXAMINER', style: TextStyle(color: Color(0xFFE65100), fontSize: 10, fontWeight: FontWeight.bold))),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF3E2723))),
          const SizedBox(height: 6),
          Text('Par : $user', style: TextStyle(color: Colors.brown[300], fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onDetails,
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.sage.withOpacity(0.3)))),
                  child: const Text('Détails', style: TextStyle(color: AppColors.sage, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.red))),
                  child: const Text('Refuser', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onValidate,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.sage, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Valider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
