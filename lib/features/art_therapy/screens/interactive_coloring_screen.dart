import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:cartas/features/art_therapy/models/drawing_stroke.dart';
import 'package:cartas/features/art_therapy/models/user_drawing.dart';
import 'package:cartas/features/art_therapy/providers/art_therapy_provider.dart';
import 'package:cartas/features/art_therapy/widgets/coloring_painter.dart';

class InteractiveColoringScreen extends StatefulWidget {
  final String title;
  final String imagePath;
  final String difficulty;
  final String duration;
  final String? initialDrawingJson;

  const InteractiveColoringScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.difficulty,
    required this.duration,
    this.initialDrawingJson,
  });

  @override
  State<InteractiveColoringScreen> createState() =>
      _InteractiveColoringScreenState();
}

class _InteractiveColoringScreenState extends State<InteractiveColoringScreen>
    with TickerProviderStateMixin {
  // Drawing state
  final List<DrawingStroke> _strokes = [];
  DrawingStroke? _currentStroke;
  final GlobalKey _canvasKey = GlobalKey();

  // Zoom / pan
  final TransformationController _transformController =
      TransformationController();
  int _activePointers = 0;
  bool get _isZooming => _activePointers >= 2;

  // Audio state
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;
  String _currentTrack = 'zen_garden.mp3';

  // Tool state
  Color _selectedColor = const Color(0xFFE8A4B0);
  double _brushSize = 4.0;
  bool _isEraser = false;
  bool _isZoomMode = false; // New: Toggle between drawing and moving/zooming

  // Animation for bottom palette
  late AnimationController _paletteController;
  late Animation<double> _paletteAnimation;

  // Palette colors
  static const List<Color> _palette = [
    Color(0xFFE8A4B0), // rose
    Color(0xFF7EB5A6), // sage vert
    Color(0xFFD4A853), // doré
    Color(0xFF9B7DB6), // violet
    Color(0xFF5A9BC4), // bleu ciel
    Color(0xFFE8726B), // corail
    Color(0xFF6BAE75), // vert prairie
    Color(0xFFE8C17A), // jaune chaud
    Color(0xFFB5651D), // brun cannelle
    Color(0xFF3A3A5C), // marine profond
    Color(0xFFFF8FAB), // rose vif
    Colors.black,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _paletteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _paletteAnimation = CurvedAnimation(
      parent: _paletteController,
      curve: Curves.easeOutCubic,
    );
    _paletteController.forward();

    if (widget.initialDrawingJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(widget.initialDrawingJson!);
        setState(() {
          for (var item in decoded) {
            _strokes.add(DrawingStroke.fromJson(item));
          }
        });
      } catch (e) {
        debugPrint('Error loading initial drawing: $e');
      }
    }
  }

  @override
  void dispose() {
    _paletteController.dispose();
    _transformController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _showMusicSelectionMenu() async {
    final List<Map<String, String>> tracks = [
      {'title': 'Stop Overthinking', 'file': 'music/Beautiful Relaxing Music - Stop Overthinking, Stress Relief Music, Sleep Music, Calming Music.mp3'},
      {'title': 'Nature Sounds', 'file': 'music/Relaxing Music Nature Sounds #shorts.mp3'},
      {'title': 'Short Meditation', 'file': 'music/Short Meditation Music - 3 Minute Relaxation, Calming.mp3'},
    ];

    await showModalBottomSheet(
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
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Musique Relaxante 🌿',
              style: AppTextStyles.title(18, AppColors.roseDeep, weight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (_isMusicPlaying)
              ListTile(
                leading: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent),
                title: Text('Arrêter la musique', style: AppTextStyles.body(14, Colors.redAccent, weight: FontWeight.w600)),
                onTap: () async {
                  await _audioPlayer.pause();
                  setState(() => _isMusicPlaying = false);
                  if (mounted) Navigator.pop(ctx);
                },
              ),
            ...tracks.map((track) {
              final isSelected = _currentTrack == track['file'];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected && _isMusicPlaying ? AppColors.sage.withOpacity(0.2) : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.music_note_rounded,
                    color: isSelected && _isMusicPlaying ? AppColors.sage : AppColors.textMuted,
                    size: 20,
                  ),
                ),
                title: Text(
                  track['title']!,
                  style: AppTextStyles.body(
                    14,
                    isSelected && _isMusicPlaying ? AppColors.sage : AppColors.textPrimary,
                    weight: isSelected && _isMusicPlaying ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: isSelected && _isMusicPlaying
                    ? const Icon(Icons.graphic_eq_rounded, color: AppColors.sage, size: 20)
                    : null,
                onTap: () async {
                  await _audioPlayer.play(AssetSource(track['file']!));
                  setState(() {
                    _currentTrack = track['file']!;
                    _isMusicPlaying = true;
                  });
                  if (mounted) Navigator.pop(ctx);
                },
              );
            }).toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (_isZooming) return; // ignore draw when pinching
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localPos = box.globalToLocal(details.globalPosition);
    setState(() {
      _currentStroke = DrawingStroke(
        points: [localPos],
        color: _selectedColor,
        width: _isEraser ? _brushSize * 2.5 : _brushSize,
        isEraser: _isEraser,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isZooming) return;
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || _currentStroke == null) return;
    final localPos = box.globalToLocal(details.globalPosition);
    setState(() {
      _currentStroke = _currentStroke!.copyWith(
        points: [..._currentStroke!.points, localPos],
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke == null) return;
    setState(() {
      _strokes.add(_currentStroke!);
      _currentStroke = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  void _resetZoom() {
    setState(() {
      _transformController.value = Matrix4.identity();
    });
  }

  void _zoomIn() {
    final matrix = _transformController.value.clone();
    final scale = matrix.getMaxScaleOnAxis();
    if (scale >= 5.0) return;
    
    // Zoom towards center
    matrix.scale(1.4, 1.4);
    setState(() => _transformController.value = matrix);
  }

  void _zoomOut() {
    final matrix = _transformController.value.clone();
    final scale = matrix.getMaxScaleOnAxis();
    if (scale <= 0.8) return;
    matrix.scale(1 / 1.4, 1 / 1.4);
    setState(() => _transformController.value = matrix);
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_transformController.value.getMaxScaleOnAxis() > 1.0) {
      _resetZoom();
    } else {
      final pos = details.localPosition;
      final matrix = Matrix4.identity()
        ..translate(-pos.dx * 1.5, -pos.dy * 1.5)
        ..scale(2.5);
      setState(() => _transformController.value = matrix);
    }
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Effacer tout ?',
            style: AppTextStyles.title(16, AppColors.roseDeep,
                weight: FontWeight.w700)),
        content: Text('Voulez-vous recommencer depuis le début ?',
            style: AppTextStyles.body(13, AppColors.textDim)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler',
                style: AppTextStyles.body(13, AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _strokes.clear());
            },
            child: Text('Effacer',
                style: AppTextStyles.body(13, AppColors.roseDeep,
                    weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage() async {
    final provider = Provider.of<ArtTherapyProvider>(context, listen: false);
    
    final drawingJson = jsonEncode(_strokes.map((s) => s.toJson()).toList());
    
    final drawing = UserDrawing(
      userEmail: "user@example.com", // Simulated user
      templateTitle: widget.title,
      templateImagePath: widget.imagePath,
      drawingDataJson: drawingJson,
    );

    final success = await provider.saveDrawing(drawing);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? 'Chef-d\'œuvre enregistré dans votre galerie ! 🎨✨' 
            : 'Erreur lors de la sauvegarde : ${provider.error}', 
            style: AppTextStyles.body(13, Colors.white)),
          backgroundColor: success ? AppColors.sage : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      if (success) _showPostMoodDialog();
    }
  }

  void _showPostMoodDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✨', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text('Félicitations !', style: AppTextStyles.title(20, AppColors.roseDeep, weight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Comment vous sentez-vous après cette séance ?', textAlign: TextAlign.center, style: AppTextStyles.body(13, AppColors.textDim)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPostMoodIcon(ctx, '😊', 'Mieux'),
                _buildPostMoodIcon(ctx, '😌', 'Zen'),
                _buildPostMoodIcon(ctx, '💪', 'Inspirée'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Simulate sharing to forum
                  Navigator.pop(ctx);
                  context.go('/arttherapy');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partagé avec la communauté ! 🌸')),
                  );
                },
                icon: const Icon(Icons.forum_outlined, size: 18),
                label: Text('Partager sur le Forum', style: AppTextStyles.body(13, Colors.white, weight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseMid,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostMoodIcon(BuildContext ctx, String icon, String label) {
    return GestureDetector(
      onTap: () => context.go('/arttherapy'),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.body(11, AppColors.textDim, weight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog() async {
    if (_strokes.isEmpty) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Quitter le coloriage ?',
            textAlign: TextAlign.center,
            style: AppTextStyles.title(18, AppColors.roseDeep, weight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.palette_outlined, size: 60, color: AppColors.roseMid),
            const SizedBox(height: 16),
            Text('Voulez-vous enregistrer votre création avant de partir ?',
                textAlign: TextAlign.center,
                style: AppTextStyles.body(14, AppColors.textDim)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, 'save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roseDeep,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Enregistrer et quitter', style: AppTextStyles.body(13, Colors.white, weight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, 'quit'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.roseDeep.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Quitter sans save', style: AppTextStyles.body(12, AppColors.roseDeep)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, 'stay'),
                      child: Text('Rester', style: AppTextStyles.body(12, AppColors.textMuted)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    if (result == 'save') {
      await _saveImage();
      return true;
    } else if (result == 'quit') {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && mounted) {
          context.go('/arttherapy');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F2F4),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _buildCanvas()),
                  _buildFloatingControls(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final shouldPop = await _showExitDialog();
                  if (shouldPop && mounted) context.go('/arttherapy');
                },
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.roseDeep, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: AppTextStyles.title(20, AppColors.roseDeep, weight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _showMusicSelectionMenu,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isMusicPlaying ? AppColors.roseMid.withOpacity(0.1) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMusicPlaying ? Icons.music_note_rounded : Icons.music_off_rounded,
                    color: _isMusicPlaying ? AppColors.roseDeep : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(widget.difficulty, difficulty: widget.difficulty),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(widget.duration, style: AppTextStyles.body(12, AppColors.textMuted)),
              const Spacer(),
              const Icon(Icons.pinch_rounded, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text('Zoomer / Déplacer', style: AppTextStyles.body(10, AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingControls() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    final zoomPercent = (scale * 100).round();

    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _buildFloatingButton(
            icon: _isZoomMode ? Icons.edit_rounded : Icons.pan_tool_alt_rounded,
            color: _isZoomMode ? AppColors.roseDeep : Colors.white,
            iconColor: _isZoomMode ? Colors.white : AppColors.roseDeep,
            onTap: () => setState(() {
              _isZoomMode = !_isZoomMode;
              if (_isZoomMode) _isEraser = false;
            }),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _buildZoomIcon(Icons.add_rounded, _zoomIn),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('$zoomPercent%', style: AppTextStyles.body(10, AppColors.roseDeep, weight: FontWeight.w700)),
                ),
                _buildZoomIcon(Icons.remove_rounded, _zoomOut),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildFloatingButton(icon: Icons.undo_rounded, onTap: _undo, enabled: _strokes.isNotEmpty),
          const SizedBox(height: 12),
          _buildFloatingButton(icon: Icons.delete_outline_rounded, onTap: _clearAll, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildZoomIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: AppColors.roseDeep, size: 20),
      ),
    );
  }

  Widget _buildFloatingButton({required IconData icon, required VoidCallback onTap, Color color = Colors.white, Color? iconColor, bool enabled = true}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Icon(icon, color: iconColor ?? AppColors.roseDeep, size: 22),
        ),
      ),
    );
  }








  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isEraser = !_isEraser),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isEraser ? AppColors.roseDeep : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.auto_fix_high_rounded, color: _isEraser ? Colors.white : AppColors.textMuted, size: 20),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.roseDeep,
                    inactiveTrackColor: AppColors.roseDeep.withOpacity(0.1),
                    thumbColor: AppColors.roseDeep,
                    overlayColor: AppColors.roseDeep.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _brushSize,
                    min: 1,
                    max: 20,
                    onChanged: (v) => setState(() => _brushSize = v),
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _isEraser ? Colors.white : _selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.roseDeep.withOpacity(0.2)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _palette.map((color) {
                final isSelected = _selectedColor == color && !_isEraser;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedColor = color;
                    _isEraser = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: isSelected ? 44 : 36,
                    height: isSelected ? 44 : 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: AppColors.roseDeep, width: 3) : null,
                      boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)] : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, {required String difficulty}) {
    Color chipColor;
    switch (difficulty.toLowerCase()) {
      case 'facile': chipColor = AppColors.sage; break;
      case 'moyen': chipColor = AppColors.gold; break;
      case 'difficile': chipColor = AppColors.roseVif; break;
      default: chipColor = AppColors.roseDeep;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: AppTextStyles.body(11, chipColor, weight: FontWeight.w700)),
    );
  }

  Widget _buildCanvas() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4)),
            ],
          ),
          child: Listener(
            onPointerDown: (_) => setState(() => _activePointers++),
            onPointerUp: (_) => setState(() { if (_activePointers > 0) _activePointers--; }),
            onPointerCancel: (_) => setState(() { if (_activePointers > 0) _activePointers--; }),
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.8,
              maxScale: 6.0,
              panEnabled: _isZoomMode || _isZooming,
              scaleEnabled: true,
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTap,
                onPanStart: (_isZoomMode || _isZooming) ? null : _onPanStart,
                onPanUpdate: (_isZoomMode || _isZooming) ? null : _onPanUpdate,
                onPanEnd: (_isZoomMode || _isZooming) ? null : _onPanEnd,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, st) => Center(child: Icon(Icons.spa_outlined, color: AppColors.textDim.withOpacity(0.2), size: 80)),
                      ),
                    ),
                    Positioned.fill(
                      child: RepaintBoundary(
                        key: _canvasKey,
                        child: CustomPaint(
                          painter: ColoringPainter(strokes: _strokes, currentStroke: _currentStroke),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
