import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../models/learning_models.dart';
import '../providers/learning_provider.dart';

class LearningHomeScreen extends StatefulWidget {
  const LearningHomeScreen({super.key});

  @override
  State<LearningHomeScreen> createState() => _LearningHomeScreenState();
}

class _LearningHomeScreenState extends State<LearningHomeScreen> {
  String _selectedType = 'ALL';

  final List<Map<String, String>> _contentTypes = [
    {'id': 'ALL', 'label': 'Tous', 'icon': '🌟'},
    {'id': 'ARTICLE', 'label': 'Articles', 'icon': '📄'},
    {'id': 'VIDEO', 'label': 'Vidéos', 'icon': '🎬'},
    {'id': 'PODCAST', 'label': 'Podcasts', 'icon': '🎙️'},
    {'id': 'EXERCISE', 'label': 'Exercices', 'icon': '🧘'},
  ];
  // --- NOUVELLE PALETTE INSPIRÉE DE L'IMAGE 2 ---
  final Color titlePurple =
      const Color.fromARGB(255, 118, 79, 126); // Purple doux / Aubergine
  final Color subtitleMauve = const Color.fromARGB(
      255, 166, 127, 182); // Mauve/Pink doux pour les descriptions
  final Color goldProgress = const Color.fromARGB(
      255, 238, 210, 158); // Beige Gold pour la barre de progression
  final Color lightPinkBg =
      const Color(0xFFFEF3F5); // Fond rose très clair pour les tags
  final Color lightGreenBg = const Color.fromARGB(
      255, 194, 233, 167); // Fond vert très clair pour Maman-Enfant

