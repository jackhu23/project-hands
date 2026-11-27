import 'package:flutter/material.dart';

import '../theme.dart';

/// Static illustrations for the two Exercises that are not playable yet.
class ExerciseArt extends StatelessWidget {
  const ExerciseArt({super.key, required this.tracing});

  final bool tracing;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: 220,
      height: 150,
      child: CustomPaint(painter: _ExercisePainter(tracing)),
    ),
  );
}

class _ExercisePainter extends CustomPainter {
  const _ExercisePainter(this.tracing);

  final bool tracing;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw in a fixed design space, scaled to the available illustration area.
    canvas.save();
    canvas.scale(size.width / 220, size.height / 150);
    final fill = Paint()..color = HandsColors.forestSage;
    final stroke = Paint()
      ..color = HandsColors.oliveGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    if (tracing) {
      final path = Path()
        ..moveTo(27, 86)
        ..cubicTo(80, 53, 163, 49, 193, 100);
      _dashed(canvas, path, stroke);
      canvas.drawCircle(const Offset(27, 86), 10, fill);
      canvas.drawCircle(const Offset(193, 100), 10, fill);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(24, 55, 48, 48),
          const Radius.circular(13),
        ),
        fill,
      );
      final arrow = Path()
        ..moveTo(88, 79)
        ..lineTo(121, 79)
        ..moveTo(110, 67)
        ..lineTo(123, 79)
        ..lineTo(110, 91);
      canvas.drawPath(arrow, stroke..color = HandsColors.forestSage);
      final target = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(145, 51, 56, 56),
            const Radius.circular(13),
          ),
        );
      _dashed(canvas, target, stroke..color = HandsColors.oliveGreen);
    }
    canvas.restore();
  }

  void _dashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      for (double start = 0; start < metric.length; start += 17) {
        canvas.drawPath(metric.extractPath(start, start + 10), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ExercisePainter oldDelegate) =>
      oldDelegate.tracing != tracing;
}
