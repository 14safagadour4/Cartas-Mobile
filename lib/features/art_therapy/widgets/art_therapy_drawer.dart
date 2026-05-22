import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/art_therapy_service.dart';
import '../models/art_therapy_models.dart';

class ArtTherapyDrawer extends StatefulWidget {
  const ArtTherapyDrawer({super.key});

  @override
  State<ArtTherapyDrawer> createState() => _ArtTherapyDrawerState();
}

class _ArtTherapyDrawerState extends State<ArtTherapyDrawer> {
  final ArtTherapyService _service = ArtTherapyService();
  ArtTherapist? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _service.getProfile();
      if (mounted) {
        setState(() {
          _profile = p;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textDeep = Color(0xFF4D2C34);
    const Color bordeaux = Color(0xFF6B3340);

    return Drawer(
      backgroundColor: const Color(0xFFFDFBF7),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEFE6E8))),
            ),
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: bordeaux))
              : Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5D8DA),
                        borderRadius: BorderRadius.circular(20),
                        image: _profile?.avatarUrl != null 
                          ? DecorationImage(image: NetworkImage(_profile!.avatarUrl!), fit: BoxFit.cover)
                          : null,
                      ),
                      child: _profile?.avatarUrl == null
                        ? Center(
                            child: Text(
                              '${_profile?.firstName[0] ?? ''}${_profile?.lastName[0] ?? ''}',
                              style: AppTextStyles.display(20, textDeep, weight: FontWeight.w800),
                            ),
                          )
                        : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_profile?.firstName ?? ''} ${_profile?.lastName ?? ''}',
                            style: AppTextStyles.display(18, textDeep, weight: FontWeight.w700),
                          ),
                          Text(
                            _profile?.artDiscipline ?? 'Art-thérapeute',
                            style: AppTextStyles.body(12, textDeep.withOpacity(0.6)),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFD4AF37), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '4.9 (87 avis)', // Mocked for now
                                style: AppTextStyles.body(11, textDeep.withOpacity(0.8), weight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  label: 'Tableau de bord',
                  isActive: GoRouterState.of(context).name == 'therapist-home',
                  onTap: () => context.goNamed('therapist-home'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.palette_outlined,
                  label: 'Mes Workshops',
                  isActive: GoRouterState.of(context).name == 'art-therapy-workshops',
                  onTap: () => context.pushNamed('art-therapy-workshops'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.people_outline,
                  label: 'Participants',
                  isActive: GoRouterState.of(context).name == 'art-therapy-participants',
                  onTap: () => context.pushNamed('art-therapy-participants'),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.star_outline,
                  label: 'Avis reçus',
                  onTap: () => context.pushNamed('art-therapy-reviews'),
                ),
              ],
            ),
          ),

          // Bottom Items
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  onTap: () {
                    context.pushNamed('art-therapy-profile');
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  label: 'Déconnexion',
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('accessToken');
                    await prefs.remove('refreshToken');
                    await prefs.remove('userId');
                    await prefs.remove('userRole');
                    if (context.mounted) {
                      context.goNamed('actor-choice');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    const Color bordeaux = Color(0xFF6B3340);
    const Color textDeep = Color(0xFF4D2C34);
    const Color activeBg = Color(0xFFF2ECEE);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: Icon(
          icon,
          color: isActive ? bordeaux : (iconColor ?? textDeep.withOpacity(0.7)),
          size: 22,
        ),
        title: Text(
          label,
          style: AppTextStyles.body(
            14,
            isActive ? bordeaux : (textColor ?? textDeep),
            weight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
