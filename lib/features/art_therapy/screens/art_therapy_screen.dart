import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cartas/features/home/widgets/home_bottom_nav_bar.dart';
import 'package:cartas/features/art_therapy/widgets/workshop_details_sheet.dart';
import 'package:cartas/features/art_therapy/providers/art_therapy_provider.dart';
import 'package:cartas/features/art_therapy/models/therapy_workshop.dart';
import 'package:cartas/features/art_therapy/models/therapy_coloring.dart';
import 'package:cartas/features/art_therapy/models/therapy_review.dart';
import 'package:cartas/features/art_therapy/models/user_drawing.dart';

class ArtTherapyScreen extends StatefulWidget {
  const ArtTherapyScreen({super.key});

  @override
  State<ArtTherapyScreen> createState() => _ArtTherapyScreenState();
}

class _ArtTherapyScreenState extends State<ArtTherapyScreen> {
  int _selectedTab = 1; 
  int _selectedFilter = 0; 

  // Chemins des images de coloriage - Mettez vos fichiers dans assets/images/coloriage/
  final String _imgMandala = 'assets/images/coloriage/mandala_rose.jpg';
  final String _imgJardin = 'assets/images/coloriage/jardin_botanique.jpg';
  final String _imgZellige = 'assets/images/coloriage/zellige_floral.jpg';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ArtTherapyProvider>(context, listen: false);
      provider.fetchAllData(); // Call every time to refresh and clear errors
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream, // Or slightly lighter off-white if needed
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTabs(),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/home'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.roseDeep, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.palette_outlined, color: AppColors.roseDeep, size: 20),
            const SizedBox(width: 8),
            Text(
              'Espace Rachma',
              style: AppTextStyles.body(14, AppColors.roseDeep, weight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Art-Thérapie',
          style: AppTextStyles.title(28, AppColors.roseDeep, weight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Colorez, créez et prenez soin de vous ',
              style: AppTextStyles.body(14, AppColors.textMuted),
            ),
            const Text('🎨', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.roseDeep.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _buildTabItem(0, Icons.palette_outlined, 'Coloriage'),
          _buildTabItem(1, Icons.self_improvement_outlined, 'Workshops'),
          _buildTabItem(2, Icons.star_outline_rounded, 'Avis'),
          _buildTabItem(3, Icons.photo_library_outlined, 'Galerie'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String title) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Provider.of<ArtTherapyProvider>(context, listen: false).clearError();
          setState(() => _selectedTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.roseDeep.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.roseDeep : AppColors.textMuted.withOpacity(0.6),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: AppTextStyles.body(
                  11,
                  isSelected ? AppColors.roseDeep : AppColors.textMuted,
                  weight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<ArtTherapyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: AppColors.roseDeep),
            ),
          );
        }

        if (provider.error != null && provider.workshops.isEmpty && provider.colorings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Erreur: ${provider.error}', style: AppTextStyles.body(14, Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => provider.fetchAllData(), child: const Text('Réessayer')),
              ],
            ),
          );
        }

        if (_selectedTab == 0) {
          return _buildColoriageContent(provider.colorings);
        } else if (_selectedTab == 1) {
          return _buildWorkshopsContent(provider.workshops);
        } else if (_selectedTab == 2) {
          return _buildAvisContent(provider.reviews);
        } else {
          return _buildGalleryContent(provider.userGallery);
        }
      },
    );
  }

  Widget _buildAvisContent(List<TherapyReview> reviews) {
    double avgRating = reviews.isNotEmpty ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length : 0;
    
    return Column(
      key: const ValueKey('avis'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: AppTextStyles.title(36, AppColors.roseDeep, weight: FontWeight.w800),
                      ),
                      Row(
                        children: List.generate(5, (index) => Icon(
                          Icons.star_rounded, 
                          color: index < avgRating.round() ? AppColors.gold : AppColors.textMuted.withOpacity(0.2), 
                          size: 20,
                        )),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reviews.length} avis vérifiés',
                        style: AppTextStyles.body(12, AppColors.textMuted),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showReviewDialog(),
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('Avis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roseDeep,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined, size: 60, color: AppColors.roseDeep.withOpacity(0.1)),
                const SizedBox(height: 16),
                Text('Soyez le premier à donner votre avis !', style: AppTextStyles.body(14, AppColors.textMuted)),
              ],
            ),
          )
        else
          ...reviews.reversed.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildReviewCard(
              name: r.reviewerName,
              context: r.reviewContext,
              rating: r.rating,
              text: r.reviewText,
            ),
          )).toList(),
      ],
    );
  }

  void _showReviewDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Votre Avis', style: AppTextStyles.title(20, AppColors.roseDeep, weight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Comment s\'est passée votre séance ?', style: AppTextStyles.body(14, AppColors.textMuted)),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedRating = index + 1),
                      child: Icon(
                        index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppColors.gold,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Partagez votre expérience...',
                    hintStyle: AppTextStyles.body(13, AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.roseDeep.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: AppTextStyles.body(14, AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final name = prefs.getString('firstName') ?? 'Anonyme';
                
                final review = TherapyReview(
                  reviewerName: name,
                  reviewContext: 'Utilisateur Cartas · Aujourd\'hui',
                  rating: selectedRating,
                  reviewText: commentController.text,
                );

                if (mounted) {
                  final success = await Provider.of<ArtTherapyProvider>(context, listen: false).submitReview(review);
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Merci pour votre avis !'), backgroundColor: AppColors.sage),
                    );
                  } else if (mounted) {
                    // Show error in dialog or snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${Provider.of<ArtTherapyProvider>(context, listen: false).error}'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roseDeep,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String context,
    required int rating,
    required String text,
  }) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AppTextStyles.title(14, AppColors.roseDeep, weight: FontWeight.w700),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    color: index < rating ? AppColors.gold : AppColors.textMuted.withOpacity(0.2),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context,
            style: AppTextStyles.body(11, AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: AppTextStyles.body(13, AppColors.textDim),
          ),
        ],
      ),
    );
  }

  Widget _buildColoriageContent(List<TherapyColoring> colorings) {
    return Column(
      key: const ValueKey('coloriage'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez une maquette et suivez le guide de couleurs pour une séance apaisante.',
          style: AppTextStyles.body(13, AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        if (colorings.isEmpty)
          const Center(child: Text('Aucun coloriage pour le moment.')),
        ...colorings.map((c) {
          Color tagColor = AppColors.sageTendre;
          if (c.tagColor == 'gold') tagColor = AppColors.gold;
          if (c.tagColor == 'roseMid') tagColor = AppColors.roseMid;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildDrawingCard(
              title: c.title,
              tagText: c.difficulty,
              tagColor: tagColor,
              time: c.duration,
              imagePath: c.imagePath,
              onTap: () => context.push('/arttherapy/mood', extra: {
                'title': c.title,
                'imagePath': c.imagePath,
                'difficulty': c.difficulty,
                'duration': c.duration,
              }),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWorkshopsContent(List<TherapyWorkshop> allWorkshops) {
    List<TherapyWorkshop> filteredWorkshops = allWorkshops;
    if (_selectedFilter == 1) {
      filteredWorkshops = allWorkshops.where((w) => w.isOnline).toList();
    } else if (_selectedFilter == 2) {
      filteredWorkshops = allWorkshops.where((w) => !w.isOnline).toList();
    }

    return Column(
      key: const ValueKey('workshops'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip(0, 'Tous'),
              const SizedBox(width: 8),
              _buildFilterChip(1, '📱 En ligne'),
              const SizedBox(width: 8),
              _buildFilterChip(2, '📍 Sur place'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (filteredWorkshops.isEmpty)
          const Center(child: Text('Aucun workshop trouvé.')),
        ...filteredWorkshops.map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildWorkshopCard(
            id: w.id,
            title: w.title,
            description: w.description,
            instructor: w.instructor,
            date: w.workshopDate,
            time: w.workshopTime,
            rating: w.rating,
            places: w.places,
            price: w.price,
            isOnline: w.isOnline,
            imagePath: w.imagePath,
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.petalCream : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.rose.withOpacity(0.1) : AppColors.textMuted.withOpacity(0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.body(
            12,
            isSelected ? AppColors.roseDeep : AppColors.textMuted,
            weight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
  Widget _buildDrawingCard({
    required String title,
    required String tagText,
    required Color tagColor,
    required String time,
    required String imagePath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.spa_outlined,
                    color: AppColors.textDim,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title(16, AppColors.roseDeep, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tagText,
                          style: AppTextStyles.body(11, tagColor, weight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, color: AppColors.textMuted, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: AppTextStyles.body(11, AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: AppColors.roseDeep, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Colorier maintenant',
                        style: AppTextStyles.body(12, AppColors.roseDeep, weight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppColors.roseDeep, size: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopCard({
    required int id,
    required String title,
    required String description,
    required String instructor,
    required String date,
    required String time,
    required String rating,
    required String places,
    required String price,
    required bool isOnline,
    required String imagePath,
  }) {
    final badgeColor = isOnline ? AppColors.sagePale : AppColors.goldPale;
    final badgeTextColor = isOnline ? AppColors.sage : AppColors.goldDeep;
    final badgeText = isOnline ? 'En ligne' : 'Sur place';

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => WorkshopDetailsSheet(
            id: id,
            title: title,
            description: description,
            instructor: instructor,
            rating: rating,
            date: date,
            time: time,
            places: places,
            price: price,
            isOnline: isOnline,
            imagePath: imagePath,
          ),
        );
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.petalCream,
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    color: AppColors.roseVif,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.title(15, AppColors.roseDeep, weight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
                          style: AppTextStyles.body(10, badgeTextColor, weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    instructor,
                    style: AppTextStyles.body(12, AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: AppColors.roseDeep.withOpacity(0.5), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: AppTextStyles.body(11, AppColors.textMuted),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, color: AppColors.roseDeep.withOpacity(0.5), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: AppTextStyles.body(11, AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.gold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: AppTextStyles.body(12, AppColors.textMuted, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.group_outlined, color: AppColors.textMuted, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            places,
                            style: AppTextStyles.body(12, AppColors.textMuted),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            price,
                            style: AppTextStyles.body(14, AppColors.roseDeep, weight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryContent(List<UserDrawing> drawings) {
    if (drawings.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Icon(Icons.palette_outlined, size: 80, color: AppColors.roseDeep.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text('Aucune création pour le moment.', style: AppTextStyles.body(14, AppColors.textMuted)),
            const SizedBox(height: 8),
            Text('Commencez à colorier pour remplir votre galerie !', style: AppTextStyles.body(12, AppColors.textDim)),
          ],
        ),
      );
    }

    return Column(
      key: const ValueKey('gallery'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vos Chef-d\'œuvres (${drawings.length})',
          style: AppTextStyles.title(18, AppColors.roseDeep, weight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: drawings.length,
          itemBuilder: (context, index) {
            final d = drawings[index];
            return GestureDetector(
              onTap: () => _showGalleryActionMenu(d),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(d.templateImagePath, fit: BoxFit.cover),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                                ),
                              ),
                            ),
                            const Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(Icons.check_circle, color: AppColors.sage, size: 20),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.templateTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(13, AppColors.roseDeep, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              d.createdAt != null 
                                ? '${d.createdAt!.day}/${d.createdAt!.month}/${d.createdAt!.year}'
                                : 'Récemment',
                              style: AppTextStyles.body(10, AppColors.textDim),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  void _showGalleryActionMenu(UserDrawing d) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text(d.templateTitle, style: AppTextStyles.title(18, AppColors.roseDeep, weight: FontWeight.w800)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.sage.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.palette_outlined, color: AppColors.sage),
              ),
              title: Text('Continuer le coloriage', style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/arttherapy/coloring/interactive', extra: {
                  'title': d.templateTitle,
                  'imagePath': d.templateImagePath,
                  'difficulty': 'Reprise',
                  'duration': '-',
                  'initialDrawingJson': d.drawingDataJson,
                });
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.roseDeep.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.share_outlined, color: AppColors.roseDeep),
              ),
              title: Text('Partager', style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _showShareMenu();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showShareMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('Partager sur', style: AppTextStyles.title(18, AppColors.roseDeep, weight: FontWeight.w800)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareIcon(ctx, Icons.message, 'WhatsApp', Colors.green),
                _buildShareIcon(ctx, Icons.facebook, 'Facebook', Colors.blue),
                _buildShareIcon(ctx, Icons.camera_alt, 'Instagram', Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareIcon(BuildContext ctx, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Votre création a été partagée sur $label ! ✨'),
            backgroundColor: AppColors.sage,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.body(12, AppColors.textDim, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
