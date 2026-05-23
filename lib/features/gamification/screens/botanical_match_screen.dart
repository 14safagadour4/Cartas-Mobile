import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../logic/match_engine.dart';
import 'dart:async';

class BotanicalMatchScreen extends StatefulWidget {
  const BotanicalMatchScreen({super.key});

  @override
  State<BotanicalMatchScreen> createState() => _BotanicalMatchScreenState();
}

class _BotanicalMatchScreenState extends State<BotanicalMatchScreen> {
  late MatchEngine _engine;
  int _score = 0;
  int _currentLevel = 1;
  int _movesLeft = 25;
  int _secondsLeft = 60;
  Timer? _timer;
  
  // Multi-target system
  Map<BotanicalType, int> _targets = {};
  Map<BotanicalType, int> _collected = {};
  
  MatchTile? _selectedTile;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _engine = MatchEngine(rows: 8, cols: 7);
    _engine.initGrid();
    _initLevel();
  }

  void _initLevel() {
    setState(() {
      _movesLeft = 30 - (_currentLevel - 1) * 2; // Start with 30 moves
      _secondsLeft = 80 - (_currentLevel - 1) * 5; // Start with 80 seconds
      if (_movesLeft < 10) _movesLeft = 10;
      if (_secondsLeft < 30) _secondsLeft = 30;

      // Define targets based on level (Starting easier)
      _targets = {
        BotanicalType.mint: 8 + (_currentLevel * 2),
        BotanicalType.jasmine: 8 + (_currentLevel * 2),
      };
      if (_currentLevel >= 2) _targets[BotanicalType.lavender] = 8 + _currentLevel;
      if (_currentLevel >= 3) _targets[BotanicalType.rosemary] = 8 + _currentLevel;

      _collected = { for (var type in _targets.keys) type : 0 };
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        _showGameOverDialog('Temps écoulé !');
      }
    });
  }

  void _onTileTap(MatchTile tile) async {
    if (_isProcessing || _movesLeft <= 0 || _secondsLeft <= 0) return;

    if (_selectedTile == null) {
      setState(() => _selectedTile = tile);
    } else {
      if (_engine.isAdjacent(_selectedTile!.row, _selectedTile!.col, tile.row, tile.col)) {
        final r1 = _selectedTile!.row;
        final c1 = _selectedTile!.col;
        final r2 = tile.row;
        final c2 = tile.col;

        setState(() {
          _isProcessing = true;
          _selectedTile = null;
        });

        bool success = _engine.swap(r1, c1, r2, c2);
        if (success) {
          setState(() => _movesLeft--);
          await _processMatches();
        }
        
        setState(() => _isProcessing = false);
      } else {
        setState(() => _selectedTile = tile);
      }
    }
  }

  Future<void> _processMatches() async {
    while (true) {
      final matches = _engine.findMatches();
      if (matches.isEmpty) break;

      bool foundSuper = false;
      for (var tile in matches) {
        if (_collected.containsKey(tile.type)) {
          _collected[tile.type] = _collected[tile.type]! + 1;
        }
        if (tile.isSuper) foundSuper = true;
      }

      if (foundSuper) {
        setState(() {
          _secondsLeft += 5; 
          _score += 50;
        });
      }

      setState(() {
        _score += matches.length * 10;
        _engine.removeMatches(matches);
      });

      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _engine.applyGravity());
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _engine.replenish());
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (_checkWin()) {
      _timer?.cancel();
      _showWinDialog();
    } else if (_movesLeft <= 0) {
      _timer?.cancel();
      _showGameOverDialog('Plus de mouvements !');
    }
  }

  bool _checkWin() {
    for (var type in _targets.keys) {
      if ((_collected[type] ?? 0) < (_targets[type] ?? 0)) return false;
    }
    return true;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Column(
          children: [
            const Icon(Icons.emoji_events, color: AppColors.gold, size: 60),
            const SizedBox(height: 10),
            Text('NIVEAU $_currentLevel RÉUSSI !', style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Excellent travail ! Voulez-vous passer au niveau suivant ?', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text('Score Total: $_score', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentLevel++;
                      _engine.initGrid();
                      _initLevel();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roseDeep,
                    minimumSize: const Size(200, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  child: const Text('CONTINUER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('QUITTER', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(message),
        content: const Text('Souhaitez-vous retenter ce niveau ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _engine.initGrid();
                _initLevel();
              });
            },
            child: const Text('Réessayer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              _buildStatsCard(),
              const Spacer(),
              _buildGrid(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.roseDeep),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'RÉCOLTE BOTANIQUE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.roseDeep,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Niveau', '$_currentLevel', Icons.layers, color: AppColors.gold),
              _buildStatItem('Score', '$_score', Icons.stars),
              _buildStatItem('Temps', '${_secondsLeft}s', Icons.timer, color: _secondsLeft < 10 ? Colors.red : AppColors.roseDeep),
              _buildStatItem('Moves', '$_movesLeft', Icons.touch_app),
            ],
          ),
          const Divider(height: 15, thickness: 0.5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _targets.keys.map((type) {
                final isDone = (_collected[type] ?? 0) >= (_targets[type] ?? 0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      _getBotanicalIconSmall(type),
                      const SizedBox(width: 4),
                      Text(
                        '${_collected[type]}/${_targets[type]}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDone ? Colors.green : AppColors.textPrimary,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (isDone) const Icon(Icons.check_circle, size: 12, color: Colors.green),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBotanicalIconSmall(BotanicalType type) {
    switch (type) {
      case BotanicalType.mint: return const Text('🍃', style: TextStyle(fontSize: 14));
      case BotanicalType.jasmine: return const Text('🌼', style: TextStyle(fontSize: 14));
      case BotanicalType.lavender: return const Text('🌿', style: TextStyle(fontSize: 14));
      case BotanicalType.rosemary: return const Text('🌱', style: TextStyle(fontSize: 14));
      case BotanicalType.aloe: return const Text('🌵', style: TextStyle(fontSize: 14));
      case BotanicalType.chamomile: return const Text('🌸', style: TextStyle(fontSize: 14));
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color color = AppColors.roseDeep}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.title(16, AppColors.textPrimary, weight: FontWeight.w900)),
        Text(label, style: AppTextStyles.body(9, AppColors.textMuted, weight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = (constraints.maxWidth - 30) / 7;
        return Container(
          width: constraints.maxWidth - 10,
          height: tileSize * 8 + 20,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Stack(
            children: [
              for (int r = 0; r < _engine.rows; r++)
                for (int c = 0; c < _engine.cols; c++)
                  if (_engine.grid[r][c] != null)
                    _buildAnimatedTile(_engine.grid[r][c]!, tileSize),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTile(MatchTile tile, double size) {
    final isSelected = _selectedTile?.id == tile.id;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      top: tile.row * size,
      left: tile.col * size,
      child: GestureDetector(
        onTap: () => _onTileTap(tile),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: isSelected ? 1.1 : scale,
              child: Container(
                width: size,
                height: size,
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: tile.isSuper 
                        ? [AppColors.gold.withOpacity(0.4), Colors.white]
                        : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)],
                    ),
                    borderRadius: BorderRadius.circular(tile.isSuper ? 20 : 12),
                    border: Border.all(
                      color: isSelected ? AppColors.gold : (tile.isSuper ? AppColors.gold.withOpacity(0.6) : Colors.white.withOpacity(0.5)),
                      width: isSelected || tile.isSuper ? 2.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected || tile.isSuper
                            ? AppColors.gold.withOpacity(0.3) 
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected || tile.isSuper ? 10 : 4,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _getBotanicalIcon(tile.type),
                      if (tile.isSuper)
                        const Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(Icons.star, size: 10, color: AppColors.gold),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getBotanicalIcon(BotanicalType type) {
    switch (type) {
      case BotanicalType.mint:
        return const Text('🍃', style: TextStyle(fontSize: 24)); // Ne3ne3
      case BotanicalType.jasmine:
        return const Text('🌼', style: TextStyle(fontSize: 24)); // Yasmin
      case BotanicalType.lavender:
        return const Text('🌿', style: TextStyle(fontSize: 24)); // Khouzama
      case BotanicalType.rosemary:
        return const Text('🌱', style: TextStyle(fontSize: 24)); // Iklil
      case BotanicalType.aloe:
        return const Text('🌵', style: TextStyle(fontSize: 24)); // Sabbar
      case BotanicalType.chamomile:
        return const Text('🌸', style: TextStyle(fontSize: 24)); // Babounj
    }
  }
}
