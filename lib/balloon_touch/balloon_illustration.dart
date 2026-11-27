import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';

/// The balloon body's outline inside [rect], ported from the demo's
/// `BalloonBodyShape`. The popping rule tests touches against this path.
Path balloonBodyPath(Rect rect) {
  Offset p(double x, double y) =>
      Offset(rect.left + x * rect.width, rect.top + y * rect.height);
  Path curve(Path path, Offset c1, Offset c2, Offset to) =>
      path..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, to.dx, to.dy);

  final path = Path()..moveTo(p(0.5, 0).dx, p(0.5, 0).dy);
  curve(path, p(0.82, 0), p(1, 0.17), p(1, 0.42));
  curve(path, p(1, 0.7), p(0.64, 1), p(0.5, 1));
  curve(path, p(0.36, 1), p(0, 0.7), p(0, 0.42));
  curve(path, p(0, 0.17), p(0.18, 0), p(0.5, 0));
  return path..close();
}

/// Where the body sits inside a balloon drawn at [size]: centred, 1.25 times
/// as tall as [bodyWidth].
Rect balloonBodyRect(Size size, double bodyWidth) => Rect.fromCenter(
  center: size.center(Offset.zero),
  width: bodyWidth,
  height: bodyWidth * 1.25,
);

/// The shine's path along the body's upper left edge, inside the outline.
Path _shinePath(Rect rect) {
  Offset p(double x, double y) =>
      Offset(rect.left + x * rect.width, rect.top + y * rect.height);
  final start = p(0.13, 0.5), c = p(0.12, 0.12), end = p(0.5, 0.07);
  return Path()
    ..moveTo(start.dx, start.dy)
    ..quadraticBezierTo(c.dx, c.dy, end.dx, end.dy);
}

/// The balloon, in a cartoon style: outlined body with a shaded crescent and
/// glare, knot, wavy string and, unless [halo] is false, the halo. Body height is 1.25 × [bodyWidth], the knot is 0.085 ×
/// [bodyWidth], and the body is centred in a square 1.75 × [bodyWidth] wide;
/// the string hangs below it. While [motion] runs (0 to 1, repeating) the
/// edge shines and the string sways; both are paint-only, so the body,
/// the only part that pops, never moves.
class BalloonIllustration extends StatelessWidget {
  const BalloonIllustration({
    super.key,
    this.bodyWidth = 176,
    this.halo = true,
    this.pressed = false,
    this.label = 'Balloon illustration',
    this.motion,
  });

  final double bodyWidth;
  final bool halo, pressed;
  final String label;
  final Animation<double>? motion;

  @override
  Widget build(BuildContext context) {
    final side = bodyWidth * 1.75;
    return Semantics(
      label: label,
      child: CustomPaint(
        size: Size.square(side),
        painter: _BalloonPainter(
          bodyWidth,
          halo: halo,
          pressed: pressed,
          motion: motion,
        ),
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  _BalloonPainter(
    this.bodyWidth, {
    required this.halo,
    required this.pressed,
    this.motion,
  }) : super(repaint: motion);

  final double bodyWidth;
  final bool halo, pressed;
  final Animation<double>? motion;

  /// The share of each [motion] cycle the shine takes to cross the highlight.
  static const _shineShare = 0.4;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final w = bodyWidth, knot = bodyWidth * 0.085;
    final t = motion?.value;

    if (halo) {
      canvas.drawCircle(
        center,
        w * 1.65 / 2,
        Paint()..color = HandsColors.panel,
      );
      canvas.drawCircle(
        center,
        w * 1.65 / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = HandsColors.tealMid.withValues(alpha: 0.10),
      );
    }

    final body = balloonBodyRect(size, w);
    final bodyPath = balloonBodyPath(body);
    Offset at(double x, double y) =>
        Offset(body.left + x * body.width, body.top + y * body.height);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = HandsColors.balloonOutline;

    // A long wavy string. Paint-only, so near the bottom edge it may be cut off.
    final sway = t == null ? 0.0 : w * 0.05 * sin(2 * pi * t);
    final from = Offset(center.dx, body.bottom + knot), length = w * 0.55;
    canvas.drawPath(
      Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(
          from.dx + w * 0.14 + sway * 0.4,
          from.dy + length * 0.3,
          from.dx - w * 0.14 + sway,
          from.dy + length * 0.6,
          from.dx + w * 0.04 + sway * 1.4,
          from.dy + length,
        ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.028
        ..strokeCap = StrokeCap.round
        ..color = HandsColors.balloonOutline,
    );

    canvas.drawPath(
      bodyPath.shift(Offset(0, pressed ? 4 : 12)),
      Paint()
        ..color = HandsColors.redShadow.withValues(alpha: pressed ? 0.15 : 0.25)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          Shadow.convertRadiusToSigma(pressed ? 6 : 16),
        ),
    );
    canvas.drawPath(
      bodyPath,
      pressed
          ? (Paint()..color = HandsColors.redShadow)
          : (Paint()..shader = HandsGradients.balloon.createShader(body)),
    );
    // The darker crescent along the lower right.
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        bodyPath,
        bodyPath.shift(Offset(-w * 0.12, -w * 0.1)),
      ),
      Paint()
        ..color = HandsColors.redShadow.withValues(alpha: pressed ? 0.3 : 0.6),
    );
    // The glare: a tilted oval and a dot.
    final glare = Paint()
      ..color = HandsColors.white.withValues(alpha: pressed ? 0.3 : 0.85);
    canvas
      ..save()
      ..translate(at(0.33, 0.2).dx, at(0.33, 0.2).dy)
      ..rotate(-0.6)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: w * 0.3, height: w * 0.14),
        glare,
      )
      ..restore()
      ..drawCircle(at(0.19, 0.4), w * 0.045, glare);
    // The shine: a bright stretch that runs along the edge, then rests.
    if (t != null && t < _shineShare && !pressed) {
      final s = t / _shineShare;
      final metric = _shinePath(body).computeMetrics().first;
      final head = metric.length * 1.4 * s;
      canvas.drawPath(
        metric.extractPath(head - metric.length * 0.4, head),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w * 0.045
          ..color = HandsColors.white.withValues(alpha: 0.9 * sin(pi * s)),
      );
    }
    canvas.drawPath(bodyPath, outline);
    // The knot: a small trapezoid widening down from the body.
    final knotPath = Path()
      ..moveTo(center.dx - w * 0.04, body.bottom - w * 0.02)
      ..lineTo(center.dx + w * 0.04, body.bottom - w * 0.02)
      ..lineTo(center.dx + w * 0.08, body.bottom + knot)
      ..lineTo(center.dx - w * 0.08, body.bottom + knot)
      ..close();
    canvas
      ..drawPath(
        knotPath,
        Paint()..color = pressed ? HandsColors.redShadow : HandsColors.red,
      )
      ..drawPath(knotPath, outline);
  }

  @override
  bool shouldRepaint(_BalloonPainter old) =>
      old.bodyWidth != bodyWidth ||
      old.halo != halo ||
      old.pressed != pressed ||
      old.motion != motion;
}
