import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import 'subject_detail_screen.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class PopularSubjectsScreen extends StatefulWidget {
  const PopularSubjectsScreen({super.key});

  @override
  State<PopularSubjectsScreen> createState() => _PopularSubjectsScreenState();
}

class _PopularSubjectsScreenState extends State<PopularSubjectsScreen> {
  String _selectedFilter = 'Tous';

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
                _buildFeaturedSection(),
                _buildAllSubjectsHeader(),
                _buildSubjectsList(),
                _buildRecentSubjectsHeader(),
                _buildRecentPostsList(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFFFDF8F5),
      elevation: 0,
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
                Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 32),
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
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg'),
                ),
              ],
            ),
          ),
        ),
      ],
      expandedHeight: 150,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sujets populaires', style: AppTextStyles.title(24, AppColors.roseDeep)),
              Text('Explorez les sujets qui passionnent notre communauté. 🌸', style: AppTextStyles.body(13, AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.petalCream.withOpacity(0.5)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un sujet...',
                hintStyle: AppTextStyles.body(14, AppColors.textMuted),
                border: InputBorder.none,
                icon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<CommunityProvider>(
            builder: (context, provider, child) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tous', isSelected: _selectedFilter == 'Tous'),
                  ...provider.topics.where((t) => t.name != 'Tout').map((topic) => _buildFilterChip(topic.name, isSelected: _selectedFilter == topic.name)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.roseDeep : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.roseDeep : AppColors.petalCream.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(13, isSelected ? Colors.white : AppColors.textPrimary, weight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🔥 À la une', style: AppTextStyles.title(16, AppColors.roseDeep)),
              Text('Voir tout', style: AppTextStyles.body(12, AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubjectDetailScreen(
              title: 'Le jardin de vos rêves',
              description: 'Partagez vos inspirations, vos idées et vos plus beaux jardins.',
              icon: Icons.emoji_events_outlined,
              bgColor: Color(0xFFFBE9E7),
              iconColor: Color(0xFFFF8A65),
              subjectId: '2',
            ))),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
                      child: Image.asset(
                        'assets/images/sujet populaire/sujet 2-1.png',
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          color: AppColors.petalCream.withOpacity(0.3),
                          child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 32),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Color(0xFFFBE9E7), shape: BoxShape.circle),
                                child: const Icon(Icons.emoji_events_outlined, color: Color(0xFFFF8A65), size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Le jardin de vos rêves', style: AppTextStyles.title(14, AppColors.roseDeep))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (int i = 0; i < 3; i++)
                                Align(
                                  widthFactor: 0.7,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage: AssetImage('assets/images/forom cumm/${i == 0 ? "olivia" : i == 1 ? "mahdi" : "yasmine"}.jpg'),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Text('+256', style: AppTextStyles.body(10, AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('128 publications', style: AppTextStyles.body(10, AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSubjectsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tous les sujets', style: AppTextStyles.title(16, AppColors.roseDeep)),
          Row(
            children: [
              Text('Trier', style: AppTextStyles.body(12, AppColors.textMuted)),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildSubjectCard(context, 'Astuces & Conseils', 'Partagez vos conseils pour un jardin florissant.', '128', Icons.local_florist_outlined, const Color(0xFFEFEBE9), const Color(0xFF8D6E63), '1'),
        _buildSubjectCard(context, 'Événements', 'Découvrez et partagez les événements autour du jardinage.', '73', Icons.calendar_today_outlined, const Color(0xFFF3E5F5), const Color(0xFFAB47BC), '3'),
        _buildSubjectCard(context, 'Questions', 'Posez vos questions et obtenez des réponses de la communauté.', '52', Icons.help_outline_rounded, const Color(0xFFE8EAF6), const Color(0xFF7986CB), '4'),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, String title, String desc, String pubs, IconData icon, Color bgColor, Color iconColor, String id) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubjectDetailScreen(
        title: title,
        description: desc,
        icon: icon,
        bgColor: bgColor,
        iconColor: iconColor,
        subjectId: id,
      ))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.title(14, AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc, style: AppTextStyles.body(11, AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('$pubs publications', style: AppTextStyles.body(10, AppColors.roseDeep, weight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSubjectsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Sujets récents', style: AppTextStyles.title(16, AppColors.roseDeep)),
          Text('Voir tout', style: AppTextStyles.body(12, AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildRecentPostsList() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (provider.posts.isEmpty) return const SizedBox();
        final post = provider.posts.first;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 18, backgroundImage: AssetImage(post.authorAvatar)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(post.authorName, style: AppTextStyles.title(13, AppColors.textPrimary)),
                            const SizedBox(width: 4),
                            const Icon(Icons.eco, color: Colors.green, size: 14),
                          ],
                        ),
                        Text(post.timeAgo, style: AppTextStyles.body(10, AppColors.textMuted)),
                      ],
                    ),
                  ),
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
                        Text(
                          'Comment prendre soin des rosiers en hiver ? 🌸',
                          style: AppTextStyles.title(14, AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  if (post.images.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          post.images.first,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${post.comments}', style: AppTextStyles.body(11, AppColors.textMuted)),
                  const SizedBox(width: 16),
                  const Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${post.likes}', style: AppTextStyles.body(11, AppColors.textMuted)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
