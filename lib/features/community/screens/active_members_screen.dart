import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class ActiveMembersScreen extends StatefulWidget {
  const ActiveMembersScreen({super.key});

  @override
  State<ActiveMembersScreen> createState() => _ActiveMembersScreenState();
}

class _ActiveMembersScreenState extends State<ActiveMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().fetchLeaderboard();
    });
  }

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
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildSearchAndFilters(context),
                Expanded(
                  child: Consumer<CommunityProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLeaderboardLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.roseDeep));
                      }
                      if (provider.leaderboardError != null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                Text('Erreur de connexion', style: AppTextStyles.title(18, AppColors.textPrimary)),
                                const SizedBox(height: 8),
                                Text(
                                  provider.leaderboardError!,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body(14, AppColors.textMuted),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => provider.fetchLeaderboard(),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.roseDeep),
                                  child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        children: [
                          ...provider.leaderboard.map((member) {
                            IconData iconData;
                            Color iconColor;
                            switch (member.icon) {
                              case 'eco': iconData = Icons.eco; iconColor = Colors.green; break;
                              case 'auto_awesome': iconData = Icons.auto_awesome; iconColor = Colors.redAccent; break;
                              default: iconData = Icons.star; iconColor = Colors.amber;
                            }
                            return _buildMemberCard(
                              rank: member.rank,
                              name: member.name,
                              title: member.title,
                              points: member.points,
                              posts: member.posts,
                              avatar: member.avatar,
                              icon: iconData,
                              iconColor: iconColor,
                            );
                          }),
                          const SizedBox(height: 20),
                          _buildPromoBanner(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.roseDeep),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Consumer<CommunityProvider>(
                builder: (context, provider, child) => Row(
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
                    const SizedBox(width: 16),
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Membres actifs', style: AppTextStyles.title(24, AppColors.roseDeep)),
          Text(
            'Découvrez les membres les plus actifs\nde notre communauté 🌸',
            style: AppTextStyles.body(14, AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.petalCream),
              ),
              child: TextField(
                onChanged: (value) => provider.setSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Rechercher un membre...',
                  hintStyle: AppTextStyles.body(14, AppColors.textMuted),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, 'Tous', isSelected: provider.timeFilter == 'Tous'),
                  _buildFilterChip(context, 'Cette semaine', isSelected: provider.timeFilter == 'Cette semaine'),
                  _buildFilterChip(context, 'Ce mois', isSelected: provider.timeFilter == 'Ce mois'),
                  _buildFilterChip(context, 'Tout le temps', isSelected: provider.timeFilter == 'Tout le temps'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.petalCream),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => context.read<CommunityProvider>().setTimeFilter(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.roseDeep : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.roseDeep : AppColors.petalCream),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(13, isSelected ? Colors.white : AppColors.textPrimary, weight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildMemberCard({
    required int rank,
    required String name,
    required String title,
    required String points,
    required String posts,
    required String avatar,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          _buildRankBadge(rank),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage(avatar),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: AppTextStyles.title(14, AppColors.textPrimary)),
                    const SizedBox(width: 4),
                    Icon(icon, size: 12, color: iconColor),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.petalCream.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(title, style: AppTextStyles.body(9, AppColors.textMuted)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.red, size: 12),
                  const SizedBox(width: 2),
                  Text('$points pts', style: AppTextStyles.title(12, AppColors.textPrimary)),
                ],
              ),
              Text('$posts pub.', style: AppTextStyles.body(10, AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank <= 3) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: rank == 1 ? Colors.amber.withOpacity(0.2) : rank == 2 ? Colors.grey.withOpacity(0.2) : Colors.brown.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.workspace_premium_rounded,
            color: rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : Colors.brown,
            size: 20,
          ),
        ),
      );
    }
    return Container(
      width: 32,
      child: Center(
        child: Text(rank.toString(), style: AppTextStyles.title(16, AppColors.textMuted.withOpacity(0.5))),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.roseDeep.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.petalCream),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.roseDeep, shape: BoxShape.circle),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Restez actif et gagnez des points !', style: AppTextStyles.title(14, AppColors.roseDeep)),
                const SizedBox(height: 4),
                Text(
                  'Partagez vos expériences, aidez les autres membres et grimpez dans le classement.',
                  style: AppTextStyles.body(11, AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
