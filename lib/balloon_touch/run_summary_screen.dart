import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/line_icon.dart';
import '../widgets/loading_section.dart';
import 'exercise_screen.dart';
import 'history_screen.dart';
import 'hub_screen.dart';
import 'metrics.dart';
import 'session.dart';

/// A Run summary and where each Miss lifted off, as a share of the play
/// area's width and height.
typedef _Loaded = ({RunSummary summary, List<({int trial, Offset at})> misses});

/// Shown while the run loads, in the shape of a real one.
final _placeholder = (
  summary: (
    run: ExerciseRunRow(
      id: '',
      sessionId: '',
      exercise: '',
      difficultyLevel: 1,
      balloonCount: 10,
      areaWidth: 16,
      areaHeight: 9,
      startedAt: DateTime(2026),
      endedAt: DateTime(2026),
      outcome: RunOutcome.completed,
    ),
    completed: true,
    pops: 10,
    misses: 0,
    overlapping: 0,
    accuracy: 1.0,
    reactionTime: const Duration(seconds: 1),
    duration: const Duration(seconds: 30),
    trials: [
      for (var i = 1; i <= 10; i++)
        (
          number: i,
          zone: 1,
          position: Offset(i / 11, 0.5),
          reactionTime: Duration(milliseconds: 500 + 100 * i),
          misses: 0,
        ),
    ],
    fastest: null,
    levelAccuracy: null,
    levelReactionTime: null,
  ),
  misses: const <({int trial, Offset at})>[],
);

String _plural(int n, String one, [String? many]) =>
    '$n ${n == 1 ? one : many ?? '${one}s'}';

/// One Exercise Run explained: its result, stat cards, Reaction Time per
/// balloon, where each balloon and Miss was, and a detail card. Loaded by
/// [runId] from [database], so it works the same from a run and from My
/// progress.
class RunSummaryScreen extends StatefulWidget {
  const RunSummaryScreen({
    super.key,
    required this.database,
    required this.runId,
    this.from,
    this.backLabel = 'Back to my progress',
  });

  final HandsDatabase database;
  final String runId;

  /// Where the header Back goes, read out; it pops when [from] is null.
  final String backLabel;

  /// The Session whose run just ended, when arriving straight from it. Only
  /// then does the screen offer Go again and play its entry motion.
  final Session? from;

  @override
  State<RunSummaryScreen> createState() => _RunSummaryScreenState();
}

