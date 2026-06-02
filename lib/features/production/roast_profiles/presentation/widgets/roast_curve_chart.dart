import 'dart:math' as math;

import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:flutter/material.dart';

class GraphCard extends StatelessWidget {
  const GraphCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2DDD8)),
      ),
      child: child,
    );
  }
}

class RoastCurveChart extends StatelessWidget {
  const RoastCurveChart._({
    required this.lines,
    required this.legendItems,
    this.markers = const <RoastCurveMarker>[],
    this.chartHeight = 220,
    this.anchorSeriesToBottomLeft = false,
    this.clipToShortestDuration = false,
  });

  factory RoastCurveChart.detail({
    required RoastProfile profile,
  }) {
    final firstCrackTime = math.max(1.0, profile.duration * 0.72);
    final secondCrackTime = math.max(firstCrackTime + 0.5, profile.duration * 0.9);
    final drumStart = math.max(profile.tempStart + 110, 130);
    final drumEnd = math.max(profile.tempEnd + 18, drumStart + 10);

    return RoastCurveChart._(
      chartHeight: 240,
      lines: [
        RoastCurveLine(
          label: 'Temperatura del grano',
          color: const Color(0xFFB16A3A),
          duration: profile.duration,
          temperatureAt: (progress) {
            final eased = Curves.easeInOut.transform(progress);
            return profile.tempStart +
                (profile.tempEnd - profile.tempStart) * eased;
          },
        ),
        RoastCurveLine(
          label: 'Temperatura del tambor',
          color: const Color(0xFF9A3D3D),
          duration: profile.duration,
          dashed: true,
          temperatureAt: (progress) {
            final eased = 1 - math.pow(1 - progress, 2.1).toDouble();
            return drumStart + (drumEnd - drumStart) * eased;
          },
        ),
      ],
      markers: [
        RoastCurveMarker(
          label: 'First Crack (estimado)',
          color: const Color(0xFFF2A01B),
          time: math.min(firstCrackTime, profile.duration.toDouble()),
        ),
        RoastCurveMarker(
          label: 'Second Crack (estimado)',
          color: const Color(0xFFE84B3C),
          time: math.min(secondCrackTime, profile.duration.toDouble()),
        ),
      ],
      legendItems: const [
        RoastCurveLegendItem(
          label: 'Temperatura del grano',
          color: Color(0xFFB16A3A),
        ),
        RoastCurveLegendItem(
          label: 'Temperatura del tambor',
          color: Color(0xFF9A3D3D),
          dashed: true,
        ),
        RoastCurveLegendItem(
          label: 'First Crack (estimado)',
          color: Color(0xFFF2A01B),
          dashed: true,
        ),
        RoastCurveLegendItem(
          label: 'Second Crack (estimado)',
          color: Color(0xFFE84B3C),
          dashed: true,
        ),
      ],
    );
  }

  factory RoastCurveChart.comparison({
    required RoastProfile left,
    required RoastProfile right,
  }) {
    return RoastCurveChart._(
      chartHeight: 230,
      anchorSeriesToBottomLeft: true,
      clipToShortestDuration: true,
      lines: [
        RoastCurveLine.fromProfile(
          label: left.name,
          color: const Color(0xFF7F52C6),
          profile: left,
        ),
        RoastCurveLine.fromProfile(
          label: right.name,
          color: const Color(0xFFB25454),
          profile: right,
        ),
      ],
      legendItems: [
        RoastCurveLegendItem(
          label: left.name,
          color: const Color(0xFF7F52C6),
        ),
        RoastCurveLegendItem(
          label: right.name,
          color: const Color(0xFFB25454),
        ),
      ],
    );
  }

