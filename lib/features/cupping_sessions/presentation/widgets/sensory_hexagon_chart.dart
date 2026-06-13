import 'dart:math' as math;

import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/sensory_scores.dart';
import 'package:flutter/material.dart';

class SensoryHexagonChart extends StatelessWidget {
  const SensoryHexagonChart({
    super.key,
    required this.scores,
    this.size = 260,
    this.fillColor = const Color(0x66879C97),
    this.strokeColor = AuthColors.primary,
    this.backgroundColor = Colors.transparent,
  });

  final SensoryScores scores;
  final double size;
  final Color fillColor;
  final Color strokeColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _SensoryHexagonPainter(
          scores: scores,
          fillColor: fillColor,
          strokeColor: strokeColor,
          backgroundColor: backgroundColor,
        ),
        size: Size.square(size),
      ),
    );
  }
}

class _SensoryHexagonPainter extends CustomPainter {
  const _SensoryHexagonPainter({
    required this.scores,
    required this.fillColor,
    required this.strokeColor,
    required this.backgroundColor,
  });

  final SensoryScores scores;
  final Color fillColor;
  final Color strokeColor;
  final Color backgroundColor;

  static const List<String> _labels = <String>[
    'Aroma',
    'Cuerpo',
    'Acidez',
    'Dulzor',
    'Amargor',
    'Postgusto',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.33;
    final labelRadius = radius + 12;

    if (backgroundColor.a > 0) {
      final backgroundPaint = Paint()..color = backgroundColor;
      canvas.drawRect(Offset.zero & size, backgroundPaint);
    }

    final guidePaint = Paint()
      ..color = const Color(0xFFCDD5D1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final axisPaint = Paint()
      ..color = const Color(0xFFB8C1BC)
      ..strokeWidth = 1.2;

    for (var level = 1; level <= 5; level++) {
      final guideRadius = radius * (level / 5);
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final point = _pointForIndex(
          center: center,
          radius: guideRadius,
          index: i,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, guidePaint);
    }

    for (var i = 0; i < 6; i++) {
      final point = _pointForIndex(center: center, radius: radius, index: i);
      canvas.drawLine(center, point, axisPaint);
      _paintLabel(canvas, size, _labels[i], point, labelRadius, i);
    }

    final values = scores.toChartValues();
    final shapePath = Path();
    for (var i = 0; i < values.length; i++) {
      final point = _pointForIndex(
        center: center,
        radius: radius * (values[i] / 10),
        index: i,
      );
      if (i == 0) {
        shapePath.moveTo(point.dx, point.dy);
      } else {
        shapePath.lineTo(point.dx, point.dy);
      }
    }
    shapePath.close();

    canvas.drawPath(
      shapePath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      shapePath,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  Offset _pointForIndex({
    required Offset center,
    required double radius,
    required int index,
  }) {
    final angle = (-math.pi / 2) + (index * (math.pi / 3));
    return Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
  }

  void _paintLabel(
    Canvas canvas,
    Size size,
    String label,
    Offset axisPoint,
    double labelRadius,
    int index,
  ) {
    final center = Offset(size.width / 2, size.height / 2);
    final direction = (axisPoint - center);
    final normalized = direction / direction.distance;
    final target = center + normalized * labelRadius;
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF5C614F),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 74);

    final dx = switch (index) {
      0 => target.dx - (textPainter.width / 2),
      1 || 2 => target.dx + 2,
      3 => target.dx - (textPainter.width / 2),
      _ => target.dx - textPainter.width - 2,
    };

    final dy = switch (index) {
      0 => target.dy - textPainter.height - 2,
      3 => target.dy,
      _ => target.dy - (textPainter.height / 2),
    };

    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _SensoryHexagonPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