class _RunSummaryScreenState extends State<RunSummaryScreen>
    with SingleTickerProviderStateMixin {
  // The banner, stat cards, chart, map, detail card and buttons each rise
  // in one stagger after the last.
  static const _items = 6;
  static final _length =
      HandsMotion.summaryStagger * (_items - 1) + HandsMotion.summaryRise;

  late final _entry = AnimationController(
    vsync: this,
    duration: _length,
    value: 1,
  );
  ExerciseRunRow? _run;

  /// The selected Trial's number.
  int? _selected;

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  Future<_Loaded?> _load() async {
    final runs = await widget.database.runs();
    final r = runs.where((r) => r.run.id == widget.runId).firstOrNull;
    if (r == null) return null;
    final area = Size(r.run.areaWidth, r.run.areaHeight);
    return (
      summary: summarizeRun(r, runs),
      misses: [
        for (final m in await widget.database.missLiftOffs(r.run.id))
          (
            trial: m.trial,
            at: Offset(m.at.dx / area.width, m.at.dy / area.height),
          ),
      ],
    );
  }

  void _onLoaded(_Loaded? loaded) {
    setState(() => _run = loaded?.summary.run);
    if (loaded != null &&
        widget.from != null &&
        !MediaQuery.disableAnimationsOf(context)) {
      _entry.forward(from: 0);
    }
  }

  // Always 12-hour, whatever the tablet's setting.
  String _time(ExerciseRunRow run) => DateFormat.jm().format(run.startedAt);

  String? get _subtitle => _run == null
      ? null
      : '${DateFormat('d MMM y').format(_run!.startedAt)} · ${_time(_run!)}';

  String? get _headerLabel => _run == null
      ? null
      : '${_run!.exercise} results, '
            '${DateFormat('d MMMM y').format(_run!.startedAt)}, ${_time(_run!)}';

  /// To My progress: popped back to when opened from there, or a fresh hub
  /// on that tab after a run.
  void _back() {
    final from = widget.from;
    if (from == null) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => BalloonTouchHub(
          database: widget.database,
          patientId: from.patientId,
          initialTab: 1,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _goAgain() {
    final from = widget.from!;
    final run = from.exerciseRun;
    // Created once here, not in the route builder, which can run again.
    final next = Session(
      patientId: from.patientId,
      balloonCount: run.balloonCount,
      difficultyLevel: run.difficultyLevel,
      onChange: from.onChange,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            ExerciseScreen(session: next, database: widget.database),
      ),
    );
  }

  void _toggle(int number) =>
      setState(() => _selected = _selected == number ? null : number);

  @override
  Widget build(BuildContext context) => PopScope(
    // The system back goes where the header's Back does.
    canPop: widget.from == null,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _back();
    },
    child: Scaffold(
      body: Column(
        children: [
          GradientHeader(
            eyebrow: 'RUN SUMMARY',
            title: _run == null ? '' : '${_run!.exercise} results',
            subtitle: _subtitle,
            semanticsLabel: _headerLabel,
            backLabel: widget.backLabel,
            onBack: _back,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  HandsSizes.pagePadH,
                  HandsSizes.summaryPadTop,
                  HandsSizes.pagePadH,
                  HandsSizes.summaryPadBottom,
                ),
                child: LoadingSection<_Loaded?>(
                  load: _load,
                  placeholder: _placeholder,
                  onLoaded: _onLoaded,
                  builder: (_, loaded) =>
                      loaded == null ? _notFound() : _body(loaded),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _notFound() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: HandsSizes.gapS,
      children: [
        Text(
          "This run couldn't be found.",
          style: HandsText.body.copyWith(color: HandsColors.inkMuted),
        ),
        OutlinedButton(
          onPressed: _back,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, HandsSizes.minTouch),
            side: const BorderSide(color: HandsColors.borderStrong),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
            ),
          ),
          child: Text('Back to my progress', style: HandsText.buttonSmall),
        ),
      ],
    ),
  );

  Animation<double> _interval(Duration start, Duration length, Curve curve) =>
      _entry.drive(
        CurveTween(
          curve: Interval(
            start.inMicroseconds / _length.inMicroseconds,
            (start + length).inMicroseconds / _length.inMicroseconds,
            curve: curve,
          ),
        ),
      );

  /// Item [i] fades in and rises 12 px, [i] staggers after the first.
  Widget _rise(int i, Widget child) {
    final t = _interval(
      HandsMotion.summaryStagger * i,
      HandsMotion.summaryRise,
      Curves.easeOut,
    );
    return AnimatedBuilder(
      animation: t,
      builder: (_, child) => Opacity(
        opacity: t.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t.value)),
          child: child,
        ),
      ),
      child: child,
    );
  }

  Widget _body(_Loaded loaded) {
    final s = loaded.summary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: HandsSizes.gap,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: HandsSizes.summaryGap,
            children: [
              _rise(0, _banner(s)),
              _rise(1, _stats(s)),
              Expanded(child: _rise(2, _chart(s))),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: HandsSizes.summaryGap,
            children: [
              Expanded(child: _rise(3, _map(s, loaded.misses))),
              _rise(4, _detail(s)),
              _rise(5, _buttons()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _banner(RunSummary s) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: HandsSizes.bannerPadH,
      vertical: HandsSizes.bannerPadV,
    ),
    decoration: BoxDecoration(
      gradient: HandsGradients.brandButton,
      borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
      boxShadow: const [
        BoxShadow(
          color: HandsColors.shadowStrong,
          blurRadius: HandsSizes.statShadowBlur,
          offset: Offset(0, HandsSizes.statShadowDy),
        ),
      ],
    ),
    child: Row(
      spacing: HandsSizes.summaryGap,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BALLOONS POPPED', style: HandsText.eyebrowOnTeal),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${s.pops} of ${s.run.balloonCount}',
                  style: HandsText.bannerValue,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Semantics(
            label:
                'Level ${s.run.difficultyLevel}. '
                'Run ${s.completed ? 'complete' : 'stopped'}. '
                '${spokenDuration(s.duration)} total.',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: HandsSizes.gapXS,
              children: [
                // Stacks the pills when the banner is narrow.
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: HandsSizes.gapXS,
                  runSpacing: HandsSizes.gapXS,
                  children: [
                    Container(
                      height: HandsSizes.summaryPillH,
                      padding: const EdgeInsets.symmetric(
                        horizontal: HandsSizes.summaryPillPadH,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: HandsColors.onTealFill,
                        border: Border.all(color: HandsColors.onTealLine),
                        borderRadius: BorderRadius.circular(
                          HandsSizes.radiusPill,
                        ),
                      ),
                      child: Text(
                        'LEVEL ${s.run.difficultyLevel}',
                        style: HandsText.summaryPill.copyWith(
                          color: HandsColors.white,
                        ),
                      ),
                    ),
                    Container(
                      height: HandsSizes.summaryPillH,
                      padding: const EdgeInsets.symmetric(
                        horizontal: HandsSizes.summaryPillPadH,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: HandsColors.pinkPill,
                        borderRadius: BorderRadius.circular(
                          HandsSizes.radiusPill,
                        ),
                      ),
                      child: Text(
                        s.completed ? 'RUN COMPLETE' : 'RUN STOPPED',
                        style: HandsText.summaryPill,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${formatDuration(s.duration)} total',
                  style: HandsText.bannerMeta,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _stats(RunSummary s) {
    final level = 'Level ${s.run.difficultyLevel} average';
    Widget card(String label, String value, String sub) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HandsSizes.summaryStatPadH,
          vertical: HandsSizes.summaryStatPadV,
        ),
        decoration: BoxDecoration(
          color: HandsColors.panel,
          borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: HandsText.statLabel),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: HandsText.summaryStat),
            ),
            Text(sub, style: HandsText.statSub),
          ],
        ),
      ),
    );
    // Neutral numbers: never coloured against the average.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: HandsSizes.summaryGap,
        children: [
          card(
            'ACCURACY',
            formatAccuracy(s.accuracy),
            [
              [
                _plural(s.pops, 'pop'),
                _plural(s.misses, 'miss', 'misses'),
                if (s.overlapping > 0)
                  _plural(
                    s.overlapping,
                    'overlapping touch',
                    'overlapping touches',
                  ),
              ].join(' · '),
              if (s.levelAccuracy case final a?) '$level ${formatAccuracy(a)}',
            ].join('\n'),
          ),
          card(
            'REACTION TIME',
            formatSeconds(s.reactionTime),
            [
              'Average per balloon',
              if (s.levelReactionTime case final rt?)
                '$level ${formatSeconds(rt)}',
            ].join('\n'),
          ),
        ],
      ),
    );
  }

  String _label(SummaryTrial t) => [
    'Balloon ${t.number}',
    if (t.reactionTime case final rt?)
      '${(rt.inMicroseconds / 1e6).toStringAsFixed(2)} seconds',
    if (t.zone case final z?) 'zone $z',
    if (t.reactionTime == null)
      'not popped'
    else if (t.misses == 0)
      'first try'
    else
      _plural(t.misses, 'miss', 'misses'),
  ].join(', ');

  /// A Trial's tap target: labelled, selectable, dimmed while another is
  /// selected.
  Widget _target(SummaryTrial t, double dimTo, Widget child) {
    final selected = _selected == t.number;
    return Semantics(
      label: _label(t),
      button: true,
      selected: selected,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggle(t.number),
        child: AnimatedOpacity(
          opacity: _selected == null || selected ? 1 : dimTo,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : HandsMotion.select,
          child: child,
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    Widget? trailing,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: HandsSizes.summaryCardPadH,
      vertical: HandsSizes.summaryCardPadV,
    ),
    decoration: BoxDecoration(
      color: HandsColors.white,
      border: Border.all(color: HandsColors.border, width: HandsSizes.borderW),
      borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: HandsSizes.summaryCardGap,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: HandsText.summaryCardTitle)),
            // Shares the row rather than squeezing the title to a strip.
            if (trailing != null) Flexible(child: trailing),
          ],
        ),
        Expanded(child: child),
      ],
    ),
  );

  Widget _chart(RunSummary s) {
    final grow = _interval(
      HandsMotion.summaryStagger * 2,
      HandsMotion.barsGrow,
      Curves.easeOutCubic,
    );
    final tallest = s.trials
        .map((t) => t.reactionTime)
        .nonNulls
        .fold(Duration.zero, (a, b) => a > b ? a : b);
    return _card(
      title: 'Reaction time per balloon',
      trailing: Text('Tap a bar or a balloon', style: HandsText.hint),
      child: LayoutBuilder(
        builder: (context, box) {
          final slot = box.maxWidth / s.trials.length;
          final width = max(
            HandsSizes.barMinW,
            min(
              HandsSizes.barMaxW,
              slot - min(HandsSizes.barMaxGap, slot * 0.25),
            ),
          );
          final showValues = width >= HandsSizes.barLabelMinW;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final t in s.trials)
                Expanded(
                  child: _target(
                    t,
                    0.4,
                    Column(
                      spacing: HandsSizes.gapXS,
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (_, plot) => _bar(
                              t,
                              width,
                              showValues,
                              (plot.maxHeight - HandsSizes.barValueH) *
                                  (tallest == Duration.zero
                                      ? 0
                                      : (t.reactionTime ?? Duration.zero)
                                                .inMicroseconds /
                                            tallest.inMicroseconds),
                              grow,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('${t.number}', style: HandsText.barLabel),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _bar(
    SummaryTrial t,
    double width,
    bool showValue,
    double height,
    Animation<double> grow,
  ) {
    final rt = t.reactionTime;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: HandsSizes.barValueH,
          child: rt == null
              ? Text('–', style: HandsText.barValue)
              : showValue
              ? Text(
                  (rt.inMilliseconds / 1000).toStringAsFixed(1),
                  style: HandsText.barValue,
                )
              : null,
        ),
        if (rt != null)
          AnimatedBuilder(
            animation: grow,
            builder: (_, _) => Container(
              key: ValueKey('bar ${t.number}'),
              width: width,
              height: max(0, height * grow.value),
              decoration: BoxDecoration(
                gradient: _selected == t.number
                    ? HandsGradients.barRed
                    : HandsGradients.barTeal,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(HandsSizes.barRadius),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _map(RunSummary s, List<({int trial, Offset at})> misses) => _card(
    title: 'Where the balloons were',
    child: Column(
      spacing: HandsSizes.gapXS,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (_, box) {
              final aspect = s.run.areaWidth / s.run.areaHeight;
              final width = [
                HandsSizes.mapMaxW,
                box.maxWidth,
                box.maxHeight * aspect,
              ].reduce(min);
              return Center(
                child: BalloonMap(
                  size: Size(width, width / aspect),
                  misses: [
                    for (final m in misses)
                      (
                        at: m.at,
                        // The selected balloon's Misses stand out; others dim.
                        child: Opacity(
                          opacity: _selected == null || _selected == m.trial
                              ? 1
                              : 0.5,
                          child: MissRing(highlighted: _selected == m.trial),
                        ),
                      ),
                  ],
                  dots: [
                    for (final t in s.trials)
                      if (t.position case final at?)
                        (at: at, child: _target(t, 0.5, _dot(t))),
                  ],
                ),
              );
            },
          ),
        ),
        Wrap(
          spacing: HandsSizes.summaryGap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _legend(
              const DecoratedBox(
                decoration: BoxDecoration(
                  color: HandsColors.tealMid,
                  shape: BoxShape.circle,
                ),
              ),
              'Pop',
            ),
            _legend(const MissRing(), 'Miss'),
          ],
        ),
      ],
    ),
  );

  Widget _legend(Widget swatch, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 6,
    children: [
      SizedBox.square(dimension: HandsSizes.legendSwatch, child: swatch),
      Flexible(child: Text(text, style: HandsText.legend)),
    ],
  );

  Widget _dot(SummaryTrial t) {
    final selected = _selected == t.number;
    final popped = t.reactionTime != null;
    final number = Text(
      '${t.number}',
      style: popped
          ? HandsText.dotNumber
          : HandsText.dotNumber.copyWith(color: HandsColors.inkMuted),
    );
    return Center(
      child: SizedBox.square(
        dimension: HandsSizes.mapDot,
        child: popped
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: selected ? HandsColors.red : HandsColors.tealMid,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HandsColors.white,
                    width: selected ? 3 : 2,
                  ),
                  boxShadow: selected
                      ? const [
                          BoxShadow(color: HandsColors.red, spreadRadius: 3),
                        ]
                      : null,
                ),
                child: Center(child: number),
              )
            : CustomPaint(
                painter: _DashedCircle(
                  selected ? HandsColors.red : HandsColors.inkMuted,
                  selected ? 3 : 2,
                ),
                child: Center(child: number),
              ),
      ),
    );
  }

  Widget _detail(RunSummary s) {
    final t = s.trials.where((t) => t.number == _selected).firstOrNull;
    final String title, text;
    if (t != null) {
      title = 'BALLOON ${t.number}';
      text = [
        if (t.reactionTime case final rt?) '${formatSeconds(rt)} to pop',
        if (t.zone case final z?) 'Zone $z',
        if (t.reactionTime == null)
          'not popped · run stopped'
        else if (t.misses == 0)
          'popped first try'
        else
          '${_plural(t.misses, 'miss', 'misses')} before the pop',
      ].join(' · ');
    } else {
      title = 'THIS RUN';
      final f = s.fastest;
      text = f == null
          ? 'No balloons popped this time.'
          : 'Your fastest balloon was number ${f.number} '
                '(${formatSeconds(f.reactionTime)})'
                '${f.zone == 1 ? ', near the centre' : ', in zone ${f.zone}'}.';
    }
    return GestureDetector(
      onTap: () => setState(() => _selected = null),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HandsSizes.summaryCardPadH,
          vertical: HandsSizes.gapS,
        ),
        decoration: BoxDecoration(
          color: HandsColors.pinkCard,
          borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(title, style: HandsText.noteLabel),
            Text(text, style: HandsText.note),
          ],
        ),
      ),
    );
  }

  Widget _buttons() {
    final radius = BorderRadius.circular(HandsSizes.radiusCard);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: HandsSizes.summaryButtonGap,
      children: [
        Semantics(
          button: true,
          child: Material(
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: Ink(
              height: HandsSizes.summaryPrimaryH,
              decoration: const BoxDecoration(
                gradient: HandsGradients.brandButton,
              ),
              child: InkWell(
                onTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: HandsSizes.controlGap,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Back to today's plan",
                          style: HandsText.completeButton,
                        ),
                      ),
                    ),
                    lineIcon(arrowIcon, HandsColors.white, HandsSizes.ctaIcon),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.from != null)
          OutlinedButton(
            onPressed: _goAgain,
            style: OutlinedButton.styleFrom(
              fixedSize: const Size.fromHeight(HandsSizes.summaryGoAgainH),
              side: const BorderSide(
                color: HandsColors.borderStrong,
                width: HandsSizes.controlBorderW,
              ),
              shape: RoundedRectangleBorder(borderRadius: radius),
            ),
            child: Text('Go again', style: HandsText.goAgain),
          ),
      ],
    );
  }
}

