import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
import 'active_members_screen.dart';
import 'popular_subjects_screen.dart';
import 'subject_detail_screen.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../providers/community_provider.dart';
import '../widgets/create_post_card.dart';
import '../widgets/post_card.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/forom cumm/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(child: const CreatePostCard()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildActiveMembers(context)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildPopularSubjectsCard()),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildChallenges()),
                _buildPostFeed(),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.roseDeep),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'FORUM\nCOMMUNAUTAIRE',
                          style: AppTextStyles.title(26, AppColors.roseDeep).copyWith(
                            height: 1.1,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Bienvenue dans votre espace d\'échange. 🌸', style: AppTextStyles.body(13, AppColors.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Consumer<CommunityProvider>(
                  builder: (context, provider, child) => Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showNotifications(context, provider),
                            child: Stack(
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
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Bird Illustration Placeholder
                      const Icon(Icons.flutter_dash, color: Colors.blueGrey, size: 40),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMembers(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Membres actifs', style: AppTextStyles.title(13, AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<CommunityProvider>(
            builder: (context, provider, child) => Row(
              children: [
                if (provider.leaderboard.isNotEmpty)
                  ...provider.leaderboard.take(3).map((member) => Align(
                    widthFactor: 0.7,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage(member.avatar),
                    ),
                  )),
                const SizedBox(width: 10),
                Text('+${provider.leaderboard.length}', style: AppTextStyles.body(12, AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveMembersScreen())),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.petalCream),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Voir tous', style: AppTextStyles.body(12, AppColors.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSubjectsCard() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Sujets populaires', style: AppTextStyles.title(13, AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 12),
              if (provider.topics.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)))
              else
                ...provider.topics.where((t) => t.name != 'Tout').take(4).map((topic) {
                  IconData iconData;
                  Color color;
                  String subjectId;
                  String description;
                  switch (topic.icon) {
                    case 'tips': 
                      iconData = Icons.psychology_outlined; color = Colors.orange; subjectId = '1'; 
                      description = 'Partagez vos conseils pour un jardin florissant.';
                      break;
                    case 'garden': 
                      iconData = Icons.yard_outlined; color = Colors.blue; subjectId = '2';
                      description = 'Montrez-nous vos jardins et inspirez la communauté.';
                      break;
                    case 'event': 
                      iconData = Icons.celebration_outlined; color = Colors.pink; subjectId = '3';
                      description = 'Découvrez et partagez les événements autour du jardinage.';
                      break;
                    case 'question': 
                      iconData = Icons.help_outline_rounded; color = Colors.purple; subjectId = '4';
                      description = 'Posez vos questions et obtenez des réponses de la communauté.';
                      break;
                    default: 
                      iconData = Icons.label_outline; color = Colors.grey; subjectId = '1';
                      description = '';
                  }
                  return _buildSubjectItem(
                    iconData,
                    topic.name,
                    description,
                    color,
                    useMarquee: topic.name == 'Astuces & Conseils',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubjectDetailScreen(
                      title: topic.name,
                      description: description,
                      icon: iconData,
                      bgColor: color.withOpacity(0.1),
                      iconColor: color,
                      subjectId: subjectId,
                    ))),
                  );
                }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PopularSubjectsScreen())),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SizedBox(
                          height: 20,
                          child: Marquee(
                            text: 'Voir tous les sujets',
                            style: AppTextStyles.body(12, AppColors.roseDeep, weight: FontWeight.w600),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            blankSpace: 20.0,
                            velocity: 30.0,
                            pauseAfterRound: const Duration(seconds: 2),
                            startPadding: 10.0,
                            accelerationDuration: const Duration(seconds: 1),
                            accelerationCurve: Curves.linear,
                            decelerationDuration: const Duration(milliseconds: 500),
                            decelerationCurve: Curves.easeOut,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.roseDeep),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubjectItem(IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap, bool isSelected = false, bool useMarquee = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  useMarquee
                    ? SizedBox(
                        height: 20,
                        child: Marquee(
                          text: title,
                          style: AppTextStyles.body(11, isSelected ? color : AppColors.textPrimary, weight: FontWeight.w600),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          blankSpace: 20.0,
                          velocity: 30.0,
                          pauseAfterRound: const Duration(seconds: 2),
                          startPadding: 0.0,
                          accelerationDuration: const Duration(seconds: 1),
                          accelerationCurve: Curves.linear,
                          decelerationDuration: const Duration(milliseconds: 500),
                          decelerationCurve: Curves.easeOut,
                        ),
                      )
                    : Text(title, style: AppTextStyles.body(11, isSelected ? color : AppColors.textPrimary, weight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.body(9, AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallenges() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 24, backgroundImage: AssetImage('assets/images/forom cumm/warda.png')),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Défi des Roses', style: AppTextStyles.title(16, AppColors.textPrimary)),
                Text('Prenez en photo votre plus belle rose et tentez de gagner des points !', style: AppTextStyles.body(11, AppColors.textMuted)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(value: 0.65, minHeight: 6, backgroundColor: AppColors.petalCream, valueColor: AlwaysStoppedAnimation(Colors.green)),
                ),
                const SizedBox(height: 8),
                Text('⏳ 31j 12h restant', style: AppTextStyles.body(11, AppColors.roseMid, weight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildPostFeed() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.roseDeep))));
        if (provider.error != null) return SliverToBoxAdapter(child: Center(child: Text('Erreur: ${provider.error}')));
        if (provider.posts.isEmpty) return const SliverToBoxAdapter(child: Center(child: Text('Pas de posts')));

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => PostCard(post: provider.posts[index]),
            childCount: provider.posts.length,
          ),
        );
      },
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
