import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Action;

import '../database.dart';
import '../theme.dart';
import 'balloon_illustration.dart';
import 'progress_screen.dart';
import 'session.dart';

/// The Balloon Touch Exercise Run, ported from the demo's `ExerciseScreen`.
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({
    super.key,
    required this.session,
    required this.database,
    this.onHome,
  });

  final Session session;
  final HandsDatabase database;
  final VoidCallback? onHome;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  Session get _session => widget.session;
  final _balloonKey = GlobalKey();
  bool _returningHome = false;

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Leaving the foreground pauses a running Exercise Run, as in the demo.
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        if (state != AppLifecycleState.resumed) _pause();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  bool get _paused => _session.status == SessionStatus.paused;

  // Like the demo, pausing drops the balloon and any touch on it.
  void _pause() => setState(_session.pause);

  void _resume() => setState(_session.resume);

  /// Home and Finish: pause and open the progress page. Quirk carried over:
  /// Finish doesn't end the Session.
  Future<void> _leave() async {
    _pause();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgressScreen(
          session: _session,
          database: widget.database,
          onHome: widget.onHome == null ? null : _returnHome,
        ),
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

  // Keep the paused Session alive when the progress page returns to Home.
  void _returnHome() {
    _returningHome = true;
    _session.pause();
    widget.onHome?.call();
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
    setState(
      () => _session.touchUp(
        event.pointer,
        _input(event),
        onBody: _onBody(event.position),
      ),
    );
    if (_session.status == SessionStatus.completed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ProgressScreen(
            session: _session,
            database: widget.database,
            onHome: widget.onHome,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = _session.exerciseRun;
    final pressed = _session.pressingBalloon;
    // The system back gesture abandons the run, so it is saved as stopped.
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && !_returningHome) _session.stop();
      },
      child: Scaffold(
        backgroundColor: HandsColors.warmCream,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              spacing: 20,
              children: [
                _header(run),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: HandsColors.warmCream,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    // Only touches in the play area are Actions, and their
                    // positions are relative to its top-left.
                    child: Listener(
                      onPointerDown: _down,
                      onPointerMove: _move,
                      onPointerUp: _up,
                      onPointerCancel: (event) =>
                          setState(() => _session.touchCancel(event.pointer)),
                      behavior: HitTestBehavior.translucent,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Like the demo, a balloon appears once the area has a size.
                          if (_paused) return _pausedPanel();
                          _session.presentNextTrial(constraints.biggest);
                          final trial = run.activeTrial;
                          if (trial == null) return const SizedBox.expand();
                          final side = trial.bodyWidth * 1.75;
                          return Stack(
                            children: [
                              Positioned(
                                left: trial.center.dx - side / 2,
                                top: trial.center.dy - side / 2,
                                child: _Pulse(
                                  holding: pressed,
                                  child: BalloonIllustration(
                                    key: _balloonKey,
                                    bodyWidth: trial.bodyWidth,
                                    halo: false,
                                    pressed: pressed,
                                    label: 'Balloon',
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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

  Widget _pausedPanel() => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: HandsColors.ivory,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          Text('Paused', style: handsText(28, HandsColors.forestSage)),
          FilledButton(
            onPressed: _resume,
            style: FilledButton.styleFrom(
              backgroundColor: HandsColors.oliveGreen,
              minimumSize: const Size(140, 56),
            ),
            child: Text('Resume', style: handsText(22, HandsColors.ivory)),
          ),
        ],
      ),
    ),
  );

  // Quirk carried over: the gear does nothing.
  Widget _header(ExerciseRun run) => Row(
    spacing: 24,
    children: [
      Flexible(
        child: Text(
          'H.A.N.D.S',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: handsText(24, HandsColors.forestSage),
        ),
      ),
      SizedBox(
        width: 220,
        child: Column(
          spacing: 8,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Your progress',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: handsText(17),
                  ),
                ),
                const Spacer(),
                Text(
                  '${run.completedTrials} / ${run.balloonCount}',
                  style: handsText(17),
                ),
              ],
            ),
            LinearProgressIndicator(
              value: run.completedTrials / run.balloonCount,
              color: HandsColors.forestSage,
              backgroundColor: HandsColors.sandBeige,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
      const Spacer(),
      FilledButton.tonal(
        onPressed: _leave,
        style: FilledButton.styleFrom(
          backgroundColor: HandsColors.oliveGreen.withValues(alpha: 0.15),
          minimumSize: const Size(0, 44),
        ),
        child: Text('Finish', style: handsText(17, HandsColors.oliveGreen)),
      ),
      IconButton(
        onPressed: _leave,
        tooltip: 'Home',
        iconSize: 24,
        color: HandsColors.oliveGreen,
        style: IconButton.styleFrom(fixedSize: const Size.square(48)),
        icon: const Icon(Icons.home),
      ),
      IconButton(
        onPressed: _paused ? null : _pause,
        tooltip: 'Pause',
        color: HandsColors.oliveGreen,
        style: IconButton.styleFrom(minimumSize: const Size.square(44)),
        icon: const Icon(Icons.pause),
      ),
      IconButton(
        onPressed: () {},
        tooltip: 'Settings',
        color: HandsColors.oliveGreen,
        icon: const Icon(Icons.settings),
      ),
    ],
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
