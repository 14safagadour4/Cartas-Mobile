import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:cartas/features/specialist/providers/specialist_provider.dart';
import 'package:cartas/features/specialist/models/specialist_model.dart';

class SpecialistProfileScreen extends StatefulWidget {
  const SpecialistProfileScreen({super.key});

  @override
  State<SpecialistProfileScreen> createState() => _SpecialistProfileScreenState();
}

class _SpecialistProfileScreenState extends State<SpecialistProfileScreen> {
  bool _isEditing = false;
  bool _initialized = false;
  
  // Controllers
  final _bioCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();

  @override
  void dispose() {
    _bioCtrl.dispose();
    _titleCtrl.dispose();
    _phoneCtrl.dispose();
    _rateCtrl.dispose();
    _specialtyCtrl.dispose();
    super.dispose();
  }

  void _initControllers(SpecialistModel? profile) {
    if (profile == null) return;
    _bioCtrl.text = profile.bio ?? '';
    _titleCtrl.text = profile.title ?? 'Dr.';
    _phoneCtrl.text = profile.phone ?? '';
    _rateCtrl.text = profile.rate.toString();
    _specialtyCtrl.text = profile.specialty ?? '';
    _initialized = true;
  }

  Future<void> _saveProfile() async {
    try {
      print('DEBUG: [UI] Clic sur "Enregistrer les modifications"');
      final provider = context.read<SpecialistProvider>();
      final currentProfile = provider.profile;
      
      print('DEBUG: [UI] Profil actuel chargé ? ${currentProfile != null}');

      if (currentProfile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur : Données du profil non disponibles. Réessayez plus tard.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final updated = SpecialistModel(
        firstName: currentProfile.firstName,
        lastName: currentProfile.lastName,
        email: currentProfile.email,
        bio: _bioCtrl.text,
        title: _titleCtrl.text,
        phone: _phoneCtrl.text,
        rate: double.tryParse(_rateCtrl.text) ?? 60.0,
        specialty: _specialtyCtrl.text,
      );

      print('DEBUG: [UI] Envoi des données au provider...');
      final success = await provider.updateProfile(updated);
      
      if (success) {
        if (mounted) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès ✨'),
              backgroundColor: AppColors.sage,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de la mise à jour (Erreur Serveur).'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: [UI] ERREUR FATALE dans _saveProfile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue : $e'),
            backgroundColor: Colors.black87,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialistProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;

        if (provider.isLoading && profile == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.sage));
        }

        if (!_initialized && profile != null) {
          _initControllers(profile);
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildProfileHeader(profile),
                const SizedBox(height: 30),

                if (_isEditing) ...[
                  _buildEditForm(),
                ] else ...[
                  _buildInfoCard(
                    title: 'Informations Professionnelles',
                    items: [
                      _InfoItem(label: 'Titre', value: profile?.title ?? 'Dr.', icon: Icons.badge_outlined),
                      _InfoItem(
                        label: 'Spécialité', 
                        value: (profile?.specialty != null && profile!.specialty!.isNotEmpty) 
                          ? profile.specialty! 
                          : 'Non renseignée', 
                        icon: Icons.local_florist_outlined
                      ),
                      _InfoItem(label: 'Tarif par consultation', value: '${profile?.rate ?? 0} DT', icon: Icons.payments_outlined),
                      _InfoItem(label: 'Téléphone', value: profile?.phone ?? 'Non renseigné', icon: Icons.phone_android_outlined),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    title: 'Bio & Parcours',
                    content: (profile?.bio != null && profile!.bio!.isNotEmpty) 
                      ? profile.bio! 
                      : 'Aucune bio renseignée.',
                  ),
                ],
                
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      _initControllers(profile);
                      setState(() => _isEditing = true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sage,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: provider.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Enregistrer les modifications' : 'Modifier mon Profil', 
                        style: AppTextStyles.body(16, Colors.white, weight: FontWeight.bold)),
                ),
                if (_isEditing)
                  TextButton(
                    onPressed: () => setState(() => _isEditing = false),
                    child: Text('Annuler', style: TextStyle(color: AppColors.textMuted)),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(SpecialistModel? profile) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.sageGradient,
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: Text('👩‍⚕️', style: TextStyle(fontSize: 50)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          profile != null ? '${profile.firstName} ${profile.lastName}' : 'Salma',
          style: AppTextStyles.title(22, AppColors.textPrimary),
        ),
        Text(profile?.email ?? 'Email non chargé', style: AppTextStyles.body(14, AppColors.textMuted)),
      ],
    ).animate().fadeIn().scale(delay: 100.ms);
  }

  Widget _buildEditForm() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.sage.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_titleCtrl, 'Titre (Ex: Dr., Pr.)'),
            _buildTextField(_specialtyCtrl, 'Spécialité'),
            _buildTextField(_phoneCtrl, 'Téléphone', keyboardType: TextInputType.phone),
            _buildTextField(_rateCtrl, 'Tarif Consultation (DT)', keyboardType: TextInputType.number),
            _buildTextField(_bioCtrl, 'Bio / Description', isMultiline: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isMultiline = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        maxLines: isMultiline ? 4 : 1,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
          filled: true,
          fillColor: AppColors.cream,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, List<_InfoItem>? items, String? content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title(16, AppColors.textPrimary)),
          const SizedBox(height: 15),
          if (items != null) ...items,
          if (content != null)
            Text(content, style: AppTextStyles.body(14, AppColors.textPrimary.withOpacity(0.8))),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.sage, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.body(10, AppColors.textMuted)),
              Text(value, style: AppTextStyles.body(14, AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }
}