/// The run's play area scaled to [size]: the game's Zone outlines, a dot
/// for each balloon shown, and a ring where each Miss lifted off. [dots] and
/// [misses] are placed as shares of the width and height.
class BalloonMap extends StatelessWidget {
  const BalloonMap({
    super.key,
    required this.size,
    required this.dots,
    required this.misses,
  });

  final Size size;
  final List<({Offset at, Widget child})> dots, misses;

  @override
  Widget build(BuildContext context) {
    Offset place(Offset at) => Offset(at.dx * size.width, at.dy * size.height);
    return SizedBox.fromSize(
      size: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: HandsGradients.stage,
                borderRadius: BorderRadius.circular(HandsSizes.mapRadius),
              ),
              child: const CustomPaint(painter: _ZonesPainter()),
            ),
          ),
          for (final m in misses)
            Positioned(
              left: place(m.at).dx - HandsSizes.missRing / 2,
              top: place(m.at).dy - HandsSizes.missRing / 2,
              width: HandsSizes.missRing,
              height: HandsSizes.missRing,
              child: m.child,
            ),
          for (final d in dots)
            Positioned(
              left: place(d.at).dx - HandsSizes.mapDotTarget / 2,
              top: place(d.at).dy - HandsSizes.mapDotTarget / 2,
              width: HandsSizes.mapDotTarget,
              height: HandsSizes.mapDotTarget,
              child: d.child,
            ),
        ],
      ),
    );
  }
}

