import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../database.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/line_icon.dart';
import '../widgets/loading_section.dart';
import 'exercise_demo.dart';
import 'exercise_screen.dart';
import 'my_progress_tab.dart';
import 'session.dart';

const _minBalloons = 1, _maxBalloons = 30;

/// The Balloon Touch hub. It opens on Practice (Watch how, run setup and
/// Start); My progress shows how the Patient's runs went.
class BalloonTouchHub extends StatefulWidget {
  const BalloonTouchHub({
    super.key,
    required this.database,
    required this.patientId,
    this.initialTab = 0,
  });

  final HandsDatabase database;
  final String patientId;

  /// 0 for Practice, 1 for My progress.
  final int initialTab;

  @override
  State<BalloonTouchHub> createState() => _BalloonTouchHubState();
}

class _BalloonTouchHubState extends State<BalloonTouchHub>
    with SingleTickerProviderStateMixin {
  /// Null until the remembered Difficulty Level loads; Start waits for it so
  /// a run never starts at a level the Patient can't see.
  int? _level;
  int _balloons = _minBalloons;
  late int _tab = widget.initialTab;

  /// Fades the tab shown in; it starts shown.
  late final _tabFade = AnimationController(
    vsync: this,
    duration: HandsMotion.tabFade,
    value: 1,
  );

  @override
  void dispose() {
    _tabFade.dispose();
    super.dispose();
  }

  void _showTab(int tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    MediaQuery.disableAnimationsOf(context)
        ? _tabFade.value = 1
        : _tabFade.forward(from: 0);
  }

  Future<int> _loadLevel() async =>
      await widget.database.lastDifficultyLevel() ?? minDifficultyLevel;

  void _start() {
    // Created once here, not in the route builder, which can run again.
    // The app's messenger outlives the hub, so Go again runs can use it.
    final messenger = ScaffoldMessenger.of(context);
    final session = Session(
      patientId: widget.patientId,
      balloonCount: _balloons,
      difficultyLevel: _level!,
      onChange: (s) => widget.database.saveSession(s).catchError((Object _) {
        // A failed save mid-run is retried by the next one, and a SnackBar
        // there would cover the stage, so only the run's last save tells.
        if (s.status case SessionStatus.running || SessionStatus.paused) return;
        messenger
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                "Couldn't save this run. Please tell your therapist.",
              ),
            ),
          );
      }),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ExerciseScreen(session: session, database: widget.database),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        GradientHeader(
          eyebrow: 'EXERCISE',
          title: 'Balloon Touch',
          tabs: const ['Practice', 'My progress'],
          selectedTab: _tab,
          onTab: _showTab,
        ),
        Expanded(
          // Practice stays mounted, so its level never reloads behind an
          // enabled Start; My progress is built afresh to load the latest runs.
          // shortcut: only the incoming tab fades through; the outgoing one
          // goes at once. Switch to PageTransitionSwitcher if Practice ever
          // keeps no state.
          child: FadeThroughTransition(
            animation: _tabFade,
            secondaryAnimation: kAlwaysDismissedAnimation,
            fillColor: HandsColors.white,
            child: IndexedStack(
              index: _tab,
              sizing: StackFit.expand,
              children: [
                _practice(),
                if (_tab == 1)
                  MyProgressTab(database: widget.database)
                else
                  const SizedBox(),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _practice() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        HandsSizes.pagePadH,
        HandsSizes.hubPadTop,
        HandsSizes.pagePadH,
        HandsSizes.hubPadBottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: HandsSizes.gap,
        children: [
          const Expanded(child: _WatchHowCard()),
          Expanded(child: _setupCard()),
        ],
      ),
    ),
  );

  Widget _setupCard() => Container(
    padding: const EdgeInsets.all(HandsSizes.panelPad),
    decoration: BoxDecoration(
      color: HandsColors.white,
      border: Border.all(color: HandsColors.border, width: HandsSizes.borderW),
      borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _oneLine(Text('STEP 2 · SET UP YOUR RUN', style: HandsText.eyebrow)),
        const SizedBox(height: HandsSizes.panelGap),
        _oneLine(Text('Difficulty Level', style: HandsText.sectionTitle)),
        const SizedBox(height: HandsSizes.controlGap),
        LoadingSection<int>(
          load: _loadLevel,
          placeholder: minDifficultyLevel,
          onLoaded: (level) => setState(() => _level = level),
          builder: (_, _) => _LevelPicker(
            selected: _level ?? minDifficultyLevel,
            onChanged: (level) => setState(() => _level = level),
          ),
        ),
        const SizedBox(height: HandsSizes.panelGap),
        Row(
          spacing: HandsSizes.controlGap,
          children: [
            Expanded(
              child: _oneLine(Text('Balloons', style: HandsText.sectionTitle)),
            ),
            _Stepper(
              value: _balloons,
              onStep: (step) => setState(
                () => _balloons = (_balloons + step).clamp(
                  _minBalloons,
                  _maxBalloons,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        _StartButton(onPressed: _level == null ? null : _start),
      ],
    ),
  );
}

/// Step 1: the Exercise Demo, always looping.
class _WatchHowCard extends StatelessWidget {
  const _WatchHowCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(HandsSizes.panelPad),
    decoration: BoxDecoration(
      color: HandsColors.panel,
      borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: HandsSizes.gapS,
      children: [
        _oneLine(Text('STEP 1 · WATCH HOW', style: HandsText.eyebrow)),
        // Loops while the card shows; tickers stop when a route covers it.
        const Expanded(child: ExerciseDemo()),
      ],
    ),
  );
}

/// Scales a one-line label down rather than wrapping it on narrow tablets.
Widget _oneLine(Widget text) => FittedBox(
  fit: BoxFit.scaleDown,
  alignment: Alignment.centerLeft,
  child: text,
);

class _LevelPicker extends StatelessWidget {
  const _LevelPicker({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    spacing: HandsSizes.controlGap,
    children: [
      for (var n = minDifficultyLevel; n <= maxDifficultyLevel; n++)
        Expanded(child: _levelButton(n)),
    ],
  );

  Widget _levelButton(int n) {
    final on = n == selected;
    final colour = on ? HandsColors.white : HandsColors.tealLink;
    final radius = BorderRadius.circular(HandsSizes.radiusCard);
    return Semantics(
      button: true,
      selected: on,
      label: 'Difficulty Level $n',
      onTap: () => onChanged(n),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: on ? HandsGradients.brandButton : null,
          color: on ? null : HandsColors.white,
          border: Border.all(
            color: on ? HandsColors.tealDeep : HandsColors.borderControl,
            width: HandsSizes.controlBorderW,
          ),
          borderRadius: radius,
          boxShadow: on
              ? const [
                  BoxShadow(
                    color: HandsColors.shadowStrong,
                    blurRadius: HandsSizes.selectedShadowBlur,
                    offset: Offset(0, HandsSizes.selectedShadowDy),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onChanged(n),
            borderRadius: radius,
            child: SizedBox(
              height: HandsSizes.levelButtonH,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: HandsSizes.gapXS / 2,
                children: [
                  ZoneDiagram(level: n, color: colour),
                  Text(
                    '$n',
                    style: HandsText.levelNumber.copyWith(color: colour),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The nested Zone ellipses, with the Zones beyond [level] drawn faint.
class ZoneDiagram extends StatelessWidget {
  const ZoneDiagram({super.key, required this.level, required this.color});

  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(HandsSizes.zoneDiagramW, HandsSizes.zoneDiagramH),
    painter: _ZonePainter(level, color),
  );
}

class _ZonePainter extends CustomPainter {
  _ZonePainter(this.level, this.color);

  final int level;
  final Color color;

  // Radii from the mockup's 56 × 40 viewBox: outer ring is Zone 4.
  static const _rings = [(26.0, 18.0, 4), (18.0, 12.5, 3), (10.0, 7.0, 2)];

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    for (final (rx, ry, zone) in _rings) {
      canvas.drawOval(
        Rect.fromCenter(center: centre, width: rx * 2, height: ry * 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = color.withValues(alpha: zone <= level ? 1 : 0.25),
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: centre, width: 8, height: 6),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_ZonePainter old) =>
      old.level != level || old.color != color;
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onStep});

  final int value;

  /// Steps rather than values, so taps in one frame all count.
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: HandsSizes.controlGap,
    children: [
      _button(Icons.remove, 'Fewer balloons', value > _minBalloons, -1),
      SizedBox(
        width: HandsSizes.stepperValueW,
        child: Semantics(
          label: '$value balloons',
          liveRegion: true,
          excludeSemantics: true,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: HandsText.stepperValue,
          ),
        ),
      ),
      _button(Icons.add, 'More balloons', value < _maxBalloons, 1),
    ],
  );

  Widget _button(IconData icon, String label, bool enabled, int step) =>
      IconButton(
        onPressed: enabled ? () => onStep(step) : null,
        tooltip: label,
        iconSize: HandsSizes.stepperIcon,
        style: IconButton.styleFrom(
          fixedSize: const Size.square(HandsSizes.stepperButton),
          backgroundColor: HandsColors.white,
          disabledBackgroundColor: HandsColors.white,
          foregroundColor: HandsColors.tealLink,
          disabledForegroundColor: HandsColors.tealLink.withValues(alpha: 0.3),
          side: const BorderSide(
            color: HandsColors.borderStrong,
            width: HandsSizes.controlBorderW,
          ),
        ),
        icon: Icon(icon),
      );
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(HandsSizes.radiusCard);
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: HandsGradients.brandButton,
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: HandsColors.shadowStrong,
              blurRadius: HandsSizes.shadowBlur,
              offset: Offset(0, HandsSizes.shadowDy),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: SizedBox(
              height: HandsSizes.buttonPrimaryH,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: HandsSizes.gapS,
                children: [
                  Text('Start', style: HandsText.button),
                  lineIcon(arrowIcon, HandsColors.white, HandsSizes.startIcon),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
