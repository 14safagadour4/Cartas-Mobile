import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../widgets/module_drawer.dart';
import '../widgets/plant_card.dart';
import '../widgets/quick_action_circle.dart';
import '../widgets/home_bottom_nav_bar.dart';

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
                  _buildSectionHeader('Plantes recommandées', onViewAll: () {}),
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
          Column(
            children: [
              Text('Marhba bik 🌿',
                  style: AppTextStyles.body(12, AppColors.textMuted,
                      weight: FontWeight.w600)),
              Text('Bonjour, $_firstName',
                  style: AppTextStyles.title(22, AppColors.roseDeep)),
            ],
          ),
        Row(
          children: [
            _buildCircleIcon(Icons.search, onTap: () {
              setState(() => _isSearchOpen = !_isSearchOpen);
            }),
            const SizedBox(width: 10),
            _buildCircleIcon(Icons.notifications_none_outlined,
                hasNotification: true, onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Aucune nouvelle notification 🔔')),
              );
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
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/femme_cartas.png',
                height: 180,
                fit: BoxFit.contain,
              ),
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
              onTap: () => context.push('/lab')),
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

  Widget _buildRecommendedPlants() {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: [
          PlantCard(
            name: 'Romarin',
            arabicName: 'إكليل الجبل',
            tag: 'Énergie & Mémoire',
            imagePath: 'assets/images/plantes/fenouil.png',
            tagColor: AppColors.sage,
          ),
          PlantCard(
            name: 'Lavande',
            arabicName: 'الخُزامى',
            tag: 'Calme & Sommeil',
            imagePath: 'assets/images/plantes/lavande.png',
            tagColor: AppColors.lavande,
          ),
          PlantCard(
            name: 'Menthe',
            arabicName: 'نعناع',
            tag: 'Digestion',
            imagePath: 'assets/images/plantes/mint.png',
            tagColor: AppColors.sageTendre,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Row(
      children: [
        Expanded(
          child: _buildServiceItem(
            'Consultation',
            'Spécialistes',
            Icons.medical_services_outlined,
            AppColors.rosePale,
            AppColors.roseVif,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildServiceItem(
            'Boutique',
            'Produits naturels',
            Icons.shopping_bag_outlined,
            AppColors.goldPale,
            AppColors.gold,
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
