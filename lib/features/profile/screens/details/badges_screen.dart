import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/core/services/auth_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final result = await AuthService.getProfile();
    if (mounted) {
      setState(() {
        if (result['success']) {
          _userProfile = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int xp = _userProfile?['xp'] ?? 0;
    final int level = _userProfile?['level'] ?? 1;
    final double progress = (xp % 100) / 100.0;

    return Scaffold(
      backgroundColor: AppColors.petalCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mon Niveau & Badges',
          style: AppTextStyles.title(20, AppColors.roseDeep),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rose))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildLevelCard(level, xp, progress),
                  const SizedBox(height: 32),
                  _buildBadgesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildLevelCard(int level, int xp, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'NIVEAU $level',
              style: AppTextStyles.title(18, AppColors.gold, weight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: AppColors.petalCream,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$xp',
                    style: AppTextStyles.title(28, AppColors.roseDeep, weight: FontWeight.w900),
                  ),
                  Text(
                    'XP TOTAL',
                    style: AppTextStyles.body(10, AppColors.textMuted, weight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Plus que ${100 - (xp % 100)} XP pour le niveau suivant !',
            style: AppTextStyles.body(13, AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mes Badges',
          style: AppTextStyles.title(18, AppColors.roseDeep),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildBadgeItem('Novice 🌿', true),
            _buildBadgeItem('Explorateur 🔎', true),
            _buildBadgeItem('Apothicaire 🧪', false),
            _buildBadgeItem('Gardien 🌳', false),
            _buildBadgeItem('Expert 🧠', false),
            _buildBadgeItem('Légende ✨', false),
          ],
        ),
      ],
    );
  }

  Widget _buildBadgeItem(String label, bool unlocked) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: unlocked ? AppColors.rose.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            unlocked ? Icons.verified : Icons.lock_outline,
            color: unlocked ? AppColors.rose : Colors.grey,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.body(10, unlocked ? AppColors.roseDeep : Colors.grey, weight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