/// Where a Miss lifted off: grey, not red, since a Miss is information.
/// [highlighted] marks the selected balloon's Misses in the selection red.
class MissRing extends StatelessWidget {
  const MissRing({super.key, this.highlighted = false});

  final bool highlighted;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.fromBorderSide(
        highlighted
            ? const BorderSide(color: HandsColors.red, width: 3)
            : const BorderSide(color: HandsColors.missRing, width: 2),
      ),
    ),
  );
}

void _dashed(Canvas canvas, Path path, Paint paint) {
  for (final metric in path.computeMetrics()) {
    for (var d = 0.0; d < metric.length; d += 9) {
      canvas.drawPath(metric.extractPath(d, min(d + 4, metric.length)), paint);
    }
  }
}

/// Dashed Zone outlines from the game's own geometry; Zone 4 is outside.
class _ZonesPainter extends CustomPainter {
  const _ZonesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = zoneEllipseSpans.length - 1; i >= 0; i--) {
      final oval = Path()
        ..addOval(
          Rect.fromCenter(
            center: size.center(Offset.zero),
            width: size.width * zoneEllipseSpans[i],
            height: size.height * zoneEllipseSpans[i],
          ),
        );
      final inner = i < zoneEllipseSpans.length - 1;
      if (inner) {
        canvas.drawPath(
          oval,
          Paint()..color = HandsColors.tealMid.withValues(alpha: 0.06),
        );
      }
      _dashed(
        canvas,
        oval,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = HandsSizes.borderW
          ..color = inner
              ? HandsColors.borderStrong
              : HandsColors.borderControl,
      );
    }
  }

  @override
  bool shouldRepaint(_ZonesPainter old) => false;
}

/// A balloon not popped: white with a dashed edge.
class _DashedCircle extends CustomPainter {
  const _DashedCircle(this.color, this.width);

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final circle = Path()..addOval(Offset.zero & size);
    canvas.drawPath(circle, Paint()..color = HandsColors.white);
    _dashed(
      canvas,
      circle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_DashedCircle old) =>
      old.color != color || old.width != width;
}