  @override
  void initState() {
    super.initState();
    // Charger les points depuis la BD au démarrage de cet écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().initializePoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5), // Beige cream très doux global
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: titlePurple),
          onPressed: () {
            if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
              Scaffold.of(context).openDrawer();
            } else {
              context.pop();
            }
          },
        ),
        title:
            Text('Forum éducatif', style: AppTextStyles.title(20, titlePurple)),
        actions: [
          Consumer<LearningProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: lightPinkBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: titlePurple.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.earnedPoints} pts',
                          style: TextStyle(
                            color: titlePurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: lightGreenBg,
              child: Icon(Icons.person, size: 20, color: AppColors.sageTendre),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 20),
            _buildQuetesApprentissage(),
            const SizedBox(height: 40),
            _buildMamanEnfantSection(),
            const SizedBox(height: 40),
            _buildQuizzesSection(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -40,
          top: -20,
          child: Opacity(
            opacity: 0.9, // Plus transparent pour un effet "Watermark"
            child: Image.asset(
              'assets/images/histoires.png',
              width: 280, // Plus grand pour toucher les bords
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.spa, size: 200, color: subtitleMauve),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lightPinkBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('LEARNING MODULES',
                    style: TextStyle(
                      fontSize: 9,
                      color: titlePurple,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    )),
              ),
              const SizedBox(height: 16),
              Text(
                'Cultivez votre\nsagesse ancestrale.',
                style:
                    AppTextStyles.title(34, titlePurple).copyWith(height: 1.1),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  'Découvrez les secrets de la terre tunisienne à travers nos modules interactifs conçus pour toute la famille.',
                  style: TextStyle(
                      fontSize: 14, color: subtitleMauve, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuetesApprentissage() {
    final provider = context.watch<LearningProvider>();
    final modules = provider.getFilteredModules(_selectedType);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quêtes d\'Apprentissage',
                  style: AppTextStyles.title(22, titlePurple)),
              const SizedBox(height: 4),
              Text('Explorez selon vos envies',
                  style: TextStyle(fontSize: 14, color: subtitleMauve)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // --- BARRE DE CATÉGORIES TYPES ---
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _contentTypes.length,
            itemBuilder: (context, index) {
              final type = _contentTypes[index];
              final isSelected = _selectedType == type['id'];
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Row(
                    children: [
                      Text(type['icon']!),
                      const SizedBox(width: 6),
                      Text(type['label']!),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: titlePurple.withOpacity(0.2),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? titlePurple : subtitleMauve,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? titlePurple : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type['id']!;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
        SizedBox(
          height: 260,
          child: modules.isEmpty 
            ? Center(
                child: Text('Aucun contenu de ce type pour le moment',
                  style: TextStyle(color: subtitleMauve, fontSize: 13, fontStyle: FontStyle.italic)),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  return _buildModuleCard(context, modules[index]);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, LearningModule module) {
    final provider = context.watch<LearningProvider>();
    // Dynamic Progress
    final double dynamicProgress = provider.calculateModuleProgress(module.id, module.totalLessons);

    final category = provider.categories.firstWhere(
        (c) => c.id == module.categoryId,
        orElse: () => provider.categories.first);

    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors
            .white, // Fond blanc pur pour bien faire ressortir les couleurs
        borderRadius: BorderRadius.circular(
            20), // Angles un peu plus carrés comme l'image 2
        border: Border.all(
            color: const Color(0xFFF0EBE6), width: 1), // Bordure légère beige
        boxShadow: [
          BoxShadow(
            color: titlePurple.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: lightPinkBg,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    module.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.account_balance, color: AppColors.sageTendre, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(module.title,
                    style: AppTextStyles.body(15, titlePurple,
                        weight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(module.description,
              style: TextStyle(fontSize: 12, color: subtitleMauve, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, size: 12, color: subtitleMauve),
                      const SizedBox(width: 4),
                      Text('${module.totalLessons} leçons',
                          style: TextStyle(fontSize: 11, color: subtitleMauve)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: subtitleMauve),
                      const SizedBox(width: 4),
                      Text(module.duration,
                          style: TextStyle(fontSize: 11, color: subtitleMauve)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: dynamicProgress == 0.0
                    ? 0.05
                    : dynamicProgress, // Montrer un bout si 0
                backgroundColor:
                    const Color(0xFFF3EDE8), // Fond beige de la barre
                valueColor: AlwaysStoppedAnimation<Color>(
                    goldProgress), // Ligne Or/Bronze
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40, // Bouton plus fin
            child: ElevatedButton(
              onPressed: () {
                context.push('/module-details', extra: module);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: titlePurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Start Lesson',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMamanEnfantSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc/clair au lieu du vert solide
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0EBE6), width: 1), // Petite bordure élégante
        boxShadow: [
          BoxShadow(
            color: titlePurple.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias, // Pour que l'image respecte les bords arrondis
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.25, // Effet Watermark (un peu visible, pas trop fort)
              child: Image.asset(
                'assets/images/maman-enfant.png',
                fit: BoxFit.cover, // Couvre tout le fond
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ESPACE MAMAN-ENFANT',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.sage,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Text('Moments de\nPartage\nInteractifs',
                    style:
                        AppTextStyles.title(24, titlePurple).copyWith(height: 1.15)),
                const SizedBox(height: 16),
                Text(
                    'Transmettez le savoir à vos enfants à travers le jeu et l\'émerveillement.',
                    style:
                        TextStyle(fontSize: 13, color: subtitleMauve, height: 1.4)),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.push('/maman-enfant-story'),
                  child: _buildActivityRow(Icons.menu_book_rounded, 'Conte Botanique',
                      'Graine de Jasmin', lightPinkBg),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push('/maman-enfant-story'),
                  child: _buildActivityRow(Icons.restaurant, 'Atelier Recette',
                      'Infusion magique', const Color(0xFFFDF7E5)),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.push('/maman-enfant-recipe'),
                  child: _buildActivityRow(Icons.auto_awesome, 'Atelier Créatif',
                      'Ma recette magique', const Color(0xFFE8F2E2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
      IconData icon, String title, String subtitle, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: titlePurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body(14, titlePurple,
                        weight: FontWeight.w700)),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: subtitleMauve)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuizzesSection() {
    final quizzes = LearningMockData.interactiveQuizzes; // Pour l'instant on garde le mock car c'est une liste à part
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Interactive Quizzes',
                  style: AppTextStyles.title(22, titlePurple)),
              Text('Tout voir',
                  style: TextStyle(
                      fontSize: 12,
                      color: titlePurple,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 130,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return _buildQuizCard(
                context, 
                quiz.title, 
                quiz.subtitle,
                quiz.baseColor, 
                index % 2 == 0 ? Icons.local_florist_outlined : Icons.psychology_outlined, 
                quiz
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuizCard(
      BuildContext context, String title, String subtitle, Color bgColor, IconData icon, Quiz? attachedQuiz) {
    return GestureDetector(
      onTap: () {
        if (attachedQuiz != null) {
          context.push('/quiz', extra: attachedQuiz);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bientôt disponible !')));
        }
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: titlePurple, size: 24),
          ),
          const Spacer(),
          Text(title,
              style:
                  AppTextStyles.body(13, titlePurple, weight: FontWeight.w700)
                      .copyWith(height: 1.2)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: subtitleMauve)),
        ],
      ),
    ));
  }
}
