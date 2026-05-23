import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Aide & FAQ', style: AppTextStyles.title(20, AppColors.roseDeep)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFaqItem('Comment identifier une plante ?', 'Utilisez le bouton scanner au centre du menu pour prendre une photo de la feuille.'),
          _buildFaqItem('Où trouver mes recettes ?', 'Toutes vos recettes enregistrées se trouvent dans votre profil sous la section "Mes recettes".'),
          _buildFaqItem('Comment gagner des XP ?', 'Identifiez des plantes, complétez des quiz et lisez des articles pour augmenter votre niveau !'),
          const SizedBox(height: 32),
          _buildContactButton(),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(question, style: AppTextStyles.body(14, AppColors.roseDeep, weight: FontWeight.w700)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: AppTextStyles.body(13, AppColors.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.rose.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Besoin de plus d\'aide ?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.roseDeep)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
            child: const Text('Nous contacter'),
          ),
        ],
      ),
    );
  }
}
