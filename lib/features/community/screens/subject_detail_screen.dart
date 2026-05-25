import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/features/community/screens/article_detail_screen.dart';
import 'post_detail_screen.dart';
import 'category_tips_screen.dart';
import 'create_post_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final String subjectId; // 1, 2, 3, 4

  const SubjectDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.subjectId,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  String _selectedFilter = 'Tous';

  final List<Map<String, dynamic>> _allPosts = [
    {'author': 'Olivia', 'avatar': 'olivia', 'title': 'Comment prendre soin des rosiers en hiver ? 🌹', 'time': 'Il y a 2h', 'tag': 'Plantes'},
    {'author': 'Yasmine', 'avatar': 'yasmine', 'title': 'Quel engrais naturel utilisez-vous ? 🌿', 'time': 'Hier à 18:45', 'tag': 'Sol & Engrais'},
    {'author': 'Ahmed', 'avatar': 'mahdi', 'title': 'Astuces contre les pucerons 🐛', 'time': 'Hier à 12:30', 'tag': 'Parasites'},
    {'author': 'Lina', 'avatar': 'yasmine', 'title': 'Comment améliorer la floraison ? 🌼', 'time': 'Il y a 2 jours', 'tag': 'Fleurs'},
    {'author': 'Omrane', 'avatar': 'omrane', 'title': 'Mon premier potager urbain ! 🍅', 'time': 'Il y a 3 jours', 'tag': 'Potager'},
    {'author': 'Rim', 'avatar': 'yasmine', 'title': 'Besoin d\'aide pour mon bonsaï 🌳', 'time': 'Lundi dernier', 'tag': 'Entretien'},
    {'author': 'Samir', 'avatar': 'mahdi', 'title': 'Les secrets d\'un gazon parfait ✨', 'time': 'Il y a 1h', 'tag': 'Aménagement'},
    {'author': 'Sara', 'avatar': 'olivia', 'title': 'Plantes d\'intérieur faciles 🪴', 'time': 'Récemment', 'tag': 'Plantes'},
    {'author': 'Ala', 'avatar': 'ala', 'title': 'Atelier taille de fruitiers ✂️', 'time': 'Mardi', 'tag': 'Ateliers'},
    {'author': 'Aya', 'avatar': 'aya', 'title': 'Rencontre entre passionnés 🤝', 'time': 'Mercredi', 'tag': 'Rencontres'},
    {'author': 'Dali', 'avatar': 'dali', 'title': 'Fête des plantes au parc 🌸', 'time': 'Demain', 'tag': 'Fêtes des plantes'},
    {'author': 'Malek', 'avatar': 'malek', 'title': 'Maladies courantes du buis 🍂', 'time': 'Jeudi', 'tag': 'Maladies'},
  ];

  List<Map<String, dynamic>> get _filteredPosts {
    if (_selectedFilter == 'Tous') return _allPosts;
    return _allPosts.where((post) => post['tag'] == _selectedFilter).toList();
  }

  List<String> get _filters {
    switch (widget.subjectId) {
      case '1': return ['Tous', 'Plantes', 'Entretien', 'Sol & Engrais', 'Parasites', 'Saisons'];
      case '2': return ['Tous', 'Aménagement', 'Fleurs', 'Potager', 'Plantes', 'Balcon & Terrasse'];
      case '3': return ['Tous', 'Ateliers', 'Rencontres', 'Fêtes des plantes', 'Visites de jardins', 'Autres'];
      case '4': return ['Tous', 'Plantes', 'Maladies', 'Entretien', 'Sol & Engrais', 'Autres'];
      default: return ['Tous'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                if (widget.subjectId == '3') _buildUpcomingEvents(),
                _buildListHeader(),
                _buildPublicationsList(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen(subjectTitle: widget.title)),
          );
          
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _allPosts.insert(0, result);
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Publication partagée !'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.sage),
              );
            }
          }
        },
        backgroundColor: const Color(0xFF5D243B),
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: Text(
          widget.subjectId == '4' ? 'Poser une question' : 'Créer un post',
          style: AppTextStyles.body(14, Colors.white, weight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFFFDF8F5),
      elevation: 0,
      pinned: true,
      centerTitle: false,
      title: Text(widget.title, style: AppTextStyles.title(18, AppColors.roseDeep)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.roseDeep),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<CommunityProvider>(
          builder: (context, provider, child) => Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _showNotifications(context, provider),
                  child: Stack(
                    children: [
                      const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 28),
                      if (provider.notificationCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              '${provider.notificationCount}',
                              style: AppTextStyles.body(10, Colors.white, weight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage('assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher da...',
                  hintStyle: AppTextStyles.body(14, AppColors.textMuted),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePostScreen(subjectTitle: widget.title)),
              );
              
              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  _allPosts.insert(0, result);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Publication partagée !'), behavior: SnackBarBehavior.floating),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF5D243B), // Deep berry/rose
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF5D243B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Text(
                widget.subjectId == '4' ? '+ Question' : '+ Publier',
                style: AppTextStyles.body(14, Colors.white, weight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: _filters.map((filter) => _buildFilterChip(filter, isSelected: _selectedFilter == filter)).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = label);
        if (label != 'Tous') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryTipsScreen(
                category: label,
                icon: _getFilterIconData(label),
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.roseDeep : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
        ),
        child: Row(
          children: [
            if (label != 'Tous') ...[
              _getFilterIcon(label),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.body(12, isSelected ? Colors.white : AppColors.textPrimary, weight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFilterIcon(String label) {
    return Icon(_getFilterIconData(label), size: 14, color: _selectedFilter == label ? Colors.white : AppColors.textPrimary);
  }

  IconData _getFilterIconData(String label) {
    switch (label) {
      case 'Plantes': return Icons.eco_outlined;
      case 'Entretien': return Icons.opacity_rounded;
      case 'Sol & Engrais': return Icons.landscape_outlined;
      case 'Parasites': return Icons.bug_report_outlined;
      case 'Aménagement': return Icons.architecture_rounded;
      case 'Fleurs': return Icons.local_florist_outlined;
      case 'Potager': return Icons.bakery_dining_rounded;
      case 'Ateliers': return Icons.work_outline_rounded;
      case 'Rencontres': return Icons.people_outline_rounded;
      case 'Maladies': return Icons.coronavirus_outlined;
      default: return Icons.label_outline;
    }
  }

  Widget _buildFeaturedSection() {
    String featuredTitle = '';
    String imagePath = '';
    String badgeText = widget.subjectId == '1' ? 'Épinglé' : widget.subjectId == '4' ? 'Populaire' : 'À la une';

    switch (widget.subjectId) {
      case '1':
        featuredTitle = 'Bien débuter son jardin 🌱';
        imagePath = 'assets/images/sujet populaire/sujet 1-1.png';
        break;
      case '2':
        featuredTitle = 'Aménager un petit jardin avec style 🌿';
        imagePath = 'assets/images/sujet populaire/sujet 2-1.png';
        break;
      case '3':
        return _buildFeaturedEvent();
      case '4':
        return _buildFeaturedQuestion();
      default:
        return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(
              title: featuredTitle,
              imagePath: imagePath,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Hero(
                      tag: 'article_image',
                      child: Image.asset(
                        imagePath, 
                        height: 160, 
                        width: double.infinity, 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(widget.subjectId == '1' ? Icons.push_pin_rounded : Icons.local_fire_department_rounded, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(badgeText, style: AppTextStyles.body(10, Colors.white, weight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(featuredTitle, style: AppTextStyles.title(15, AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              for (int i = 0; i < 4; i++)
                                Align(
                                  widthFactor: 0.7,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: AssetImage('assets/images/forom cumm/${i == 0 ? "olivia" : i == 1 ? "mahdi" : i == 2 ? "yasmine" : "ahmed"}.jpg'),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Text('+87', style: AppTextStyles.body(10, AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Text('52 réponses', style: AppTextStyles.body(10, AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedEvent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🔥 Événement à la une', style: AppTextStyles.title(16, AppColors.roseDeep)),
              Text('Voir tout', style: AppTextStyles.body(12, AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.asset(
                    'assets/images/sujet populaire/sujet 3-1.png', 
                    height: 180, 
                    width: double.infinity, 
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Grande Bourse aux Plantes d\'Automne 🌿', style: AppTextStyles.title(15, AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              for (int i = 0; i < 3; i++)
                                Align(
                                  widthFactor: 0.7,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: AssetImage('assets/images/forom cumm/${i == 0 ? "mahdi" : i == 1 ? "olivia" : "yasmine"}.jpg'),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Text('+142', style: AppTextStyles.body(10, AppColors.textMuted)),
                            ],
                          ),
                          Text('24 participants', style: AppTextStyles.body(10, AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedQuestion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('❓ Questions populaires', style: AppTextStyles.title(16, AppColors.roseDeep)),
              Text('Voir tout', style: AppTextStyles.body(12, AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/sujet populaire/sujet 4-1.png', 
                        width: 120, 
                        height: 120, 
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 10),
                            const SizedBox(width: 4),
                            Text('Populaire', style: AppTextStyles.body(9, Colors.white, weight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yasmine 🌹', style: AppTextStyles.title(12, AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text('Pourquoi mes rosiers perdent leurs feuilles ? 🌿', style: AppTextStyles.title(14, AppColors.textPrimary), maxLines: 3, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.forum_outlined, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text('12 réponses', style: AppTextStyles.body(10, AppColors.textMuted)),
                            ],
                          ),
                          Text('Il y a 2h', style: AppTextStyles.body(10, AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Événements à venir', style: AppTextStyles.title(16, AppColors.roseDeep)),
              Text('Voir tout', style: AppTextStyles.body(12, AppColors.textMuted)),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              _buildEventCard('Atelier : Plantes aromatiques', '18 MAI', '10:00 – 12:00', 'Jardin Partagé La Marsa', 'Atelier'),
              _buildEventCard('Atelier rempotage pour débutants', '22 MAI', '14:00 – 16:00', 'Green Center', 'Atelier'),
              _buildEventCard('Visite guidée : Jardins secrets', '01 JUIN', '09:30 – 12:30', 'Le Belvédère, Tunis', 'Visite'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(String title, String date, String time, String location, String type) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.petalCream.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
            child: Text(type, style: AppTextStyles.body(9, AppColors.roseDeep, weight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text(date.split(' ')[0], style: AppTextStyles.title(18, AppColors.textPrimary)),
                  Text(date.split(' ')[1], style: AppTextStyles.body(10, AppColors.roseDeep, weight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppTextStyles.title(13, AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(time, style: AppTextStyles.body(10, AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(child: Text(location, style: AppTextStyles.body(10, AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < 3; i++)
                Align(
                  widthFactor: 0.7,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundImage: AssetImage('assets/images/forom cumm/${i == 0 ? "olivia" : i == 1 ? "mahdi" : "yasmine"}.jpg'),
                  ),
                ),
              const SizedBox(width: 4),
              Text('+24', style: AppTextStyles.body(9, AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    String title = widget.subjectId == '4' ? 'Toutes les questions' : 'Toutes les publications';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: AppTextStyles.title(15, AppColors.roseDeep), overflow: TextOverflow.visible)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Trier par : ', style: AppTextStyles.body(11, AppColors.textMuted)),
              Text('Récentes', style: AppTextStyles.body(11, AppColors.textPrimary, weight: FontWeight.bold)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildPublicationsList() {
    final posts = _filteredPosts;
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
              const SizedBox(height: 12),
              Text('Aucune publication pour cette catégorie', style: AppTextStyles.body(14, AppColors.textMuted)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(index, posts[index]);
      },
    );
  }

  Widget _buildPostCard(int index, Map<String, dynamic> post) {
    String author = post['author'];
    String avatar = post['avatar'];
    String title = post['title'];
    String time = post['time'];
    String tag = post['tag'];
    String image = post['image'] ?? 'assets/images/sujet populaire/sujet ${widget.subjectId}-${(index % 4) + 2}.png';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(
            post: post,
            subjectTitle: widget.title,
            imagePath: image,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/images/forom cumm/$avatar.jpg')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(author, style: AppTextStyles.title(13, AppColors.textPrimary)),
                          const SizedBox(width: 4),
                          Icon(index % 2 == 0 ? Icons.eco : Icons.local_florist, color: Colors.green, size: 14),
                        ],
                      ),
                      Text(time, style: AppTextStyles.body(10, AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.roseDeep.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                  child: Text(tag, style: AppTextStyles.body(9, AppColors.roseDeep, weight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.title(15, AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: AppColors.petalCream.withOpacity(0.2),
                    child: Image.asset(
                      image, 
                      width: 80, 
                      height: 80, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.petalCream.withOpacity(0.3),
                        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(index % 3 == 0 ? Icons.favorite : Icons.favorite_border_rounded, size: 16, color: index % 3 == 0 ? Colors.red : AppColors.textMuted),
                const SizedBox(width: 4),
                Text('${(index + 1) * 7}', style: AppTextStyles.body(10, AppColors.textMuted)),
                const SizedBox(width: 12),
                const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('${(index + 1) * 3}', style: AppTextStyles.body(10, AppColors.textMuted)),
                const SizedBox(width: 12),
                const Icon(Icons.bookmark_border_rounded, size: 16, color: AppColors.textMuted),
                const Spacer(),
                _buildReplyButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.roseDeep.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Voir les réponses', style: AppTextStyles.body(11, AppColors.roseDeep, weight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.roseDeep),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context, CommunityProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifications', style: AppTextStyles.title(20, AppColors.roseDeep)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Tout marquer lu', style: AppTextStyles.body(12, AppColors.roseDeep, weight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildNotificationItem(
                'Rim a aimé votre publication',
                'Il y a 5 min',
                Icons.favorite,
                Colors.red,
              ),
              _buildNotificationItem(
                'Ahmed a commenté votre photo',
                'Il y a 15 min',
                Icons.chat_bubble,
                Colors.blue,
              ),
              _buildNotificationItem(
                'Sara vous a identifié',
                'Il y a 1h',
                Icons.person_pin,
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String time, IconData icon, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: AppTextStyles.body(14, AppColors.textPrimary, weight: FontWeight.w600)),
      subtitle: Text(time, style: AppTextStyles.body(12, AppColors.textMuted)),
      trailing: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.roseDeep, shape: BoxShape.circle)),
    );
  }
}
