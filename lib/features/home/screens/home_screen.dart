import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cartas/core/services/auth_service.dart';

import '../widgets/module_drawer.dart';
import '../widgets/plant_card.dart';
import '../widgets/quick_action_circle.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../../notifications/widgets/notification_badge.dart';
import 'package:provider/provider.dart';
import '../../learning/providers/learning_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  bool _isSearchOpen = false;
  String _firstName = '...';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _firstName = prefs.getString('firstName') ?? '...';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    
    final lowerQuery = query.toLowerCase().trim();
    
    // 1. Redirections vers les services rapides
    if (lowerQuery.contains('consult') || lowerQuery.contains('rdv') || lowerQuery.contains('medecin')) {
      context.push('/consultation');
      return;
    }
    if (lowerQuery.contains('chat') || lowerQuery.contains('ia') || lowerQuery.contains('tawhida')) {
      context.push('/chat');
      return;
    }
    if (lowerQuery.contains('lab') || lowerQuery.contains('phyto')) {
      context.push('/phyto-lab');
      return;
    }
    if (lowerQuery.contains('art') || lowerQuery.contains('rachma') || lowerQuery.contains('dessin')) {
      context.push('/arttherapy');
      return;
    }

    // 2. Recherche dans les Modules d'Apprentissage
    final provider = context.read<LearningProvider>();
    final modules = provider.modules;
    for (var module in modules) {
      if (module.title.toLowerCase().contains(lowerQuery) || 
          module.description.toLowerCase().contains(lowerQuery)) {
        // Module trouvé ! On ferme la barre et on y va
        setState(() => _isSearchOpen = false);
        _searchController.clear();
        context.push('/module-details', extra: module);
        return;
      }
    }

    // 3. Fallback : Redirection vers l'Herbier par défaut
    setState(() => _isSearchOpen = false);
    _searchController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recherche pour "$query" : Redirection vers l\'Herbier...'),
        backgroundColor: AppColors.roseDeep,
        duration: const Duration(seconds: 2),
      ),
    );
    context.push('/herbier');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.petalCream,
      drawer: const ModuleDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildTopBar(),
                  if (_isSearchOpen) _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildDailyTipCard(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Accès rapide', showViewAll: false),
                  const SizedBox(height: 16),
                  _buildQuickAccessList(),
                  const SizedBox(height: 32),
                  _buildSectionHeader(_getRecommendedTitle(), onViewAll: () {}),
                  const SizedBox(height: 16),
                  _buildRecommendedPlants(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Services', showViewAll: false),
                  const SizedBox(height: 16),
                  _buildServicesSection(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HomeBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child:
                const Icon(Icons.menu, color: AppColors.textPrimary, size: 20),
          ),
        ),
        if (!_isSearchOpen)
          Expanded(
            child: Column(
              children: [
                Text('Marhba bik 🌿',
                    style: AppTextStyles.body(12, AppColors.textMuted,
                        weight: FontWeight.w600)),
                Text('Bonjour, $_firstName',
                    style: AppTextStyles.title(22, AppColors.roseDeep),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        Row(
          children: [
            _buildCircleIcon(Icons.search, onTap: () {
              setState(() => _isSearchOpen = !_isSearchOpen);
            }),
            const SizedBox(width: 10),
            NotificationBadge(
              icon: Icons.notifications_none_outlined,
              color: AppColors.textPrimary,
              onTap: () => context.pushNamed('notifications'),
            ),
            const SizedBox(width: 10),
            // Bouton Déconnexion (Trés important pour tes tests !)
            _buildCircleIcon(Icons.logout, onTap: () async {
              await AuthService.logout();
              if (mounted) context.go('/onboarding');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _handleSearch,
        decoration: InputDecoration(
          hintText: 'Rechercher une plante, un article...',
          hintStyle: AppTextStyles.body(12, AppColors.textDim),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: AppColors.textMuted),
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildCircleIcon(IconData icon,
      {bool hasNotification = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Stack(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            if (hasNotification)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.gold, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTipCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.rosePale,
            AppColors.petalCream.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.rose.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -5,
            child: Image.asset(
              'assets/images/femme cart.png',
              height: 196,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border,
                        color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    Text('Votre Bien-Être',
                        style: AppTextStyles.body(11, AppColors.gold,
                            weight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Conseil du jour',
                    style: AppTextStyles.title(18, AppColors.roseDeep)),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    'Commencez votre journée avec une infusion de romarin pour stimuler votre mémoire et votre énergie. 🌿',
                    style: AppTextStyles.body(
                        11, AppColors.textPrimary.withOpacity(0.7),
                        weight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title,
      {bool showViewAll = true, VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title(22, AppColors.roseDeep)),
        if (showViewAll)
          GestureDetector(
            onTap: onViewAll,
            child: Text('Voir tout',
                style: AppTextStyles.body(13, AppColors.gold,
                    weight: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _buildQuickAccessList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          QuickActionCircle(
              icon: Icons.local_florist,
              label: 'Herbier',
              color: AppColors.sage,
              onTap: () => context.push('/herbier')),
          QuickActionCircle(
              icon: Icons.spa_outlined,
              label: 'Ma Trousse',
              color: AppColors.rose,
              onTap: () => context.push('/trousse')),
          QuickActionCircle(
              icon: Icons.qr_code_scanner,
              label: 'Scanner',
              color: AppColors.gold,
              onTap: () {}),
          QuickActionCircle(
              icon: Icons.science,
              label: 'Phyto Lab',
              color: AppColors.lavande,
              onTap: () => context.push('/phyto-lab')),
          QuickActionCircle(
              icon: Icons.chat_bubble_outline,
              label: 'Chat IA',
              color: AppColors.roseVif,
              onTap: () => context.push('/chat')),
          QuickActionCircle(
              icon: Icons.palette_outlined,
              label: 'Espace Rachma',
              color: AppColors.lavandeVif,
              onTap: () => context.push('/arttherapy')),
        ],
      ),
    );
  }

  String _getRecommendedTitle() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Plantes pour bien démarrer';
    if (hour >= 12 && hour < 18) return 'Plantes pour l\'après-midi';
    return 'Plantes pour une douce nuit';
  }

  Widget _buildRecommendedPlants() {
    final hour = DateTime.now().hour;
    List<Widget> plants = [];

    // Matin (5h - 12h) : Énergie
    if (hour >= 5 && hour < 12) {
      plants = const [
        PlantCard(
          name: 'Romarin',
          arabicName: 'إكليل الجبل',
          tag: 'Énergie & Focus',
          imagePath: 'assets/images/plantes/fenouil.png', // Image existante
          tagColor: AppColors.sage,
        ),
        PlantCard(
          name: 'Menthe',
          arabicName: 'نعناع',
          tag: 'Fraîcheur Matinale',
          imagePath: 'assets/images/plantes/mint.png',
          tagColor: AppColors.sageTendre,
        ),
      ];
    } 
    // Après-midi (12h - 18h) : Digestion
    else if (hour >= 12 && hour < 18) {
      plants = const [
        PlantCard(
          name: 'Fenouil',
          arabicName: 'بسباس',
          tag: 'Digestion Légère',
          imagePath: 'assets/images/plantes/fenouil.png',
          tagColor: AppColors.sage,
        ),
        PlantCard(
          name: 'Menthe',
          arabicName: 'نعناع',
          tag: 'Après-repas',
          imagePath: 'assets/images/plantes/mint.png',
          tagColor: AppColors.sageTendre,
        ),
      ];
    } 
    // Soir/Nuit (18h - 5h) : Sommeil et Relaxation
    else {
      plants = const [
        PlantCard(
          name: 'Lavande',
          arabicName: 'الخُزامى',
          tag: 'Calme & Sommeil',
          imagePath: 'assets/images/plantes/lavande.png',
          tagColor: AppColors.lavande,
        ),
        PlantCard(
          name: 'Camomille',
          arabicName: 'بابونج',
          tag: 'Relaxation Profonde',
          imagePath: 'assets/images/plantes/fenouil.png', // Réutilisation d'image
          tagColor: AppColors.gold,
        ),
      ];
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(children: plants),
    );
  }

  Widget _buildServicesSection() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/consultation'),
            child: _buildServiceItem(
              'Consultation',
              'Spécialistes',
              Icons.medical_services_outlined,
              AppColors.rosePale,
              AppColors.roseVif,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/my-consultations'),
            child: _buildServiceItem(
              'Mes RDV',
              'Suivi des rendez-vous',
              Icons.calendar_month_outlined,
              AppColors.goldPale,
              AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(String title, String subtitle, IconData icon,
      Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body(12, AppColors.roseDeep,
                        weight: FontWeight.w700)),
                Text(subtitle,
                    style: AppTextStyles.body(9, AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
