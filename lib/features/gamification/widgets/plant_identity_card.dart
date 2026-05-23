import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PlantIdentityCard extends StatefulWidget {
  final Map<String, dynamic>? plant;
  const PlantIdentityCard({super.key, this.plant});

  @override
  State<PlantIdentityCard> createState() => _PlantIdentityCardState();
}

class _PlantIdentityCardState extends State<PlantIdentityCard> with SingleTickerProviderStateMixin {
  // --- Game State ---
  int _score = 0;
  int _timeLeft = 30;
  bool _isGameOver = false;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final Random _random = Random();
  double _basketX = 150.0;
  
  final List<FallingItem> _items = [];
  final List<FloatingElement> _birds = [];
  final List<FloatingElement> _butterflies = [];
  final List<Offset> _petals = [];
  
  // Progress tracking
  final List<bool> _completedLevels = [true, true, false, false, false];
  final int _currentHarvestLevel = 3;

  @override
  void initState() {
    super.initState();
    _initFloatingElements();
    _startGameTimer();
  }

  void _initFloatingElements() {
    for (int i = 0; i < 2; i++) {
      _birds.add(FloatingElement(x: _random.nextDouble() * 300, y: _random.nextDouble() * 200, speed: 0.5 + _random.nextDouble()));
    }
    for (int i = 0; i < 3; i++) {
      _butterflies.add(FloatingElement(x: _random.nextDouble() * 300, y: _random.nextDouble() * 400, speed: 0.3 + _random.nextDouble()));
    }
    for (int i = 0; i < 15; i++) {
      _petals.add(Offset(_random.nextDouble() * 350, _random.nextDouble() * 600));
    }
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!_isGameOver) _spawnItem();
    });

    // Ambient loop
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) _updateAmbientElements();
    });
  }

  void _spawnItem() {
    final type = _random.nextDouble() < 0.15 ? ItemType.pest : (_random.nextDouble() < 0.4 ? ItemType.premiumHerb : ItemType.basicHerb);
    setState(() {
      _items.add(FallingItem(
        x: _random.nextDouble() * 300 + 20,
        y: -50,
        speed: 3.0 + _random.nextDouble() * 3,
        type: type,
        emoji: type == ItemType.pest ? '🦂' : (type == ItemType.premiumHerb ? '🪻' : '🌹'),
      ));
    });
  }

  void _updateAmbientElements() {
    setState(() {
      for (var b in _birds) {
        b.x += b.direction ? b.speed : -b.speed;
        if (b.x > 350 || b.x < -50) b.direction = !b.direction;
      }
      for (var bf in _butterflies) {
        bf.y += bf.speed;
        bf.x += sin(bf.y / 20) * 2;
        if (bf.y > 600) bf.y = -50;
      }
      for (int i = 0; i < _items.length; i++) {
        _items[i].y += _items[i].speed;
        if (_items[i].y > 500) {
          _items.removeAt(i);
          i--;
        } else if (_items[i].y > 380 && (_items[i].x - _basketX).abs() < 50) {
          _handleCatch(_items[i]);
          _items.removeAt(i);
          i--;
        }
      }
    });
  }

  void _handleCatch(FallingItem item) {
    if (item.type == ItemType.pest) {
      _score = max(0, _score - 30);
    } else {
      _score += item.type == ItemType.premiumHerb ? 40 : 20;
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() => _isGameOver = true);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        height: 680,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 40)],
          image: const DecorationImage(
            image: AssetImage('assets/images/royal_garden_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Stack(
            children: [
              // Ambient Petals
              ..._petals.map((p) => Positioned(
                left: p.dx,
                top: p.dy,
                child: Opacity(opacity: 0.3, child: const Text('🌸', style: TextStyle(fontSize: 8))),
              )),
              
              // Animated Birds/Butterflies
              ..._birds.map((b) => Positioned(
                left: b.x,
                top: b.y,
                child: Transform(
                  transform: Matrix4.identity()..scale(b.direction ? 1.0 : -1.0, 1.0),
                  child: const Text('🐦', style: TextStyle(fontSize: 24)),
                ),
              )),
              ..._butterflies.map((b) => Positioned(
                left: b.x,
                top: b.y,
                child: const Text('🦋', style: TextStyle(fontSize: 18)),
              )),

              _buildHeader(),
              
              if (!_isGameOver) ...[
                _buildSideControls(),
                _buildSideStats(),
                _buildPowerUps(),
                _buildGameArea(),
                _buildGoldCoffret(),
              ] else
                _buildResultArea(),
                
              _buildTouchLayer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: 15,
      left: 10,
      right: 10,
      child: Center(
        child: Container(
          width: screenWidth * 0.7,
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderStat(Icons.stars_rounded, '$_score', const Color(0xFFD4AF37)),
              Text('JARDIN ROYAL', style: AppTextStyles.title(11, const Color(0xFF4A148C), weight: FontWeight.w900)),
              _buildHeaderStat(Icons.timer_rounded, '${_timeLeft}s', const Color(0xFF4CAF50)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 3),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildSideControls() {
    return Positioned(
      top: 75,
      left: 10,
      child: Column(
        children: [
          _buildCircleControl(Icons.pause_rounded),
          const SizedBox(height: 6),
          _buildCircleControl(Icons.music_note_rounded),
          const SizedBox(height: 6),
          _buildCircleControl(Icons.volume_up_rounded),
        ],
      ),
    );
  }

  Widget _buildCircleControl(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B2D).withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 0.8),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildSideStats() {
    return Positioned(
      top: 75,
      right: 10,
      child: Column(
        children: [
          _buildSquareStat('NIVEAU', '$_currentHarvestLevel'),
          const SizedBox(height: 8),
          _buildSquareStat('SCORE', '$_score'),
        ],
      ),
    );
  }

  Widget _buildSquareStat(String label, String value) {
    return Container(
      width: 55,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B2D).withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 0.8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 7, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPowerUps() {
    return Positioned(
      bottom: 100,
      left: 10,
      child: Column(
        children: [
          _buildPowerUpItem('🧲', 'AIMANT', '3'),
          const SizedBox(height: 8),
          _buildPowerUpItem('⏰', '+10s', '2'),
          const SizedBox(height: 8),
          _buildPowerUpItem('🌹', 'DOUBLE', '3'),
        ],
      ),
    );
  }

  Widget _buildPowerUpItem(String emoji, String label, String count) {
    return Container(
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B2D).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 0.8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
            ],
          ),
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Color(0xFFAD1457), shape: BoxShape.circle),
              child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Stack(
      children: _items.map((item) => Positioned(
        left: item.x,
        top: item.y,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: (item.type == ItemType.pest ? Colors.orange : Colors.white).withOpacity(0.3), blurRadius: 10)],
          ),
          child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
        ),
      )).toList(),
    );
  }

  Widget _buildGoldCoffret() {
    return Positioned(
      left: _basketX - 150,
      bottom: -60,
      child: SizedBox(
        width: 300,
        height: 450,
        child: Image.asset(
          'assets/images/cartas_premium.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTouchLayer() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (_isGameOver) return;
        setState(() => _basketX = (_basketX + details.delta.dx).clamp(30, 320));
      },
      child: Container(color: Colors.transparent),
    );
  }

  Widget _buildResultArea() {
    return Stack(
      children: [
        ...List.generate(15, (index) => _buildResultParticle(index)),
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStagedAnimation(delayMs: 200, child: const Icon(Icons.workspace_premium, color: Color(0xFFD4AF37), size: 60)),
              const SizedBox(height: 10),
              _buildStagedAnimation(delayMs: 400, child: Text('RÉCOLTE TERMINÉE !', style: AppTextStyles.title(20, const Color(0xFFAD1457), weight: FontWeight.w900))),
              _buildStagedAnimation(delayMs: 600, child: Text('$_score', style: AppTextStyles.title(48, const Color(0xFFD4AF37), weight: FontWeight.w900))),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.black12)),
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(5, (index) => _buildAdventureLevel(index + 1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildStagedAnimation(delayMs: 800, child: _buildResultButtons()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _score = 0;
              _timeLeft = 30;
              _isGameOver = false;
              _items.clear();
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
          child: const Text('REJOUER LE NIVEAU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAD1457), minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
          child: const Text('RETOUR À L\'AVENTURE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStagedAnimation({required Widget child, required int delayMs}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, 30 * (1 - value)), child: child),
      ),
      child: child,
    );
  }

  Widget _buildResultParticle(int index) {
    return Positioned(
      left: _random.nextDouble() * 300,
      top: _random.nextDouble() * 600,
      child: const Text('✨', style: TextStyle(fontSize: 10)),
    );
  }

  Widget _buildAdventureLevel(int level) {
    bool isCompleted = _completedLevels[level - 1];
    bool isUnlocked = level == 1 || _completedLevels[level - 2];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 35, height: 35,
            decoration: BoxDecoration(color: isCompleted ? Colors.green : (isUnlocked ? const Color(0xFFD4AF37) : Colors.grey.shade200), shape: BoxShape.circle),
            child: Icon(isCompleted ? Icons.check : (isUnlocked ? Icons.stars : Icons.lock), color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Text('Niveau $level', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          if (isCompleted) const Text('MAESTRO', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- Data Models ---
enum ItemType { premiumHerb, basicHerb, pest }

class FallingItem {
  double x, y, speed;
  final ItemType type;
  final String emoji;
  FallingItem({required this.x, required this.y, required this.speed, required this.type, required this.emoji});
}

class FloatingElement {
  double x, y, speed;
  bool direction = true;
  FloatingElement({required this.x, required this.y, required this.speed});
}
