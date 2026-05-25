import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cartas/features/profile/screens/details/favorites_screen.dart';
import 'package:cartas/features/profile/screens/details/recipes_screen.dart';
import 'package:cartas/features/profile/screens/details/history_screen.dart';
import 'package:cartas/features/profile/screens/details/badges_screen.dart';
import 'package:cartas/features/profile/screens/details/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String _firstName = 'Utilisatrice';
  String _lastName = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 1. Charger d'abord ce qu'on a en local (sauvegardé au login)
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _firstName = prefs.getString('firstName') ?? 'Utilisatrice';
        _lastName = prefs.getString('lastName') ?? '';
      });
    }
    
    // 2. Ensuite, on appelle la base de données pour rafraîchir
    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final result = await AuthService.getProfile();
      if (mounted) {
        setState(() {
          if (result['success']) {
            _userProfile = result['data'];
            _firstName = _userProfile?['firstName'] ?? _firstName;
            _lastName = _userProfile?['lastName'] ?? _lastName;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur Profile: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.rose));
    }

    return Container(
      color: AppColors.petalCream,
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchProfile,
              color: AppColors.rose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildUserInfoCard(),
                    const SizedBox(height: 24),
                    _buildTotemCard(),
                    const SizedBox(height: 24),
                    _buildMenuItems(context),
                    const SizedBox(height: 32),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.rose.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
            Text(
              'Profil',
              style: AppTextStyles.title(22, AppColors.roseDeep, weight: FontWeight.w800),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    final String fullName = '$_firstName $_lastName'.trim();
    final String initial = _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'U';
    final int xp = _userProfile?['xp'] ?? 0;
    final int favoritesCount = _userProfile?['favoritesCount'] ?? 0;
    final int recipesCount = _userProfile?['recipesCount'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.roseVif.withOpacity(0.15),
            Colors.white.withOpacity(0.9),
            AppColors.lavande.withOpacity(0.15),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTextStyles.title(32, Colors.white, weight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: AppTextStyles.title(20, AppColors.roseDeep),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Passionnée de phytothérapie ',
                style: AppTextStyles.body(13, AppColors.textMuted),
              ),
              const Text('🌿', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('$xp', 'XP', AppColors.gold),
              _buildStatItem('$favoritesCount', 'Plantes', AppColors.sageTendre),
              _buildStatItem('$recipesCount', 'Recettes', AppColors.lavandeVif),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.title(20, color, weight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.body(11, AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildTotemCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.petalCream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/plantes/romarin.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: AppColors.sage, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre plante totem',
                  style: AppTextStyles.body(11, AppColors.gold, weight: FontWeight.w700),
                ),
                Text(
                  'Romarin',
                  style: AppTextStyles.title(16, AppColors.roseDeep),
                ),
                Text(
                  'Énergie, mémoire & vitalité',
                  style: AppTextStyles.body(11, AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sageTendre.withOpacity(0.5)),
            ),
            child: const Icon(Icons.energy_savings_leaf_outlined, color: AppColors.sage, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final int favoritesCount = _userProfile?['favoritesCount'] ?? 0;
    final int recipesCount = _userProfile?['recipesCount'] ?? 0;
    final int xp = _userProfile?['xp'] ?? 0;

    return Column(
      children: [
        _buildMenuItem(
          Icons.favorite_border, 
          'Plantes favorites', 
          trailingText: '$favoritesCount',
          onTap: () => _navigateTo(context, 'favorites'),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons.history, 
          'Historique activités',
          onTap: () => _navigateTo(context, 'history'),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons.menu_book_outlined, 
          'Mes recettes', 
          trailingText: '$recipesCount',
          onTap: () => _navigateTo(context, 'recipes'),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons.star_border, 
          'Badges & XP', 
          trailingText: '$xp XP',
          onTap: () => _navigateTo(context, 'badges'),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          Icons.settings_outlined, 
          'Paramètres',
          onTap: () => _navigateTo(context, 'settings'),
        ),
      ],
    );
  }

  Future<void> _navigateTo(BuildContext context, String route) async {
    Widget screen;
    switch (route) {
      case 'favorites':
        screen = const FavoritesScreen();
        break;
      case 'history':
        screen = const HistoryScreen();
        break;
      case 'recipes':
        screen = const RecipesScreen();
        break;
      case 'badges':
        screen = const BadgesScreen();
        break;
      case 'settings':
        screen = const SettingsScreen();
        break;
      default:
        return;
    }
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result == true && mounted) {
      _fetchProfile();
    }
  }

  Widget _buildMenuItem(IconData icon, String title, {String? trailingText, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.petalCream,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.rose, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body(14, AppColors.roseDeep, weight: FontWeight.w600),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: AppTextStyles.body(13, AppColors.textMuted),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.roseDeep, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await AuthService.logout();
        if (mounted) {
          context.go('/actor-choice');
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.roseVif.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: AppColors.roseVif, size: 20),
            const SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: AppTextStyles.body(15, AppColors.roseVif, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
