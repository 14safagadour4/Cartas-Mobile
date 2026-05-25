import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String imagePath;

  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildIntroCard(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                  _buildExploreTopics(),
                  const SizedBox(height: 32),
                  _buildActiveMembers(),
                  const SizedBox(height: 32),
                  _buildQuestionBanner(),
                  const SizedBox(height: 100), // Bottom spacing for nav bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.white.withOpacity(0.2),
              const Color(0xFFFDF8F5).withOpacity(1.0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        Stack(
                          children: [
                            const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 32),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: Text('3', style: AppTextStyles.body(10, Colors.white, weight: FontWeight.bold)),
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
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  title,
                  style: AppTextStyles.title(32, AppColors.roseDeep).copyWith(height: 1.1),
                ),
                const SizedBox(height: 12),
                Text(
                  'Partagez vos conseils, posez vos questions\net apprenez ensemble les bases du jardinage. 🌸',
                  style: AppTextStyles.body(14, AppColors.textPrimary.withOpacity(0.8)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Row(
                      children: [
                        for (int i = 0; i < 4; i++)
                          Align(
                            widthFactor: 0.7,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage('assets/images/forom cumm/${i == 0 ? "olivia" : i == 1 ? "mahdi" : i == 2 ? "yasmine" : "ahmed"}.jpg'),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text('+87', style: AppTextStyles.body(11, AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Text('52 réponses', style: AppTextStyles.body(11, AppColors.textMuted)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.push_pin_rounded, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text('Épinglé', style: AppTextStyles.body(10, Colors.white, weight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Vous débutez en jardinage ? Ici, retrouvez tous nos conseils pour commencer facilement : choisir ses plantes, préparer le sol, arroser, entretenir et voir son jardin s\'épanouir 🌱',
              style: AppTextStyles.body(13, AppColors.textPrimary).copyWith(height: 1.5),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            _buildActionButton('assets/images/jardin/Logo Conseils.png', 'Conseils', const Color(0xFFE8F5E9)),
            _buildActionButton('assets/images/jardin/Logo Question.png', 'Poser une question', const Color(0xFFF3E5F5)),
            _buildActionButton('assets/images/jardin/partager photo.png', 'Partager une photo', const Color(0xFFFFF3E0)),
            _buildActionButton('assets/images/jardin/enregestrer .png', 'Enregistrer', const Color(0xFFFCE4EC)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String assetPath, String label, Color bgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
            child: Image.asset(
              assetPath, 
              width: 45, 
              height: 45, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined, size: 45, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 85,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(11, AppColors.textPrimary, weight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreTopics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Sujets à explorer ', style: AppTextStyles.title(18, AppColors.textPrimary)),
            const Text('🌱', style: TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTopicTile('Choisir ses premières plantes', '26 publications', const Color(0xFFF1F8E9), 'assets/images/jardin/plante.png'),
        _buildTopicTile('Préparer le sol', '18 publications', const Color(0xFFEFEBE9), 'assets/images/jardin/preparer le sol .png'),
        _buildTopicTile('Arrosage et entretien', '23 publications', const Color(0xFFE3F2FD), 'assets/images/jardin/arrosages .png'),
        _buildTopicTile('Petits problèmes & solutions', '15 publications', const Color(0xFFFFF3E0), 'assets/images/jardin/problemes et solutions .png'),
        _buildTopicTile('Planifier son jardin', '12 publications', const Color(0xFFFCE4EC), 'assets/images/jardin/planifier son jardin .png'),
      ],
    );
  }

  Widget _buildTopicTile(String title, String count, Color bgColor, String assetPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Image.asset(
              assetPath, 
              width: 35, 
              height: 35, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco_outlined, size: 35, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title(14, AppColors.textPrimary)),
                Text(count, style: AppTextStyles.body(11, AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildActiveMembers() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('Membres actifs', style: AppTextStyles.title(16, AppColors.textPrimary)),
              ],
            ),
            Text('Voir tous', style: AppTextStyles.body(12, AppColors.textMuted, weight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMemberAvatar('Yasmine', 'olivia', '🌹'),
            _buildMemberAvatar('Mehdi', 'mahdi', '🍃'),
            _buildMemberAvatar('Olivia', 'yasmine', '🌸'),
            _buildMemberAvatar('Karim', 'malek', '🍃'),
            _buildMoreAvatar('+125'),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberAvatar(String name, String image, String emoji) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/images/forom cumm/$image.jpg')),
            Positioned(
              right: 0,
              bottom: 0,
              child: Text(emoji, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: AppTextStyles.body(11, AppColors.textPrimary, weight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMoreAvatar(String text) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: const Color(0xFFF5E9E2), shape: BoxShape.circle),
      child: Center(child: Text(text, style: AppTextStyles.body(12, AppColors.textMuted, weight: FontWeight.bold))),
    );
  }

  Widget _buildQuestionBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF3F0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/forom cumm/warda.png', width: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Une question ?', style: AppTextStyles.title(15, AppColors.textPrimary)),
                Text('La communauté est là pour vous aider 🌸', style: AppTextStyles.body(11, AppColors.textMuted)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D243B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('Poser une question', style: AppTextStyles.body(11, Colors.white, weight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Jardin'),
          _buildNavItem(Icons.store_outlined, 'Boutique'),
          const SizedBox(width: 40), // Espace à la place de la rose
          _buildNavItem(Icons.people_outline_rounded, 'Communauté', isSelected: true),
          _buildNavItem(Icons.person_outline_rounded, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isSelected ? AppColors.roseDeep : AppColors.textMuted),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.body(10, isSelected ? AppColors.roseDeep : AppColors.textMuted)),
      ],
    );
  }

  Widget _buildCenterNavItem() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF4A2C5D),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: const Color(0xFF4A2C5D).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Image.asset('assets/images/forom cumm/warda.png', width: 40),
    );
  }
}
