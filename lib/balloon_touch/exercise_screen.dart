import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../database.dart';
import '../theme.dart';
import 'balloon_illustration.dart';
import 'progress_screen.dart';
import 'session.dart';

/// The Balloon Touch Exercise Run, on the branded stage.
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({
    super.key,
    required this.session,
    required this.database,
  });

  final Session session;
  final HandsDatabase database;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen>
    with SingleTickerProviderStateMixin {
  Session get _session => widget.session;
  final _balloonKey = GlobalKey();

  late final AppLifecycleListener _lifecycle;

  /// Drives the balloon's shine and string sway; stopped under reduce motion.
  late final _life = AnimationController(
    vsync: this,
    duration: HandsMotion.balloonLife,
  );
  bool _reduceMotion = false;

  /// Where the last Pop's burst plays; the next balloon waits for it.
  Offset? _burst;

  /// Where the last Miss lifted off, and a count so each Miss restarts it.
  Offset? _miss;
  var _misses = 0;

  @override
  void initState() {
    super.initState();
    // The screen stays on, and the system bars out of reach, for the run.
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Leaving the foreground pauses a running Exercise Run, as in the demo.
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        if (state != AppLifecycleState.resumed) _pause();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _reduceMotion ? _life.stop() : _life.repeat();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _life.dispose();
    _lifecycle.dispose();
    super.dispose();
  }

  bool get _paused => _session.status == SessionStatus.paused;

  // Like the demo, pausing drops the balloon and any touch on it. The burst
  // and ring go too, so the next balloon never waits on a burst not shown.
  void _pause() => setState(() {
    _session.pause();
    _burst = _miss = null;
  });

  void _resume() => setState(_session.resume);

  /// Home and Finish: pause and open the progress page. Quirk carried over:
  /// Finish doesn't end the Session.
  Future<void> _leave() async {
    _pause();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProgressScreen(session: _session, database: widget.database),
      ),
    );
    if (!mounted) return;
    // Start New Session stopped it: carry on back to setup.
    if (_session.status == SessionStatus.stopped) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  bool _onBody(Offset global) {
    final box = _balloonKey.currentContext?.findRenderObject() as RenderBox?;
    final trial = _session.exerciseRun.activeTrial;
    if (box == null || trial == null) return false;
    return balloonBodyPath(balloonBodyRect(box.size, trial.bodyWidth))
        .contains(box.globalToLocal(global));
  }

  static TouchInput _input(PointerEvent event) => (
    timeStamp: event.timeStamp,
    position: event.localPosition,
    pressure: event.pressure,
    kind: switch (event.kind) {
      PointerDeviceKind.stylus ||
      PointerDeviceKind.invertedStylus => TouchKind.stylus,
      PointerDeviceKind.mouse || PointerDeviceKind.trackpad => TouchKind.mouse,
      _ => TouchKind.finger,
    },
  );

  // The Session labels each Action and applies the popping rule.
  void _down(PointerDownEvent event) {
    if (event.buttons & kPrimaryButton == 0) return;
    setState(
      () => _session.touchDown(
        event.pointer,
        _input(event),
        onBody: _onBody(event.position),
      ),
    );
  }

  void _move(PointerMoveEvent event) =>
      _session.touchMove(event.pointer, _input(event));

  void _up(PointerUpEvent event) {
    if (_session.status != SessionStatus.running) return;
    final trial = _session.exerciseRun.activeTrial;
    setState(() {
      switch (_session.touchUp(
        event.pointer,
        _input(event),
        onBody: _onBody(event.position),
      )) {
        case ActionOutcome.pop:
          _burst = trial!.center;
        case ActionOutcome.miss:
          _miss = event.localPosition;
          _misses++;
        case ActionOutcome.overlappingTouch || null:
      }
    });
    if (_session.status == SessionStatus.completed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              ProgressScreen(session: _session, database: widget.database),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pressed = _session.pressingBalloon;
    final radius = BorderRadius.circular(HandsSizes.radiusStage);
    // The system back gesture abandons the run, so it is saved as stopped.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _session.stop();
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: HandsGradients.brand),
          child: SafeArea(
            child: Column(
              children: [
                _band(_session.exerciseRun),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      HandsSizes.stageInset,
                      0,
                      HandsSizes.stageInset,
                      HandsSizes.stageInset,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: HandsGradients.stage,
                        borderRadius: radius,
                      ),
                      child: ClipRRect(
                        borderRadius: radius,
                        // Only touches in the play area are Actions, and their
                        // positions are relative to its top-left.
                        child: Listener(
                          onPointerDown: _down,
                          onPointerMove: _move,
                          onPointerUp: _up,
                          onPointerCancel: (event) => setState(
                            () => _session.touchCancel(event.pointer),
                          ),
                          behavior: HitTestBehavior.translucent,
                          child: LayoutBuilder(
                            builder: (context, constraints) =>
                                _play(constraints.biggest, pressed),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _play(Size area, bool pressed) {
    if (_paused) return _pausedPanel();
    // Like the demo, a balloon appears once the area has a size.
    if (_burst == null) _session.presentNextTrial(area);
    final trial = _session.exerciseRun.activeTrial;
    Widget at(Offset c, double side, Widget child) =>
        Positioned(left: c.dx - side / 2, top: c.dy - side / 2, child: child);
    return Stack(
      children: [
        const SizedBox.expand(),
        if (trial != null)
          at(
            trial.center,
            trial.bodyWidth * 1.75,
            _Pulse(
              holding: pressed,
              child: BalloonIllustration(
                key: _balloonKey,
                bodyWidth: trial.bodyWidth,
                halo: false,
                pressed: pressed,
                label: 'Balloon',
                motion: _reduceMotion ? null : _life,
              ),
            ),
          ),
        if (_burst case final c?)
          at(
            c,
            HandsSizes.burst,
            PopBurst(onDone: () => setState(() => _burst = null)),
          ),
        if (_miss case final c?)
          at(
            c,
            HandsSizes.missRing,
            MissRing(
              key: ValueKey(_misses),
              onDone: () => setState(() => _miss = null),
            ),
          ),
      ],
    );
  }

  Widget _pausedPanel() => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: HandsColors.panel,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          Text('Paused', style: HandsText.sectionTitle),
          FilledButton(
            onPressed: _resume,
            style: FilledButton.styleFrom(
              backgroundColor: HandsColors.tealMid,
              minimumSize: const Size(140, 56),
            ),
            child: Text(
              'Resume',
              style: HandsText.buttonSmall.copyWith(color: HandsColors.white),
            ),
          ),
        ],
      ),
    ),
  );

  /// The logo, the progress pill and Pause. Home and Finish stay until the
  /// Pause overlay replaces them.
  Widget _band(ExerciseRun run) => SizedBox(
    height: HandsSizes.runBandH,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: HandsSizes.runBandPadH),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/logos/carle-health-white.png',
                height: HandsSizes.runLogoH,
                semanticLabel: 'Carle Health',
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: HandsSizes.runPillW,
                ),
                child: _progressPill(run),
              ),
            ),
          ),
          // The app is landscape only; this keeps a portrait window from
          // overflowing.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: _controls(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _controls() => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: HandsSizes.gapXS,
    children: [
      for (final (tooltip, icon) in [
        ('Home', Icons.home),
        ('Finish', Icons.flag),
      ])
        IconButton(
          onPressed: _leave,
          tooltip: tooltip,
          color: HandsColors.white,
          style: IconButton.styleFrom(
            fixedSize: const Size.square(HandsSizes.minTouch),
          ),
          icon: Icon(icon),
        ),
      FilledButton(
        onPressed: _paused ? null : _pause,
        style: FilledButton.styleFrom(
          backgroundColor: HandsColors.white,
          foregroundColor: HandsColors.tealDeep,
          disabledBackgroundColor: HandsColors.onTealLine,
          minimumSize: const Size(0, HandsSizes.runPillH),
          padding: const EdgeInsets.symmetric(horizontal: HandsSizes.pausePadH),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: HandsSizes.controlGap,
          children: [
            const Icon(Icons.pause, size: HandsSizes.pauseIcon),
            Text('Pause', style: HandsText.buttonSmall),
          ],
        ),
      ),
    ],
  );

  Widget _progressPill(ExerciseRun run) => Container(
    height: HandsSizes.runPillH,
    padding: const EdgeInsets.symmetric(horizontal: HandsSizes.runPillPadH),
    decoration: BoxDecoration(
      color: HandsColors.white,
      borderRadius: BorderRadius.circular(HandsSizes.radiusPill),
      boxShadow: const [
        BoxShadow(
          color: HandsColors.shadow,
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      spacing: HandsSizes.panelGap,
      children: [
        Text(
          '${run.completedTrials} of ${run.balloonCount}',
          style: HandsText.runCount,
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(HandsSizes.radiusPill),
            child: Container(
              height: HandsSizes.runBarH,
              color: HandsColors.panel,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: run.completedTrials / run.balloonCount,
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: HandsGradients.brandButton,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Plays once over [duration], giving [builder] the progress 0 to 1, then
/// calls [onDone].
class _Once extends StatefulWidget {
  const _Once({
    required this.duration,
    required this.onDone,
    required this.builder,
  });

  final Duration duration;
  final VoidCallback onDone;
  final Widget Function(BuildContext, double) builder;

  @override
  State<_Once> createState() => _OnceState();
}

class _OnceState extends State<_Once> with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    _clock.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _clock,
    builder: (context, _) => widget.builder(context, _clock.value),
  );
}

/// A Pop's burst: a red ring and eight teal rays that grow from 0.4 to 1.5
/// and fade out over 500 ms. Under reduce motion it only fades.
class PopBurst extends StatelessWidget {
  const PopBurst({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return _Once(
      duration: HandsMotion.burst,
      onDone: onDone,
      builder: (context, t) {
        final eased = Curves.easeOut.transform(t);
        return Opacity(
          opacity: 1 - eased,
          child: Transform.scale(
            scale: still ? 1 : 0.4 + 1.1 * eased,
            child: const CustomPaint(
              size: Size.square(HandsSizes.burst),
              painter: _BurstPainter(),
            ),
          ),
        );
      },
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // In the mockup's 200 × 200 box: ring r46, rays from 70 to 88 out.
    final k = size.width / 200, c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      46 * k,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 * k
        ..color = HandsColors.red,
    );
    final ray = Paint()
      ..strokeWidth = 6 * k
      ..strokeCap = StrokeCap.round
      ..color = HandsColors.tealBright;
    for (var i = 0; i < 8; i++) {
      final d = Offset.fromDirection(i * pi / 4);
      canvas.drawLine(c + d * 70 * k, c + d * 88 * k, ray);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => false;
}

/// A Miss's faint grey ring at the lift-off point, fading over 300 ms. Never
/// red, so a Miss doesn't read as a mistake.
class MissRing extends StatelessWidget {
  const MissRing({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => _Once(
    duration: HandsMotion.missRing,
    onDone: onDone,
    builder: (context, t) => Opacity(
      opacity: 1 - t,
      child: Container(
        width: HandsSizes.missRing,
        height: HandsSizes.missRing,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: HandsColors.inkMuted.withValues(alpha: 0.35),
            width: 3,
          ),
        ),
      ),
    ),
  );
}

/// The demo's pulse: scale `0.98 + 0.05 × (sin(t·π/2) + 1) / 2`, t in seconds.
/// It holds while [holding] and stays at 1.0 with reduce motion on. Leaving
/// the foreground pauses the run, which takes the balloon off screen. The
/// popping rule hit-tests through the transform, so it tests against the
/// drawn (scaled) shape.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.holding, required this.child});

  final bool holding;
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(_Pulse old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (_reduceMotion || widget.holding) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _clock,
    child: widget.child,
    builder: (context, child) {
      final t = _clock.value * 4;
      final scale = _reduceMotion
          ? 1.0
          : 0.98 + 0.05 * (sin(t * pi / 2) + 1) / 2;
      return Transform.scale(scale: scale, child: child);
    },
  );
}
