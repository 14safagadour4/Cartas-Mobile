import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';
import 'package:cartas/features/specialist/providers/specialist_provider.dart';
import 'package:cartas/features/notifications/widgets/notification_badge.dart';

class SpecialistMainLayout extends StatefulWidget {
  final Widget child;
  const SpecialistMainLayout({super.key, required this.child});

  @override
  State<SpecialistMainLayout> createState() => _SpecialistMainLayoutState();
}

class _SpecialistMainLayoutState extends State<SpecialistMainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpecialistProvider>().fetchProfile();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        context.goNamed('specialist-home');
        break;
      case 1:
        context.goNamed('specialist-agenda');
        break;
      case 2:
        context.goNamed('specialist-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.sage),
        title: Text(
          _currentIndex == 0
              ? 'Tableau de Bord'
              : _currentIndex == 1
                  ? 'Agenda'
                  : 'Profil',
          style: AppTextStyles.title(18, AppColors.sage),
        ),
        actions: [
          NotificationBadge(
            icon: Icons.notifications_none_outlined,
            color: AppColors.sage,
            onTap: () => context.pushNamed('notifications'),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.cream,
        child: Column(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(color: AppColors.sagePale),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/box plantes med.jpg',
                      fit: BoxFit.cover,
                      color: Colors.white.withOpacity(0.3),
                      colorBlendMode: BlendMode.dstATop,
                    ),
                  ),
                  Consumer<SpecialistProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.sage));
                      }
                      final profile = provider.profile;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              profile != null 
                                ? '${profile.title ?? "DR."} ${profile.firstName.toUpperCase()} ${profile.lastName.toUpperCase()}'
                                : 'ESPACE PROFESSIONNEL',
                              style: AppTextStyles.title(14, const Color.fromARGB(255, 4, 26, 9), weight: FontWeight.w900),
                            ),
                            Text(
                              profile?.email ?? 'CARTAS SANTÉ',
                              style: AppTextStyles.body(10, const Color.fromARGB(255, 33, 13, 36).withOpacity(0.6)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildDrawerItem(Icons.dashboard_outlined, 'Dashboard', 0,
                onTap: () => context.goNamed('specialist-home')),
            _buildDrawerItem(
                Icons.pending_actions_outlined, 'Demandes de consultations', 1,
                onTap: () => context.pushNamed('consultation-requests')),
            _buildDrawerItem(
                Icons.event_available_outlined, 'Mes Rendez-vous', 2,
                onTap: () => context.pushNamed('confirmed-appointments')),
            _buildDrawerItem(
                Icons.assignment_turned_in_outlined, 'Validation Remèdes', 3,
                onTap: () => context.pushNamed('remedy-validation')),
            const Spacer(),
            const Divider(color: Colors.black12, indent: 20, endIndent: 20),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.roseMid),
              title: Text('Déconnexion',
                  style: AppTextStyles.body(14, AppColors.roseMid)),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.sage,
          unselectedItemColor: AppColors.sage.withOpacity(0.4),
          selectedLabelStyle:
              AppTextStyles.body(10, AppColors.sage, weight: FontWeight.bold),
          unselectedLabelStyle:
              AppTextStyles.body(10, AppColors.sage.withOpacity(0.4)),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded), label: 'Accueil'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded), label: 'Agenda'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.sage, size: 22),
      title: Text(title, style: AppTextStyles.body(14, AppColors.textPrimary)),
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) onTap();
      },
    );
  }
}
