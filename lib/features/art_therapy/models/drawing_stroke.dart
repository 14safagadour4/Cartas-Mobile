import 'package:flutter/material.dart';

class DrawingStroke {
  final List<Offset?> points;
  final Color color;
  final double width;
  final bool isEraser;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.width,
    this.isEraser = false,
  });

  DrawingStroke copyWith({List<Offset?>? points}) {
    return DrawingStroke(
      points: points ?? this.points,
      color: color,
      width: width,
      isEraser: isEraser,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => p != null ? {'dx': p.dx, 'dy': p.dy} : null).toList(),
      'color': color.value,
      'width': width,
      'isEraser': isEraser,
    };
  }

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    return DrawingStroke(
      points: (json['points'] as List)
          .map((p) => p != null ? Offset(p['dx'], p['dy']) : null)
          .toList(),
      color: Color(json['color']),
      width: json['width'].toDouble(),
      isEraser: json['isEraser'] ?? false,
    );
  }
}
