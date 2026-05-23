import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'dart:ui';
import 'package:cartas/features/home/widgets/home_bottom_nav_bar.dart';

// Interactive Widgets
import '../widgets/quiz_dialog.dart';
import '../widgets/plant_identity_card.dart';
import '../widgets/level_up_dialog.dart';
import 'botanical_match_screen.dart';

class TreasurePathScreen extends StatefulWidget {
  const TreasurePathScreen({super.key});

  @override
  State<TreasurePathScreen> createState() => _TreasurePathScreenState();
}

class _TreasurePathScreenState extends State<TreasurePathScreen> {
  // Game State
  bool _isQuizUnlocked = true;
  bool _isForestUnlocked = true;
  bool _isLevel13 = false;
  int _xp = 1500;
  int _level = 10;
  bool _showAdventureCard = false;

  void _onQuizComplete(bool success) {
    if (success) {
      setState(() {
        _isForestUnlocked = true;
        _xp += 100;
      });
      _showSuccessSnackBar('Forêt de Cartas débloquée – Région suivante ! 🌳 (+100 XP)');
    } else {
      _showErrorSnackBar('On réessaie ! (ou consomme une gemme / un ticket)');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.sage,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.roseMid,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onLevelUp() {
    showDialog(
      context: context,
      builder: (context) => const LevelUpDialog(),
    ).then((_) {
      setState(() {
        _isLevel13 = true;
        _level = 13;
        _xp += 200;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F7F2), // Parchment color
        body: Stack(
          children: [
          // Background Illustration (Map)
          Positioned.fill(
            child: Image.asset(
              'assets/images/map/map_bg.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          // Scrollable Map Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 100), // Padding for the fixed Top Bar
                
                // Progression Card (Now Scrollable)
                _buildProgressionCard(),
                
                Stack(
                  children: [
                    // The Path & Nodes
                    SizedBox(
                      height: 1000,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: PathPainter(
                          unlockedTo: _isLevel13 ? 4 : (_isForestUnlocked ? 3 : (_isQuizUnlocked ? 2 : 1)),
                        ),
                        child: Stack(
                          children: [
                            // Level Nodes
                            _buildNode(
                              top: 850,
                              left: 175,
                              title: 'Oasis Beginnings',
                              icon: Icons.check,
                              isCompleted: true,
                              onTap: () {
                                _showSuccessSnackBar('Succès : Débuts de la flore tunisienne débloqué ! 🏆');
                              },
                            ),
                            _buildNode(
                              top: 650,
                              left: 65,
                              title: 'Botanical Quiz',
                              icon: Icons.menu_book,
                              isCompleted: true,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => QuizDialog(onResult: _onQuizComplete),
                                );
                              },
                            ),
                            _buildNode(
                              top: 450,
                              left: 215,
                              title: 'Cartas Forest',
                              icon: Icons.landscape,
                              isCompleted: true,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const PlantIdentityCard(),
                                );
                              },
                            ),
                            _buildNode(
                              top: 350,
                              left: 130,
                              title: 'Herb Garden',
                              icon: Icons.grid_view_rounded,
                              isCompleted: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const BotanicalMatchScreen()),
                                );
                              },
                            ),
                            _buildNode(
                              top: 250,
                              left: 75,
                              title: 'Leaf Scanner',
                              icon: Icons.qr_code_scanner,
                              isLocked: false, 
                              isActive: !_isQuizUnlocked,
                              onTap: () => context.push('/scanner'),
                            ),
                            _buildNode(
                              top: 50,
                              left: 195,
                              title: _isLevel13 ? 'Oasis Level 13' : 'Cork Oak',
                              icon: _isLevel13 ? Icons.auto_awesome : Icons.forest,
                              isLocked: !_isLevel13,
                              isActive: _isLevel13,
                            ),

                            // Explorer Avatar (Centered perfectly on nodes)
                            if (!_showAdventureCard || _isLevel13)
                              AnimatedPositioned(
                                duration: const Duration(seconds: 1),
                                top: _isLevel13 ? 10 : (_isForestUnlocked ? 410 : (_isQuizUnlocked ? 610 : 210)),
                                left: _isLevel13 ? 195 : (_isForestUnlocked ? 215 : (_isQuizUnlocked ? 65 : 75)),
                                child: _buildExplorerAvatar(),
                              ),

                            // Floating Adventure Card (with integrated avatar)
                            if (_showAdventureCard && !_isLevel13)
                              Positioned(
                                top: _isForestUnlocked ? 300 : 520,
                                left: 40,
                                right: 40,
                                child: _buildAdventureCard(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Fixed Top Bar (Home + Branding + Search removed)
          _buildFixedTopBar(),

          // Bottom Navigation removed as requested
        ],
      ),
    ),
  );
}

  Widget _buildFixedTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home, color: AppColors.roseMid, size: 30),
          ),
          GestureDetector(
            onTap: () => context.go('/home'),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'The Botanical',
                    style: AppTextStyles.title(16, AppColors.roseDeep, weight: FontWeight.w900),
                  ),
                  Text(
                    'Curator',
                    style: AppTextStyles.title(16, AppColors.roseDeep, weight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TUNISIAN FLORA',
                style: AppTextStyles.body(9, AppColors.sage, weight: FontWeight.w900),
              ),
              Text(
                _level >= 13 ? 'MASTER' : 'EXPERT',
                style: AppTextStyles.body(9, AppColors.sage, weight: FontWeight.w900),
              ),
              Text(
                _level >= 13 ? 'Grand Master' : 'Wise Sage',
                style: AppTextStyles.title(12, AppColors.roseDeep, weight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(width: 28), // Placeholder for balance instead of search
        ],
      ),
    );
  }


  Widget _buildProgressionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tri9 el Kenz',
                    style: AppTextStyles.title(26, AppColors.roseDeep, weight: FontWeight.w900),
                  ),
                  Text(
                    'BOTANICAL TREASURE HUNT',
                    style: AppTextStyles.body(11, AppColors.textMuted, weight: FontWeight.w700),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Level',
                    style: AppTextStyles.body(12, AppColors.gold, weight: FontWeight.w600),
                  ),
                  Text(
                    '$_level',
                    style: AppTextStyles.title(26, AppColors.gold, weight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _xp / 2000,
              minHeight: 10,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sage),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.sage, size: 14),
                  const SizedBox(width: 4),
                  Text('$_xp XP', style: AppTextStyles.body(11, AppColors.textPrimary, weight: FontWeight.w700)),
                ],
              ),
              Text('${2000 - _xp} XP TO NEXT RANK', style: AppTextStyles.body(11, AppColors.textMuted, weight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildNode({
    required double top,
    required double left,
    required String title,
    required IconData icon,
    bool isCompleted = false,
    bool isActive = false,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isLocked ? Colors.white.withOpacity(0.8) : (isCompleted ? AppColors.sage : Colors.white.withOpacity(0.9)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppColors.gold : (isLocked ? Colors.grey.shade300 : AppColors.sage),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isLocked ? Colors.grey.shade400 : (isCompleted ? Colors.white : AppColors.sage),
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title.toUpperCase(),
              style: AppTextStyles.body(10, isLocked ? Colors.grey : AppColors.roseDeep, weight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplorerAvatar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle,
        ),
        child: const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/map/explorer.png'),
        ),
      ),
    );
  }

  Widget _buildAdventureCard() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Main Card
        Container(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppColors.roseDeep.withOpacity(0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => setState(() => _showAdventureCard = false),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: AppColors.roseDeep),
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isForestUnlocked ? 'Cartas Forest' : 'Oasis Discovery',
                  style: AppTextStyles.body(12, AppColors.goldDeep, weight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isForestUnlocked ? 'IDENTIFIER' : 'CARTAS',
                style: AppTextStyles.title(24, AppColors.roseDeep, weight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                _isForestUnlocked 
                  ? 'Identifiez l\'Arbutus unedo rare pour débloquer la région suivante.'
                  : 'Utilisez le scanner pour trouver la plante et débloquer le quiz.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(14, AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  if (_isForestUnlocked) {
                    // Open identifier mystery card
                    showDialog(
                      context: context,
                      builder: (context) => const PlantIdentityCard(),
                    );
                  } else if (!_isQuizUnlocked) {
                    // Simulate finding the plant after scan (mock logic)
                    setState(() => _isQuizUnlocked = true);
                    _showSuccessSnackBar('Plante trouvée ! Quiz débloqué 📚');
                  } else if (_isQuizUnlocked && !_isForestUnlocked) {
                    // Open Quiz
                    showDialog(
                      context: context,
                      builder: (context) => QuizDialog(onResult: _onQuizComplete),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'CONTINUE ADVENTURE',
                      style: AppTextStyles.body(14, Colors.white, weight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Overlapping Avatar
        Positioned(
          top: -40,
          child: _buildExplorerAvatar(),
        ),
      ],
    );
  }
}

class PathPainter extends CustomPainter {
  final int unlockedTo;
  PathPainter({required this.unlockedTo});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.9)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(205, 880);
    path.quadraticBezierTo(205, 780, 95, 680);
    path.quadraticBezierTo(95, 550, 245, 480);
    path.quadraticBezierTo(245, 420, 160, 380); 
    path.quadraticBezierTo(105, 330, 105, 280);
    path.quadraticBezierTo(105, 150, 225, 80);

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 8.0;
    double distance = 0.0;
    for (final PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}





