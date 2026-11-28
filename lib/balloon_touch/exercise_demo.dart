import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';
import 'balloon_illustration.dart';
import 'exercise_screen.dart';

/// The Exercise Demo, as in WATCH_HOW_DEMO_SPEC.md (white hand B) but with
/// the run's own balloon, Pop and Miss marker: a white hand touches the
/// balloon and it pops, then touches beside it, a Miss. It records nothing.
/// Without [onDone] it loops; with it, it plays once and then calls it.
/// Under reduce motion it holds the hand on the Miss for the same time.
class ExerciseDemo extends StatefulWidget {
  const ExerciseDemo({super.key, this.onDone});

  final VoidCallback? onDone;

  static const handKey = ValueKey('demo hand');
  static const popAt = Duration(milliseconds: 2160);
  static const missAt = Duration(milliseconds: 7190);
  static const length = Duration(milliseconds: 10600);

  @override
  State<ExerciseDemo> createState() => _ExerciseDemoState();
}

class _ExerciseDemoState extends State<ExerciseDemo>
    with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(
    vsync: this,
    duration: ExerciseDemo.length,
    // Runs its full length under reduce motion too, so Start and Pause wait
    // for it as they would otherwise.
    animationBehavior: AnimationBehavior.preserve,
  );

  @override
  void initState() {
    super.initState();
    final onDone = widget.onDone;
    if (onDone == null) {
      _clock.repeat();
    } else {
      _clock.forward().whenComplete(() {
        if (mounted) onDone();
      });
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final radius = BorderRadius.circular(HandsSizes.radiusStage);
    return Semantics(
      image: true,
      label:
          'Demonstration. A hand touches the balloon and it pops. Then a '
          'hand touches beside the balloon, which is a miss.',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: HandsGradients.stage,
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: LayoutBuilder(
            builder: (context, constraints) => AnimatedBuilder(
              animation: _clock,
              builder: (context, _) => _frame(
                constraints.biggest,
                // The hand on the Miss, beside the balloon.
                still
                    ? 7800
                    : _clock.value * ExerciseDemo.length.inMilliseconds,
                still: still,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The scene [ms] milliseconds in, laid out in the spec's 800 × 500 box.
  Widget _frame(Size area, double ms, {required bool still}) {
    final u = min(area.width / 800, area.height / 500);
    final origin = Offset(area.width - 800 * u, area.height - 500 * u) / 2;
    Offset at(double x, double y) => origin + Offset(x, y) * u;
    final balloon = at(336, 210);
    final missPoint = at(450, 225);
    final away = at(840, 625);
    final bodyWidth = 103 * u;
    final pop = ExerciseDemo.popAt.inMilliseconds.toDouble();
    final miss = ExerciseDemo.missAt.inMilliseconds.toDouble();
    final burst = HandsMotion.burst.inMilliseconds;

    double seg(double a, double b) => ((ms - a) / (b - a)).clamp(0.0, 1.0);
    // Keyframes (ms, value), eased between.
    double keys(List<(double, double)> k) {
      if (ms <= k.first.$1) return k.first.$2;
      for (var i = 1; i < k.length; i++) {
        final (t1, v1) = k[i];
        if (ms <= t1) {
          final (t0, v0) = k[i - 1];
          return v0 + (v1 - v0) * Curves.easeInOut.transform(seg(t0, t1));
        }
      }
      return k.last.$2;
    }

    // In to the target, hold, back out: scene 1 the balloon, scene 2 the Miss.
    final (target, inA, inB, outA, outB) = ms < 5000
        ? (balloon, 410.0, 1950.0, 3210.0, 4190.0)
        : (missPoint, 5440.0, 6970.0, 8510.0, 9490.0);
    final finger = Offset.lerp(
      Offset.lerp(away, target, Curves.easeInOutCubic.transform(seg(inA, inB))),
      away,
      Curves.easeInCubic.transform(seg(outA, outB)),
    )!;
    final press = keys([
      (1950, 1),
      (pop, 0.9),
      (2440, 1),
      (6970, 1),
      (miss, 0.9),
      (7460, 1),
    ]);
    final popped = ms >= pop && ms < 5020;
    final fadeOut = 1 - seg(9900, 10460);
    final balloonOpacity = ms < pop ? seg(0, 560) : seg(5020, 5580) * fadeOut;
    // Captions fade in and out; under reduce motion both stay, ✓ above ✗.
    final check = still ? 1.0 : seg(2370, 2650) * (1 - seg(4190, 4600));
    final cross = still ? 1.0 : seg(7390, 7670) * (1 - seg(9750, 10040));
    Widget caption(double opacity, {required bool ok}) => Opacity(
      opacity: opacity,
      child: Transform.translate(
        offset: Offset(0, 8 * (1 - opacity)),
        child: _Caption(ok: ok),
      ),
    );
    final wobble = keys([
      (miss, 0),
      (7370, 5),
      (7580, -4),
      (7790, 2),
      (8090, 0),
    ]);

    Widget place(Offset c, double side, Key key, Widget child) => Positioned(
      key: key,
      left: c.dx - side / 2,
      top: c.dy - side / 2,
      child: child,
    );
    final side = bodyWidth * 1.75;
    return Stack(
      children: [
        const SizedBox.expand(),
        if (!popped)
          place(
            balloon,
            side,
            const ValueKey('balloon'),
            Opacity(
              opacity: balloonOpacity,
              child: Transform.rotate(
                angle: wobble * pi / 180,
                // About the knot, at the body's bottom.
                alignment: const Alignment(0, 0.625 / 0.875),
                child: BalloonIllustration(
                  bodyWidth: bodyWidth,
                  halo: false,
                  pressed: ms >= 1950 && ms < pop,
                ),
              ),
            ),
          ),
        if (ms >= pop && ms < pop + burst)
          place(
            balloon,
            side,
            const ValueKey('burst'),
            PopBurst(bodyWidth: bodyWidth, onDone: () {}),
          ),
        if (ms >= miss && fadeOut > 0)
          place(
            missPoint,
            HandsSizes.missMarker,
            const ValueKey('miss'),
            Opacity(
              opacity: fadeOut,
              child: MissMarker(onDone: () {}),
            ),
          ),
        Positioned(
          left: finger.dx,
          top: finger.dy,
          child: CustomPaint(
            key: ExerciseDemo.handKey,
            // Smaller than the spec's hand, at the project lead's request.
            painter: _HandPainter(0.65 * u * press),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 20 * u,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: HandsSizes.gapS,
              children: [
                if (check > 0) caption(check, ok: true),
                if (cross > 0) caption(cross, ok: false),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A white pill: a ✓ or ✗ badge and what it means.
class _Caption extends StatelessWidget {
  const _Caption({required this.ok});

  final bool ok;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: HandsColors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: const [
        BoxShadow(
          color: HandsColors.shadow,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 18, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok ? HandsColors.tealMid : HandsColors.red,
            ),
            child: Icon(
              ok ? Icons.check_rounded : Icons.close_rounded,
              size: 18,
              color: HandsColors.white,
            ),
          ),
          Text(
            ok ? 'Touch the balloon to pop it' : 'Touching beside it is a miss',
            style: HandsText.demoCaption,
          ),
        ],
      ),
    ),
  );
}

/// The white cartoon hand from the spec, its fingertip at the origin.
class _HandPainter extends CustomPainter {
  const _HandPainter(this.scale);

  final double scale;

  // The hand's own colours, from the spec.
  static const _outline = Color(0xFF1E2A30);
  static const _shade = Color(0xFFE3E9EC);
  static const _backShade = Color(0xFFDCE4E8);
  static const _shadow = Color(0x40003A4E);

  static final _hand = Path()
    ..moveTo(-12, 12)
    ..arcToPoint(const Offset(12, 12), radius: const Radius.circular(12))
    ..lineTo(12, 58)
    ..arcToPoint(const Offset(30, 60), radius: const Radius.circular(9))
    ..arcToPoint(const Offset(45, 66), radius: const Radius.circular(9))
    ..arcToPoint(const Offset(58, 74), radius: const Radius.circular(8))
    ..lineTo(58, 100)
    ..cubicTo(58, 124, 44, 138, 22, 138)
    ..lineTo(4, 138)
    ..cubicTo(-14, 138, -24, 126, -28, 114)
    ..lineTo(-42, 88)
    ..arcToPoint(const Offset(-28, 80), radius: const Radius.circular(9))
    ..lineTo(-12, 94)
    ..close();
  static final _back = Path()
    ..moveTo(58, 90)
    ..cubicTo(58, 124, 44, 136, 22, 136)
    ..lineTo(28, 122)
    ..cubicTo(44, 118, 50, 106, 50, 90)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    Paint line(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas
      ..scale(scale)
      ..rotate(-20 * pi / 180)
      ..drawPath(
        _hand.shift(const Offset(0, 6)),
        Paint()
          ..color = _shadow
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawPath(_hand, Paint()..color = HandsColors.white)
      ..drawPath(_back, Paint()..color = _backShade)
      ..drawLine(const Offset(7, 16), const Offset(7, 54), line(_shade, 6))
      ..drawPath(
        Path()..addPolygon(const [
          Offset(-40, 90),
          Offset(-30, 110),
          Offset(-20, 112),
        ], false),
        line(_shade, 5),
      )
      ..drawPath(_hand, line(_outline, 4));
    for (final (x, y0, y1) in const [
      (12.0, 58.0, 74.0),
      (30.0, 60.0, 76.0),
      (45.0, 66.0, 78.0),
    ]) {
      canvas.drawLine(Offset(x, y0), Offset(x, y1), line(_outline, 3));
    }
  }

  @override
  bool shouldRepaint(_HandPainter old) => old.scale != scale;
}

/// The Exercise Demo full-screen, with Skip. It calls [onDone] once, on Skip
/// or when the demo ends, whichever comes first.
class ExerciseDemoScreen extends StatefulWidget {
  const ExerciseDemoScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<ExerciseDemoScreen> createState() => _ExerciseDemoScreenState();
}

class _ExerciseDemoScreenState extends State<ExerciseDemoScreen> {
  // The demo keeps playing while the route leaves, so it could end after Skip.
  var _done = false;

  void _finish() {
    // After back, the route is leaving and onDone would act on the one below.
    if (_done || !(ModalRoute.of(context)?.isCurrent ?? true)) return;
    _done = true;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: const BoxDecoration(gradient: HandsGradients.brand),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HandsSizes.stageInset),
          child: Column(
            spacing: HandsSizes.gap,
            children: [
              Expanded(child: ExerciseDemo(onDone: _finish)),
              OutlinedButton(
                onPressed: _finish,
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size(
                    HandsSizes.pauseButtonW,
                    HandsSizes.buttonSecondaryH,
                  ),
                  foregroundColor: HandsColors.white,
                  side: const BorderSide(
                    color: HandsColors.onTealOutline,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
                  ),
                ),
                child: Text('Skip', style: HandsText.completeButton),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
