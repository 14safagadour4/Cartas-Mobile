import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/features/profile/screens/details/edit_profile_screen.dart';
import 'package:cartas/features/profile/screens/details/change_password_screen.dart';
import 'package:cartas/features/profile/screens/details/notifications_settings_screen.dart';
import 'package:cartas/features/profile/screens/details/language_settings_screen.dart';
import 'package:cartas/features/profile/screens/details/help_faq_screen.dart';
import 'package:cartas/features/profile/screens/details/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        title: Text(
          'Paramètres',
          style: AppTextStyles.title(20, AppColors.roseDeep),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Compte'),
            _buildSettingItem(
              Icons.person_outline, 
              'Modifier le profil', 
              'Nom, email, téléphone',
              onTap: () async {
                final result = await Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const EditProfileScreen())
                );
                if (result == true && context.mounted) {
                  // Si le profil a été modifié, on informe l'écran précédent (ProfileScreen)
                  Navigator.pop(context, true);
                }
              },
            ),
            _buildSettingItem(
              Icons.lock_outline, 
              'Sécurité', 
              'Changer le mot de passe',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen())),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Préférences'),
            _buildSettingItem(
              Icons.notifications_none, 
              'Notifications', 
              'Alertes et rappels',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsSettingsScreen())),
            ),
            _buildSettingItem(
              Icons.language_outlined, 
              'Langue', 
              'Français',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageSettingsScreen())),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Support'),
            _buildSettingItem(
              Icons.help_outline, 
              'Aide & FAQ', 
              '',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpFaqScreen())),
            ),
            _buildSettingItem(
              Icons.info_outline, 
              'À propos', 
              'Version 1.0.0',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.body(14, AppColors.gold, weight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.petalCream,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.rose, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body(15, AppColors.roseDeep, weight: FontWeight.w600),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTextStyles.body(12, AppColors.textMuted),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ],
      ),
    ),
    );
  }
}
