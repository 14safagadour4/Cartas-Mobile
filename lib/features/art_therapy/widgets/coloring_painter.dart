import 'package:flutter/material.dart';
import 'package:cartas/features/art_therapy/models/drawing_stroke.dart';

class ColoringPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  ColoringPainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    // saveLayer allows BlendMode.clear (eraser) to cut through all drawn strokes
    canvas.saveLayer(Offset.zero & size, Paint());

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }

    canvas.restore();
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    final paint = Paint()
      ..color = stroke.isEraser
          ? Colors.white
          : stroke.color.withOpacity(0.82) // soft watercolor feel
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = stroke.width
      ..style = PaintingStyle.stroke;

    if (stroke.isEraser) {
      paint.blendMode = BlendMode.clear;
    }

    final path = Path();
    bool first = true;
    for (final point in stroke.points) {
      if (point == null) {
        first = true;
        continue;
      }
      if (first) {
        path.moveTo(point.dx, point.dy);
        first = false;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ColoringPainter oldDelegate) => true;
}