  final List<RoastCurveLine> lines;
  final List<RoastCurveMarker> markers;
  final List<RoastCurveLegendItem> legendItems;
  final double chartHeight;
  final bool anchorSeriesToBottomLeft;
  final bool clipToShortestDuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: chartHeight,
          child: CustomPaint(
            painter: _RoastCurvePainter(
              lines: lines,
              markers: markers,
              anchorSeriesToBottomLeft: anchorSeriesToBottomLeft,
              clipToShortestDuration: clipToShortestDuration,
            ),
          ),
        ),
        if (legendItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: legendItems
                .map(
                  (item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendSwatch(
                        color: item.color,
                        dashed: item.dashed,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: Color(0xFF575757),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class RoastCurveLine {
  const RoastCurveLine({
    required this.label,
    required this.color,
    required this.duration,
    required this.temperatureAt,
    this.dashed = false,
  });

  factory RoastCurveLine.fromProfile({
    required String label,
    required Color color,
    required RoastProfile profile,
  }) {
    return RoastCurveLine(
      label: label,
      color: color,
      duration: profile.duration,
      temperatureAt: (progress) {
        final eased = Curves.easeInOut.transform(progress);
        return profile.tempStart + (profile.tempEnd - profile.tempStart) * eased;
      },
    );
  }

  final String label;
  final Color color;
  final int duration;
  final double Function(double progress) temperatureAt;
  final bool dashed;
}

class RoastCurveMarker {
  const RoastCurveMarker({
    required this.label,
    required this.color,
    required this.time,
  });

  final String label;
  final Color color;
  final double time;
}

class RoastCurveLegendItem {
  const RoastCurveLegendItem({
    required this.label,
    required this.color,
    this.dashed = false,
  });

  final String label;
  final Color color;
  final bool dashed;
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({
    required this.color,
    required this.dashed,
  });

  final Color color;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 4,
      child: CustomPaint(
        painter: _LegendSwatchPainter(
          color: color,
          dashed: dashed,
        ),
      ),
    );
  }
}

class _LegendSwatchPainter extends CustomPainter {
  const _LegendSwatchPainter({
    required this.color,
    required this.dashed,
  });

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);

    if (dashed) {
      _drawDashedPath(canvas, path, paint);
      return;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LegendSwatchPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.dashed != dashed;
  }
}

class _RoastCurvePainter extends CustomPainter {
  const _RoastCurvePainter({
    required this.lines,
    required this.markers,
    required this.anchorSeriesToBottomLeft,
    required this.clipToShortestDuration,
  });

  final List<RoastCurveLine> lines;
  final List<RoastCurveMarker> markers;
  final bool anchorSeriesToBottomLeft;
  final bool clipToShortestDuration;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 48.0;
    const rightPadding = 12.0;
    const topPadding = 10.0;
    const bottomPadding = 34.0;

    final chartRect = Rect.fromLTWH(
      leftPadding,
      topPadding,
      size.width - leftPadding - rightPadding,
      size.height - topPadding - bottomPadding,
    );

    final axisPaint = Paint()
      ..color = const Color(0xFFBBB5AF)
      ..strokeWidth = 1.2;
    final gridPaint = Paint()
      ..color = const Color(0xFFF0ECE7)
      ..strokeWidth = 1;

    const gridSteps = 5;
    for (var i = 0; i <= gridSteps; i++) {
      final dx = chartRect.left + (chartRect.width / gridSteps) * i;
      final dy = chartRect.top + (chartRect.height / gridSteps) * i;
      canvas.drawLine(
        Offset(dx, chartRect.top),
        Offset(dx, chartRect.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(chartRect.left, dy),
        Offset(chartRect.right, dy),
        gridPaint,
      );
    }

    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      axisPaint,
    );

    final maxDuration = lines.map((item) => item.duration).fold<int>(1, math.max);
    final minDuration = lines
        .map((item) => item.duration)
        .fold<int>(lines.first.duration, math.min);
    final visibleDuration = clipToShortestDuration ? minDuration : maxDuration;

    var minTemp = double.infinity;
    var maxTemp = double.negativeInfinity;

    for (final line in lines) {
      for (var i = 0; i <= 32; i++) {
        final progress = i / 32;
        final temp = line.temperatureAt(progress);
        minTemp = math.min(minTemp, temp);
        maxTemp = math.max(maxTemp, temp);
      }
    }

    if (!minTemp.isFinite || !maxTemp.isFinite) {
      minTemp = 0;
      maxTemp = 50;
    }

    final tempPadding = ((maxTemp - minTemp) * 0.12).clamp(8, 24);
    final yMin = math.max(0, minTemp - tempPadding);
    final yMax = maxTemp + tempPadding;

    for (final marker in markers) {
      if (marker.time > visibleDuration) {
        continue;
      }

      final markerX =
          chartRect.left + (marker.time / visibleDuration) * chartRect.width;
      final markerPath = Path()
        ..moveTo(markerX, chartRect.top)
        ..lineTo(markerX, chartRect.bottom);
      final markerPaint = Paint()
        ..color = marker.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      _drawDashedPath(canvas, markerPath, markerPaint);
    }

    for (final line in lines) {
      final path = Path();
      const samples = 48;
      final effectiveDuration = math.min(
        line.duration.toDouble(),
        visibleDuration.toDouble(),
      );

      if (anchorSeriesToBottomLeft) {
        path.moveTo(chartRect.left, chartRect.bottom);
      }

      for (var i = 0; i <= samples; i++) {
        final progressOnVisibleDuration = i / samples;
        final time = effectiveDuration * progressOnVisibleDuration;
        final profileProgress = line.duration == 0
            ? 0.0
            : (time / line.duration).clamp(0.0, 1.0);
        final temp = line.temperatureAt(profileProgress);
        final x = chartRect.left + (time / visibleDuration) * chartRect.width;
        final y = chartRect.bottom -
            ((temp - yMin) / (yMax - yMin).clamp(1, double.infinity)) *
                chartRect.height;

        if (!anchorSeriesToBottomLeft && i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final paint = Paint()
        ..color = line.color
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;

      if (line.dashed) {
        _drawDashedPath(canvas, path, paint);
      } else {
        canvas.drawPath(path, paint);
      }
    }

    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    final axisStyle = const TextStyle(
      color: Color(0xFF7B7670),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    for (var i = 0; i <= gridSteps; i++) {
      final timeValue = (visibleDuration / gridSteps) * i;
      labelPainter.text = TextSpan(
        text: '${timeValue.toStringAsFixed(1)} min',
        style: axisStyle,
      );
      labelPainter.layout();
      final dx = chartRect.left + (chartRect.width / gridSteps) * i;
      labelPainter.paint(
        canvas,
        Offset(dx - (labelPainter.width / 2), chartRect.bottom + 6),
      );

      final tempValue = yMax - ((yMax - yMin) / gridSteps) * i;
      labelPainter.text = TextSpan(
        text: '${tempValue.toStringAsFixed(0)} °C',
        style: axisStyle,
      );
      labelPainter.layout();
      final dy = chartRect.top + (chartRect.height / gridSteps) * i;
      labelPainter.paint(
        canvas,
        Offset(chartRect.left - labelPainter.width - 6, dy - 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoastCurvePainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.markers != markers ||
        oldDelegate.anchorSeriesToBottomLeft != anchorSeriesToBottomLeft ||
        oldDelegate.clipToShortestDuration != clipToShortestDuration;
  }
}

void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    const dashLength = 8.0;
    const gapLength = 5.0;

    while (distance < metric.length) {
      final next = math.min(distance + dashLength, metric.length);
      canvas.drawPath(metric.extractPath(distance, next), paint);
      distance += dashLength + gapLength;
    }
  }
}
