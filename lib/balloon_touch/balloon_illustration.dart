import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../theme.dart';

// The art from balloon-pop-spec.md, in its SVG units: the body spans
// x 22–178 and y 20–205.
final _body = Path()
  ..moveTo(100, 20)
  ..cubicTo(150, 20, 178, 62, 178, 110)
  ..cubicTo(178, 160, 140, 200, 100, 205)
  ..cubicTo(60, 200, 22, 160, 22, 110)
  ..cubicTo(22, 62, 50, 20, 100, 20)
  ..close();
final _sheen = Path()
  ..moveTo(100, 26)
  ..cubicTo(62, 28, 34, 62, 32, 106)
  ..cubicTo(40, 72, 66, 42, 100, 34)
  ..close();
final _shade = Path()
  ..moveTo(100, 205)
  ..cubicTo(140, 200, 178, 160, 178, 110)
  ..cubicTo(178, 68, 156, 36, 126, 24)
  ..cubicTo(148, 46, 162, 80, 160, 114)
  ..cubicTo(157, 158, 132, 192, 100, 205)
  ..close();
final _knot = Path()
  ..addPolygon(const [
    Offset(91, 216),
    Offset(109, 216),
    Offset(103, 203),
    Offset(97, 203),
  ], true);
final _string = Path()
  ..moveTo(100, 214)
  ..cubicTo(86, 240, 114, 262, 100, 290)
  ..cubicTo(86, 318, 96, 330, 104, 352);

/// Where the float's tilt turns: the knot.
const _pivot = Offset(100, 206);

/// The balloon body's outline inside [rect].
Path balloonBodyPath(Rect rect) {
  final sx = rect.width / 156, sy = rect.height / 185;
  return _body.transform(
    (Matrix4.diagonal3Values(
      sx,
      sy,
      1,
    )..setTranslationRaw(rect.left - 22 * sx, rect.top - 20 * sy, 0)).storage,
  );
}

/// Where the body sits inside a balloon drawn at [size]: centred, 1.25 times
/// as tall as [bodyWidth].
Rect balloonBodyRect(Size size, double bodyWidth) => Rect.fromCenter(
  center: size.center(Offset.zero),
  width: bodyWidth,
  height: bodyWidth * 1.25,
);

/// Whether [point] is on the body ([body] at rest) anywhere the idle float
/// can carry it. The whole reach pops, so it doesn't matter where the
/// balloon is in its float when it is touched.
bool balloonReachContains(Rect body, Offset point) {
  final p = Offset(
    22 + (point.dx - body.left) * 156 / body.width,
    20 + (point.dy - body.top) * 185 / body.height,
  );
  // The float's extremes and midpoints (see _float); the gaps between
  // samples are far under a pixel.
  for (final dx in const [-4.0, 0.0, 4.0]) {
    for (final dy in const [-8.0, -2.0, 4.0]) {
      for (final degrees in const [-3.0, 0.0, 3.0]) {
        final q = p - Offset(dx, dy) - _pivot, r = -degrees * pi / 180;
        final atRest =
            Offset(
              q.dx * cos(r) - q.dy * sin(r),
              q.dx * sin(r) + q.dy * cos(r),
            ) +
            _pivot;
        if (_body.contains(atRest)) return true;
      }
    }
  }
  return false;
}

/// 0 to 1 and back every 2 × [half] seconds, as CSS's `ease-in-out infinite
/// alternate`.
double _wave(double s, double half) {
  final p = (s / half) % 2;
  return Curves.easeInOut.transform(p < 1 ? p : 2 - p);
}

/// The idle float at [s] seconds: bob, drift, then tilt about the knot.
void _float(Canvas canvas, double s) => canvas
  ..translate(
    lerpDouble(-4, 4, _wave(s, 3.1))!,
    lerpDouble(4, -8, _wave(s, 1.7))!,
  )
  ..translate(_pivot.dx, _pivot.dy)
  ..rotate(lerpDouble(-3, 3, _wave(s, 2.3))! * pi / 180)
  ..translate(-_pivot.dx, -_pivot.dy);

/// Moves [canvas] into the art's SVG units for a balloon drawn at [size],
/// floated to [s] seconds, or at rest if [s] is null.
void enterBalloonArt(Canvas canvas, Size size, double bodyWidth, double? s) {
  final body = balloonBodyRect(size, bodyWidth);
  canvas
    ..translate(body.left, body.top)
    ..scale(body.width / 156, body.height / 185)
    ..translate(-22, -20);
  if (s != null) _float(canvas, s);
}

/// The string and knot, in the art's units. At [s] seconds the string
/// trails the float's tilt.
void paintBalloonTail(Canvas canvas, double? s) {
  final trail = s == null
      ? 0.0
      : lerpDouble(2.5, -2.5, _wave(max(0, s - 0.35), 2.3))! * pi / 180;
  canvas
    ..save()
    ..translate(100, 214)
    ..rotate(trail)
    ..translate(-100, -214)
    ..drawPath(
      _string,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..color = HandsColors.balloonString,
    )
    ..restore()
    ..drawPath(_knot, Paint()..color = HandsColors.balloonDark);
}

/// The body, in the art's units: base, left sheen, shade crescent and two
/// highlights. [pressed] darkens it.
void paintBalloonBody(Canvas canvas, {bool pressed = false}) {
  canvas.drawPath(
    _body,
    Paint()..color = pressed ? HandsColors.balloonDark : HandsColors.balloon,
  );
  if (!pressed) {
    canvas.drawPath(
      _sheen,
      Paint()..color = HandsColors.balloonLight.withValues(alpha: 0.55),
    );
  }
  canvas
    ..drawPath(_shade, Paint()..color = HandsColors.balloonDark)
    ..save()
    ..translate(64, 68)
    ..rotate(28 * pi / 180)
    ..drawOval(
      Rect.fromCenter(center: Offset.zero, width: 22, height: 54),
      Paint()..color = HandsColors.white.withValues(alpha: pressed ? 0.4 : 0.8),
    )
    ..restore()
    ..drawCircle(
      const Offset(56, 114),
      6,
      Paint()
        ..color = HandsColors.white.withValues(alpha: pressed ? 0.3 : 0.55),
    );
}

/// The cartoon balloon from balloon-pop-spec.md: body with sheen, shade and
/// highlights, knot, string and, unless [halo] is false, the halo. Body
/// height is 1.25 × [bodyWidth], centred in a square 1.75 × [bodyWidth]
/// wide; the string hangs below it. [motion], in seconds, drives the idle
/// float. The float is paint-only: the box never moves, and the hit area is
/// the float's whole reach ([balloonReachContains]).
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

  @override
  void paint(Canvas canvas, Size size) {
    if (halo) {
      final center = size.center(Offset.zero);
      canvas
        ..drawCircle(
          center,
          bodyWidth * 1.65 / 2,
          Paint()..color = HandsColors.panel,
        )
        ..drawCircle(
          center,
          bodyWidth * 1.65 / 2,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = HandsColors.tealMid.withValues(alpha: 0.10),
        );
    }
    final s = motion?.value;
    canvas.save();
    enterBalloonArt(canvas, size, bodyWidth, s);
    paintBalloonTail(canvas, s);
    paintBalloonBody(canvas, pressed: pressed);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BalloonPainter old) =>
      old.bodyWidth != bodyWidth ||
      old.halo != halo ||
      old.pressed != pressed ||
      old.motion != motion;
}
