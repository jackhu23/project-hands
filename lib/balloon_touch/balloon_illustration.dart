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

/// The still balloon from the setup screen: body, highlight, knot and halo.
/// Body height is 1.25 × [bodyWidth] and the knot is 0.085 × [bodyWidth].
class BalloonIllustration extends StatelessWidget {
  const BalloonIllustration({super.key, this.bodyWidth = 176});

  final double bodyWidth;

  @override
  Widget build(BuildContext context) {
    final side = bodyWidth * 1.75;
    return Semantics(
      label: 'Balloon illustration',
      child: CustomPaint(
        size: Size.square(side),
        painter: _BalloonPainter(bodyWidth),
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  _BalloonPainter(this.bodyWidth);

  final double bodyWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final w = bodyWidth, h = bodyWidth * 1.25, knot = bodyWidth * 0.085;

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

    // Body and knot stack vertically, shifted down by half the knot as in the demo.
    final top = center.dy - (h + knot) / 2 + knot / 2;
    final body = Rect.fromLTWH(center.dx - w / 2, top, w, h);
    final bodyPath = balloonBodyPath(body);

    canvas.drawPath(
      bodyPath.shift(const Offset(0, 6)),
      Paint()
        ..color = HandsColors.charcoal.withValues(alpha: 0.16)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          Shadow.convertRadiusToSigma(9),
        ),
    );
    canvas.drawPath(bodyPath, Paint()..color = HandsColors.forestSage);
    canvas.drawPath(
      _highlightPath(body),
      Paint()..color = HandsColors.oliveGreen,
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = HandsColors.forestSage,
    );
    canvas.drawPath(
      _knotPath(Rect.fromLTWH(center.dx - knot / 2, body.bottom, knot, knot)),
      Paint()..color = HandsColors.forestSage,
    );
  }

  @override
  bool shouldRepaint(_BalloonPainter old) => old.bodyWidth != bodyWidth;
}
