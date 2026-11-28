import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/loading_section.dart';
import 'metrics.dart';
import 'run_summary_screen.dart';
import 'session.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// A whole percentage, or a dash when there is nothing to divide.
String formatAccuracy(double? accuracy) =>
    accuracy == null ? '–' : '${(accuracy * 100).round()}%';

/// Minutes and seconds, for example "2:05".
String formatDuration(Duration d) => '${d.inMinutes}:${_two(d.inSeconds % 60)}';

/// For screen readers, for example "2 minutes 5 seconds".
String spokenDuration(Duration d) {
  String unit(int n, String name) => '$n $name${n == 1 ? '' : 's'}';
  final m = d.inMinutes, s = d.inSeconds % 60;
  return [
    if (m > 0) unit(m, 'minute'),
    if (s > 0 || m == 0) unit(s, 'second'),
  ].join(' ');
}

/// Seconds to two places, for example "1.23 s", or a dash.
String formatSeconds(Duration? d) =>
    d == null ? '–' : '${(d.inMicroseconds / 1e6).toStringAsFixed(2)} s';

/// A white card with a thin border, clipped to its corners.
Widget _card(Widget child) => Container(
  clipBehavior: Clip.antiAlias,
  decoration: BoxDecoration(
    color: HandsColors.white,
    border: Border.all(color: HandsColors.border, width: HandsSizes.borderW),
    borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
  ),
  child: child,
);

/// The run table's column widths, shared by its header and rows.
const _flex = [16, 8, 10, 8, 7, 10];

/// Every Exercise Run, newest first: a count summary and runs by level on
/// the left, and a table on the right, filtered by Difficulty Level, whose
/// rows open each run's Run summary. Popped with true by Go to Practice.
class AllRunsScreen extends StatefulWidget {
  const AllRunsScreen({super.key, required this.database});

  final HandsDatabase database;

  @override
  State<AllRunsScreen> createState() => _AllRunsScreenState();
}

