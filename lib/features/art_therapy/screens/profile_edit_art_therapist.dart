import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../services/art_therapy_service.dart';
import '../models/art_therapy_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditArtTherapist extends StatefulWidget {
  const ProfileEditArtTherapist({super.key});

  @override
  State<ProfileEditArtTherapist> createState() => _ProfileEditArtTherapistState();
}

class _ProfileEditArtTherapistState extends State<ProfileEditArtTherapist> {
  final ArtTherapyService _service = ArtTherapyService();
  final Color bordeaux = const Color(0xFF6B3340);
  final Color textDeep = const Color(0xFF4D2C34);
  final Color bgColor = const Color(0xFFFDFBF7);

  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _disciplineCtrl;
  
  bool _isLoading = true;
  ArtTherapist? _profile;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _disciplineCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final p = await _service.getProfile();
      if (mounted) {
        setState(() {
          if (p != null) {
            _profile = p;
            _nameCtrl.text = '${p.firstName} ${p.lastName}';
            _bioCtrl.text = p.bio ?? prefs.getString('bio') ?? '';
            _phoneCtrl.text = p.phone ?? prefs.getString('phone') ?? '';
            _disciplineCtrl.text = p.artDiscipline ?? prefs.getString('artDiscipline') ?? '';
          } else {
            // Fallback to local data
            final fn = prefs.getString('firstName') ?? '';
            final ln = prefs.getString('lastName') ?? '';
            _nameCtrl.text = '$fn $ln'.trim();
            _bioCtrl.text = prefs.getString('bio') ?? '';
            _phoneCtrl.text = prefs.getString('phone') ?? '';
            _disciplineCtrl.text = prefs.getString('artDiscipline') ?? '';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Fallback to local data on error
        final fn = prefs.getString('firstName') ?? '';
        final ln = prefs.getString('lastName') ?? '';
        setState(() {
          _nameCtrl.text = '$fn $ln'.trim();
          _bioCtrl.text = prefs.getString('bio') ?? '';
          _phoneCtrl.text = prefs.getString('phone') ?? '';
          _disciplineCtrl.text = prefs.getString('artDiscipline') ?? '';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF6B3340))),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B3340), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mon Profil',
          style: AppTextStyles.display(18, bordeaux, weight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Change Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5D8DA),
                        borderRadius: BorderRadius.circular(30),
                        image: _profile?.avatarUrl != null 
                          ? DecorationImage(image: NetworkImage(_profile!.avatarUrl!), fit: BoxFit.cover)
                          : null,
                        boxShadow: [
                          BoxShadow(
                            color: bordeaux.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _profile?.avatarUrl == null
                        ? Center(
                            child: Text(
                              '${_profile?.firstName.isNotEmpty == true ? _profile!.firstName[0] : ''}${_profile?.lastName.isNotEmpty == true ? _profile!.lastName[0] : ''}',
                              style: AppTextStyles.display(32, bordeaux, weight: FontWeight.w800),
                            ),
                          )
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: bordeaux,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildFieldLabel('Nom complet'),
              _buildTextField(_nameCtrl, Icons.person_outline),
              
              const SizedBox(height: 20),
              _buildFieldLabel('Discipline artistique'),
              _buildTextField(_disciplineCtrl, Icons.palette_outlined),

              const SizedBox(height: 20),
              _buildFieldLabel('Téléphone'),
              _buildTextField(_phoneCtrl, Icons.phone_outlined),

              const SizedBox(height: 20),
              _buildFieldLabel('Bio / Présentation'),
              _buildTextField(_bioCtrl, Icons.description_outlined, maxLines: 4),

              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Save to SharedPreferences for local persistence
                    final prefs = await SharedPreferences.getInstance();
                    
                    final fullName = _nameCtrl.text.trim();
                    final parts = fullName.split(' ');
                    final firstName = parts.isNotEmpty ? parts[0] : '';
                    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
                    
                    await prefs.setString('firstName', firstName);
                    await prefs.setString('lastName', lastName);
                    await prefs.setString('phone', _phoneCtrl.text.trim());
                    await prefs.setString('artDiscipline', _disciplineCtrl.text.trim());
                    await prefs.setString('bio', _bioCtrl.text.trim());
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Profil mis à jour avec succès ✅'),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bordeaux,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Enregistrer les modifications',
                    style: AppTextStyles.body(16, Colors.white, weight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: AppTextStyles.body(14, textDeep.withOpacity(0.8), weight: FontWeight.w700),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: bordeaux.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: AppTextStyles.body(14, textDeep, weight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: bordeaux.withOpacity(0.4), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
