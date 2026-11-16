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
  curve(path, p(1, 0.73), p(0.7, 1), p(0.5, 1));
  curve(path, p(0.3, 1), p(0, 0.73), p(0, 0.42));
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

Path _highlightPath(Rect rect) {
  Offset p(double x, double y) =>
      Offset(rect.left + x * rect.width, rect.top + y * rect.height);
  final start = p(0.53, 0.07), c1 = p(0.98, 0.14), c2 = p(0.99, 0.44);
  final mid = p(0.8, 0.74), c3 = p(0.86, 0.43), c4 = p(0.77, 0.21);
  return Path()
    ..moveTo(start.dx, start.dy)
    ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, mid.dx, mid.dy)
    ..cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, start.dx, start.dy)
    ..close();
}

Path _knotPath(Rect rect) {
  final midX = rect.center.dx, top = rect.top, h = rect.height;
  return Path()
    ..moveTo(midX, top)
    ..quadraticBezierTo(midX, top + h * 0.65, rect.right, top + h * 0.9)
    ..quadraticBezierTo(midX, top + h * 1.1, rect.left, top + h * 0.9)
    ..quadraticBezierTo(midX, top + h * 0.65, midX, top)
    ..close();
}

/// The demo's balloon: body, highlight, knot and, unless [halo] is false, the
/// halo. Body height is 1.25 × [bodyWidth], the knot is 0.085 × [bodyWidth],
/// and the body is centred in a square 1.75 × [bodyWidth] wide.
class BalloonIllustration extends StatelessWidget {
  const BalloonIllustration({
    super.key,
    this.bodyWidth = 176,
    this.halo = true,
    this.pressed = false,
    this.label = 'Balloon illustration',
  });

  final double bodyWidth;
  final bool halo, pressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final side = bodyWidth * 1.75;
    return Semantics(
      label: label,
      child: CustomPaint(
        size: Size.square(side),
        painter: _BalloonPainter(bodyWidth, halo: halo, pressed: pressed),
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  _BalloonPainter(this.bodyWidth, {required this.halo, required this.pressed});

  final double bodyWidth;
  final bool halo, pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final w = bodyWidth, knot = bodyWidth * 0.085;

    if (halo) {
      canvas.drawCircle(
        center,
        w * 1.65 / 2,
        Paint()..color = HandsColors.warmCream,
      );
      canvas.drawCircle(
        center,
        w * 1.65 / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = HandsColors.oliveGreen.withValues(alpha: 0.10),
      );
    }

    // Body and knot stack vertically, shifted down by half the knot as in the
    // demo, which leaves the body centred.
    final body = balloonBodyRect(size, w);
    final bodyPath = balloonBodyPath(body);

    canvas.drawPath(
      bodyPath.shift(Offset(0, pressed ? 2 : 6)),
      Paint()
        ..color = HandsColors.charcoal.withValues(alpha: pressed ? 0.08 : 0.16)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          Shadow.convertRadiusToSigma(pressed ? 3 : 9),
        ),
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = pressed ? HandsColors.oliveGreen : HandsColors.forestSage,
    );
    canvas.drawPath(
      _highlightPath(body),
      Paint()
        ..color = pressed
            ? HandsColors.ivory.withValues(alpha: 0.22)
            : HandsColors.oliveGreen,
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = pressed ? 3 : 1
        ..color = HandsColors.forestSage,
    );
    canvas.drawPath(
      _knotPath(Rect.fromLTWH(center.dx - knot / 2, body.bottom, knot, knot)),
      Paint()..color = HandsColors.forestSage,
    );
  }

  @override
  bool shouldRepaint(_BalloonPainter old) =>
      old.bodyWidth != bodyWidth || old.halo != halo || old.pressed != pressed;
}
