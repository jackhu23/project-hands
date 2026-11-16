import 'package:flutter/material.dart';

import '../theme.dart';
import 'balloon_illustration.dart';
import 'progress_screen.dart';
import 'session.dart';

/// The Balloon Touch Exercise Run, ported from the demo's `ExerciseScreen`.
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key, required this.session});

  final Session session;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  Session get _session => widget.session;

  void _pop(Trial trial) {
    setState(() => _session.completeTrial(trial));
    if (_session.status == SessionStatus.completed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ProgressScreen(session: _session),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = _session.exerciseRun;
    return Scaffold(
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Like the demo, a balloon appears once the area has a size.
                      _session.presentNextTrial(constraints.biggest);
                      final trial = run.activeTrial;
                      if (trial == null) return const SizedBox.expand();
                      final side = trial.bodyWidth * 1.75;
                      return Stack(
                        children: [
                          Positioned(
                            left: trial.center.dx - side / 2,
                            top: trial.center.dy - side / 2,
                            child: _PoppableBalloon(
                              key: ObjectKey(trial),
                              bodyWidth: trial.bodyWidth,
                              onPopped: () => _pop(trial),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Finish, Home, Pause and the gear are shown only; they do something in #13.
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
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: HandsColors.oliveGreen.withValues(alpha: 0.15),
          minimumSize: const Size(0, 44),
        ),
        child: Text('Finish', style: handsText(17, HandsColors.oliveGreen)),
      ),
      IconButton(
        onPressed: () {},
        tooltip: 'Home',
        iconSize: 24,
        color: HandsColors.oliveGreen,
        style: IconButton.styleFrom(fixedSize: const Size.square(48)),
        icon: const Icon(Icons.home),
      ),
      IconButton(
        onPressed: () {},
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

/// A balloon that pops when an Action both starts and ends on its body.
/// Only the first pointer counts; a cancelled pointer does nothing.
class _PoppableBalloon extends StatefulWidget {
  const _PoppableBalloon({
    super.key,
    required this.bodyWidth,
    required this.onPopped,
  });

  final double bodyWidth;
  final VoidCallback onPopped;

  @override
  State<_PoppableBalloon> createState() => _PoppableBalloonState();
}

class _PoppableBalloonState extends State<_PoppableBalloon> {
  int? _pointer;

  bool _onBody(Offset local) {
    final side = widget.bodyWidth * 1.75;
    return balloonBodyPath(balloonBodyRect(Size.square(side), widget.bodyWidth))
        .contains(local);
  }

  void _down(PointerDownEvent event) {
    if (_pointer != null || !_onBody(event.localPosition)) return;
    setState(() => _pointer = event.pointer);
  }

  void _up(PointerUpEvent event) {
    if (event.pointer != _pointer) return;
    setState(() => _pointer = null);
    if (_onBody(event.localPosition)) widget.onPopped();
  }

  void _cancel(PointerCancelEvent event) {
    if (event.pointer == _pointer) setState(() => _pointer = null);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _down,
    onPointerUp: _up,
    onPointerCancel: _cancel,
    child: BalloonIllustration(
      bodyWidth: widget.bodyWidth,
      halo: false,
      pressed: _pointer != null,
      label: 'Balloon',
    ),
  );
}
