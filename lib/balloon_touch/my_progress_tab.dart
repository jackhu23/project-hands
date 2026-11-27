import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database.dart';
import '../theme.dart';
import '../widgets/line_icon.dart';
import '../widgets/loading_section.dart';
import 'history_screen.dart';
import 'metrics.dart';

/// The hub's My progress tab: level chips, stat cards, the Accuracy chart,
/// the therapist note and recent runs, for the selected Difficulty Level.
class MyProgressTab extends StatefulWidget {
  const MyProgressTab({super.key, required this.database});

  final HandsDatabase database;

  @override
  State<MyProgressTab> createState() => _MyProgressTabState();
}

class _MyProgressTabState extends State<MyProgressTab> {
  /// Null for All levels.
  int? _level;

  // shortcut: each section runs its own history query so each can fail and
  // retry alone; share one query once the cloud backend makes them costly.
  Widget _section(Widget Function(List<RunRecord> runs) builder) =>
      LoadingSection<List<RunRecord>>(
        load: widget.database.runs,
        placeholder: const [],
        builder: (_, runs) => builder(atLevel(runs, _level)),
      );

  @override
  Widget build(BuildContext context) {
    final lower = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: HandsSizes.progressGap,
      children: [
        Expanded(
          flex: 3,
          child: _card(
            padding: const EdgeInsets.fromLTRB(
              HandsSizes.statPadH,
              HandsSizes.chartPadTop,
              HandsSizes.statPadH,
              HandsSizes.chartPadBottom,
            ),
            title: 'Accuracy over time',
            child: _section((runs) => _Chart(accuracySeries(runs))),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: HandsSizes.noteGap,
            children: [
              LoadingSection<String?>(
                // Therapist notes arrive with therapist mode.
                load: () async => null,
                placeholder: null,
                builder: (_, note) => _NoteCard(note),
              ),
              Expanded(
                child: _card(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HandsSizes.sideCardPadH,
                    vertical: HandsSizes.gapS,
                  ),
                  title: 'Recent runs',
                  action: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            AllRunsScreen(database: widget.database),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, HandsSizes.minTouch),
                    ),
                    child: Text('See all runs →', style: HandsText.link),
                  ),
                  child: _section(_recent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, box) {
          // Short tablets scroll rather than squash the chart and Recent runs.
          final tight = box.maxHeight < HandsSizes.progressMinH;
          final page = Padding(
            padding: const EdgeInsets.fromLTRB(
              HandsSizes.pagePadH,
              HandsSizes.progressPadTop,
              HandsSizes.pagePadH,
              HandsSizes.progressPadBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: HandsSizes.progressGap,
              children: [
                // The chips need every run, not just the filtered ones.
                LoadingSection<List<RunRecord>>(
                  load: widget.database.runs,
                  placeholder: const [],
                  builder: (_, runs) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: HandsSizes.progressGap,
                    children: [_chips(runs), _stats(atLevel(runs, _level))],
                  ),
                ),
                if (tight)
                  SizedBox(height: HandsSizes.progressLowerMinH, child: lower)
                else
                  Expanded(child: lower),
              ],
            ),
          );
          return tight ? SingleChildScrollView(child: page) : page;
        },
      ),
    );
  }

  Widget _chips(List<RunRecord> runs) {
    final levels = {for (final r in runs) r.run.difficultyLevel}.toList()
      ..sort();
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: HandsSizes.controlGap,
          children: [
            _chip('All levels', null),
            for (final level in levels) _chip('Level $level', level),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, int? level) {
    final on = level == _level;
    return Semantics(
      selected: on,
      child: OutlinedButton(
        onPressed: () => setState(() => _level = level),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, HandsSizes.minTouch),
          padding: const EdgeInsets.symmetric(
            horizontal: HandsSizes.filterChipPadH,
          ),
          backgroundColor: on ? HandsColors.tealDeep : HandsColors.white,
          side: BorderSide(
            color: on ? HandsColors.tealDeep : HandsColors.borderControl,
            width: HandsSizes.controlBorderW,
          ),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: on
              ? HandsText.filterChip.copyWith(color: HandsColors.white)
              : HandsText.filterChip,
        ),
      ),
    );
  }

  Widget _stats(List<RunRecord> runs) {
    final s = summarize(runs);
    final rt = s.reactionTime;
    return Row(
      spacing: HandsSizes.progressGap,
      children: [
        Expanded(
          child: _StatCard(
            label: 'Accuracy',
            value: s.accuracy,
            format: (x) => formatAccuracy(x),
            gradient: true,
          ),
        ),
        Expanded(
          child: _StatCard(
            label: 'Reaction Time',
            value: rt == null ? null : rt.inMicroseconds / 1e6,
            format: (x) =>
                formatSeconds(Duration(microseconds: (x * 1e6).round())),
            color: HandsColors.panel,
          ),
        ),
        Expanded(
          child: _StatCard(
            label: 'Runs completed',
            value: s.completed.toDouble(),
            format: (x) => '${x.round()}',
            border: true,
          ),
        ),
      ],
    );
  }

  Widget _recent(List<RunRecord> runs) {
    if (runs.isEmpty) return _empty('No runs yet');
    // A Column, not a ListView, so every row is built and reachable by
    // scrolling on short tablets.
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final r in runs.take(4))
            Container(
              padding: const EdgeInsets.symmetric(vertical: HandsSizes.rowPadV),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: HandsColors.panel)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('d MMM, HH:mm').format(r.run.startedAt),
                          style: HandsText.rowTitle,
                        ),
                        Text(
                          [
                            'Level ${r.run.difficultyLevel}',
                            formatDuration(runDuration(r)),
                            if (r.run.outcome == RunOutcome.stopped) 'Stopped',
                          ].join(' · '),
                          style: HandsText.caption,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatAccuracy(runAccuracy(r)),
                    style: HandsText.rowValue,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget _empty(String text) => Center(
  child: Text(
    text,
    textAlign: TextAlign.center,
    style: HandsText.body.copyWith(color: HandsColors.inkMuted),
  ),
);

/// A bordered card with a title, its [child] filling the rest.
Widget _card({
  required EdgeInsets padding,
  required String title,
  required Widget child,
  Widget? action,
}) => Container(
  padding: padding,
  decoration: BoxDecoration(
    border: Border.all(color: HandsColors.border, width: HandsSizes.borderW),
    borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: HandsSizes.controlGap,
    children: [
      Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(title, style: HandsText.sectionTitle),
            ),
          ),
          ?action,
        ],
      ),
      Expanded(child: child),
    ],
  ),
);

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.format,
    this.gradient = false,
    this.color,
    this.border = false,
  });

  final String label;
  final double? value;
  final String Function(double) format;
  final bool gradient, border;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final v = value;
    final textColor = gradient ? HandsColors.white : HandsColors.tealLink;
    Widget number(String text) =>
        Text(text, style: HandsText.metric.copyWith(color: textColor));
    return Semantics(
      label: '$label ${v == null ? '–' : format(v)}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HandsSizes.statPadH,
          vertical: HandsSizes.statPadV,
        ),
        decoration: BoxDecoration(
          gradient: gradient ? HandsGradients.brandButton : null,
          color: color ?? (gradient ? null : HandsColors.white),
          border: border
              ? Border.all(color: HandsColors.border, width: HandsSizes.borderW)
              : null,
          borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
          boxShadow: gradient
              ? const [
                  BoxShadow(
                    color: HandsColors.shadowStrong,
                    blurRadius: HandsSizes.statShadowBlur,
                    offset: Offset(0, HandsSizes.statShadowDy),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                style: gradient
                    ? HandsText.statLabel.copyWith(color: HandsColors.redOnTeal)
                    : HandsText.statLabel,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: v == null
                  ? number('–')
                  : _Grow(to: v, builder: (x) => number(format(x))),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animates from 0 to [to] when it first appears, or jumps there under
/// "reduce motion".
class _Grow extends StatelessWidget {
  const _Grow({required this.to, required this.builder});

  final double to;
  final Widget Function(double value) builder;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: to),
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : HandsMotion.countUp,
    curve: Curves.easeOut,
    builder: (_, value, _) => builder(value),
  );
}

/// One column per completed run, oldest on the left; scrolls sideways,
/// starting at the latest, once the columns no longer fit.
class _Chart extends StatelessWidget {
  const _Chart(this.points);

  final List<AccuracyPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _empty('No runs yet\nYour progress shows here after a run.');
    }
    return LayoutBuilder(
      builder: (context, box) {
        final slot = max(
          box.maxWidth / points.length,
          HandsSizes.chartColumnMinW,
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, p) in points.indexed)
                SizedBox(
                  width: slot,
                  height: box.maxHeight,
                  child: _column(p, latest: i == points.length - 1, slot),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _column(AccuracyPoint p, double slot, {required bool latest}) {
    final label = '${DateFormat('d MMM').format(p.startedAt)} · L${p.level}';
    final value = formatAccuracy(p.accuracy);
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final full = max(
                HandsSizes.chartColumnMinH,
                p.accuracy * (box.maxHeight - HandsSizes.chartValueH),
              );
              return Align(
                alignment: Alignment.bottomCenter,
                child: Semantics(
                  label: '$label, $value${latest ? ', latest run' : ''}',
                  excludeSemantics: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: HandsSizes.chartValueH,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(value, style: HandsText.chartValue),
                        ),
                      ),
                      _Grow(
                        to: full,
                        builder: (h) => Container(
                          width: min(
                            slot - HandsSizes.chartColumnGap,
                            HandsSizes.chartColumnMaxW,
                          ),
                          height: h,
                          decoration: BoxDecoration(
                            gradient: latest
                                ? HandsGradients.barRed
                                : HandsGradients.barTeal,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(HandsSizes.chartRadius),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(height: HandsSizes.chartAxisW, color: HandsColors.border),
        const SizedBox(height: HandsSizes.controlGap),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: HandsText.chartLabel),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard(this.note);

  final String? note;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: HandsSizes.sideCardPadH,
      vertical: HandsSizes.notePadV,
    ),
    decoration: BoxDecoration(
      color: HandsColors.pinkCard,
      borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: HandsSizes.gapS,
      children: [
        lineIcon(noteIcon, HandsColors.red, HandsSizes.noteIcon),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text('FROM YOUR THERAPIST', style: HandsText.noteLabel),
              Text(
                note ?? 'No note from your therapist yet',
                style: HandsText.note,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