class _AllRunsScreenState extends State<AllRunsScreen> {
  /// The table's Difficulty Level, or null for All levels. Not saved.
  int? _level;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const GradientHeader(
            // shortcut: Balloon Touch is the only Exercise; take the name
            // from the runs once Tracing is recorded.
            eyebrow: 'BALLOON TOUCH',
            title: 'All runs',
            backLabel: 'Back to my progress',
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  HandsSizes.pagePadH,
                  HandsSizes.progressPadTop,
                  HandsSizes.pagePadH,
                  HandsSizes.allRunsPadBottom,
                ),
                child: LoadingSection<List<RunRecord>>(
                  load: widget.database.runs,
                  placeholder: const [],
                  builder: (context, runs) => _body(runs),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(List<RunRecord> runs) {
    final levels = {for (final r in runs) r.run.difficultyLevel}.toList()
      ..sort();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: HandsSizes.gap,
      children: [
        SizedBox(
          width: HandsSizes.allRunsLeftW,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: HandsSizes.allRunsCardGap,
              children: [
                _summary(runs, levels),
                if (runs.isNotEmpty) _byLevel(runs, levels),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: HandsSizes.tableGap,
            children: [
              // At 1024 px with four levels the filter drops below the
              // title, and scrolls if it's still too wide.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: HandsSizes.tableGap,
                runSpacing: HandsSizes.gapXS,
                children: [
                  Text('Every run', style: HandsText.everyRun),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _filter(levels),
                  ),
                ],
              ),
              Expanded(child: _table(runs)),
            ],
          ),
        ),
      ],
    );
  }

  /// Run counts and Overlapping Touches per run, for All and each level.
  Widget _summary(List<RunRecord> runs, List<int> levels) {
    // Four level columns don't fit at full width.
    final short = levels.length > 3;
    final columns = [
      ('All', 'All', countRuns(runs)),
      for (final l in levels)
        (short ? 'L$l' : 'Level $l', 'Level $l', countRuns(atLevel(runs, l))),
    ];
    final rows = <(String, String Function(RunCounts))>[
      ('Runs', (c) => '${c.runs}'),
      ('Completed', (c) => '${c.completed}'),
      ('Stopped early', (c) => '${c.stopped}'),
      (
        'Overlapping touches / run',
        (c) => c.overlappingPerRun?.toStringAsFixed(1) ?? '–',
      ),
    ];
    final last = columns.length;
    Widget cell(
      int i,
      double padV,
      Text text, {
      Alignment align = Alignment.centerRight,
    }) => Padding(
      padding: EdgeInsets.fromLTRB(
        i == 0 ? HandsSizes.tablePadH : HandsSizes.tableCellPadH,
        padV,
        i == last ? HandsSizes.tablePadH : HandsSizes.tableCellPadH,
        padV,
      ),
      child: Align(alignment: align, child: text),
    );
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text('SUMMARY', style: HandsText.cardEyebrow),
          ),
          Table(
            columnWidths: const {0: FlexColumnWidth()},
            defaultColumnWidth: const IntrinsicColumnWidth(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(color: HandsColors.panel),
                children: [
                  cell(0, 10, const Text('')),
                  for (final (i, (head, _, _)) in columns.indexed)
                    cell(i + 1, 10, Text(head, style: HandsText.tableHead)),
                ],
              ),
              for (final (r, (name, value)) in rows.indexed)
                TableRow(
                  decoration: r == rows.length - 1
                      ? null
                      : const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: HandsColors.panel),
                          ),
                        ),
                  children: [
                    cell(
                      0,
                      14,
                      Text(name, style: HandsText.tableLabel),
                      align: Alignment.centerLeft,
                    ),
                    for (final (i, (_, column, counts)) in columns.indexed)
                      cell(
                        i + 1,
                        14,
                        Text(
                          value(counts),
                          semanticsLabel: '$name, $column: ${value(counts)}',
                          style: HandsText.tableValue.copyWith(
                            fontSize: short ? 20 : null,
                            color: name == 'Stopped early' && counts.stopped > 0
                                ? HandsColors.redDeep
                                : i == 0
                                ? HandsColors.tealLink
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// A bar per level: completed then stopped, scaled to the busiest level.
  Widget _byLevel(List<RunRecord> runs, List<int> levels) {
    final most = levels.map((l) => atLevel(runs, l).length).reduce(max);
    Widget swatch(String label, {Color? color, Gradient? gradient}) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: HandsSizes.gapXS,
      children: [
        Container(
          width: HandsSizes.legendSquare,
          height: HandsSizes.legendSquare,
          decoration: BoxDecoration(
            color: color,
            gradient: gradient,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Text(label, style: HandsText.legend),
      ],
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: HandsColors.panel,
        borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: HandsSizes.tableGap,
        children: [
          Text('RUNS BY LEVEL', style: HandsText.cardEyebrow),
          for (final l in levels)
            if (countRuns(atLevel(runs, l)) case final c)
              Semantics(
                label:
                    'Level $l: ${c.runs} run${c.runs == 1 ? '' : 's'}, '
                    '${c.completed} completed, ${c.stopped} stopped',
                excludeSemantics: true,
                child: Row(
                  spacing: HandsSizes.tableGap,
                  children: [
                    SizedBox(
                      width: HandsSizes.levelLabelW,
                      child: Text('Level $l', style: HandsText.rowTitle),
                    ),
                    Expanded(
                      child: Container(
                        height: HandsSizes.levelTrackH,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: HandsColors.white,
                          borderRadius: BorderRadius.circular(
                            HandsSizes.levelTrackH / 2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (c.completed > 0)
                              Expanded(
                                flex: c.completed,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: HandsGradients.brandButton,
                                  ),
                                ),
                              ),
                            if (c.stopped > 0)
                              Expanded(
                                flex: c.stopped,
                                child: const ColoredBox(
                                  color: HandsColors.stoppedBar,
                                ),
                              ),
                            if (most > c.runs) Spacer(flex: most - c.runs),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: HandsSizes.levelCountW,
                      child: Text(
                        '${c.runs}',
                        textAlign: TextAlign.end,
                        style: HandsText.levelCount,
                      ),
                    ),
                  ],
                ),
              ),
          Wrap(
            spacing: HandsSizes.allRunsCardGap,
            children: [
              swatch('Completed', gradient: HandsGradients.brandButton),
              swatch('Stopped', color: HandsColors.stoppedBar),
            ],
          ),
        ],
      ),
    );
  }

  /// All levels, then each level with runs; it filters only the table.
  Widget _filter(List<int> levels) {
    Widget segment(String label, int? level) {
      final selected = _level == level;
      return Semantics(
        container: true,
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _level = level),
          // The padding makes the 42 px segment a 48 px target.
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HandsSizes.segmentPad / 2,
              vertical: HandsSizes.segmentPad,
            ),
            child: Container(
              height: HandsSizes.segmentH,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: HandsSizes.segmentPadH,
              ),
              decoration: BoxDecoration(
                color: selected ? HandsColors.tealDeep : null,
                borderRadius: BorderRadius.circular(HandsSizes.segmentH / 2),
              ),
              child: Text(
                label,
                style: selected
                    ? HandsText.segment.copyWith(color: HandsColors.white)
                    : HandsText.segment,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HandsSizes.segmentPad / 2,
      ),
      decoration: BoxDecoration(
        color: HandsColors.white,
        border: Border.all(
          color: HandsColors.borderControl,
          width: HandsSizes.controlBorderW,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment('All levels', null),
          for (final l in levels) segment('Level $l', l),
        ],
      ),
    );
  }

  /// [cells] in the table's columns, the last one a fixed chevron column.
  Widget _cells(List<Widget> cells) => Row(
    spacing: HandsSizes.tableGap,
    children: [
      for (final (i, flex) in _flex.indexed)
        Expanded(flex: flex, child: cells[i]),
      SizedBox(width: HandsSizes.chevron, child: cells.last),
    ],
  );

  Widget _table(List<RunRecord> runs) {
    final shown = atLevel(runs, _level);
    Text head(String text, [TextAlign? align]) =>
        Text(text, textAlign: align, style: HandsText.columnHead);
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: HandsColors.panel,
            padding: const EdgeInsets.symmetric(
              horizontal: HandsSizes.tablePadH,
              vertical: HandsSizes.tableGap,
            ),
            child: _cells([
              head('DATE & TIME'),
              head('LEVEL'),
              head('POPPED'),
              head('ACCURACY', TextAlign.end),
              head('TIME', TextAlign.end),
              head('STATUS'),
              const SizedBox(),
            ]),
          ),
          Expanded(
            child: runs.isEmpty
                ? _empty()
                : ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, i) => _row(shown[i], i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(RunRecord r, int i) {
    final run = r.run;
    final popped = r.trials
        .where((t) => t.status == TrialStatus.completed)
        .length;
    final accuracy = runAccuracy(r);
    final duration = runDuration(r);
    final stopped = run.outcome == RunOutcome.stopped;
    final date = DateFormat(
      run.startedAt.year == DateTime.now().year ? 'd MMM' : 'd MMM y',
    ).format(run.startedAt);
    final time = DateFormat.jm().format(run.startedAt);
    void open() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RunSummaryScreen(
          database: widget.database,
          runId: run.id,
          backLabel: 'Back to all runs',
        ),
      ),
    );
    return Semantics(
      button: true,
      excludeSemantics: true,
      onTap: open,
      label:
          '$date $time, level ${run.difficultyLevel}, '
          '$popped of ${run.balloonCount} popped, '
          '${accuracy == null ? 'no accuracy' : 'accuracy ${(accuracy * 100).round()} percent'}, '
          '${spokenDuration(duration)}, ${stopped ? 'stopped' : 'completed'}. '
          'Opens run summary.',
      child: Material(
        color: i.isOdd ? HandsColors.zebra : HandsColors.white,
        child: InkWell(
          onTap: open,
          splashFactory: NoSplash.splashFactory,
          highlightColor: HandsColors.panel,
          child: Container(
            constraints: const BoxConstraints(minHeight: HandsSizes.runRowMinH),
            padding: const EdgeInsets.symmetric(
              horizontal: HandsSizes.tablePadH,
              vertical: HandsSizes.gapXS,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: HandsColors.panel)),
            ),
            child: _cells([
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: HandsText.runDate),
                  Text(time, style: HandsText.runTime),
                ],
              ),
              Text('Level ${run.difficultyLevel}', style: HandsText.filterChip),
              Text(
                '$popped of ${run.balloonCount}',
                style: HandsText.cellMuted,
              ),
              Text(
                formatAccuracy(accuracy),
                textAlign: TextAlign.end,
                style: HandsText.rowValue,
              ),
              Text(
                formatDuration(duration),
                textAlign: TextAlign.end,
                style: HandsText.cellMuted,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: HandsSizes.statusPillH,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: HandsSizes.statusPillPadH,
                  ),
                  decoration: BoxDecoration(
                    color: stopped
                        ? HandsColors.pinkPill
                        : HandsColors.tealTint,
                    borderRadius: BorderRadius.circular(
                      HandsSizes.statusPillH / 2,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      stopped ? 'STOPPED' : 'COMPLETED',
                      style: stopped
                          ? HandsText.statusPill.copyWith(
                              color: HandsColors.redDeep,
                            )
                          : HandsText.statusPill,
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: HandsSizes.chevron,
                color: HandsColors.borderStrong,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _empty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(HandsSizes.gap),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: HandsSizes.gap,
        children: [
          Text(
            'No runs yet. Your runs will appear here after you practise.',
            textAlign: TextAlign.center,
            style: HandsText.body,
          ),
          Semantics(
            button: true,
            child: Material(
              borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
              clipBehavior: Clip.antiAlias,
              child: Ink(
                height: HandsSizes.practiceButtonH,
                decoration: const BoxDecoration(
                  gradient: HandsGradients.brandButton,
                ),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HandsSizes.cardPad,
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        'Go to Practice',
                        style: HandsText.completeButton,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
