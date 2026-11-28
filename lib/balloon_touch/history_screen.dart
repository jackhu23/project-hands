import 'package:flutter/material.dart';

import '../database.dart';
import '../theme.dart';
import '../widgets/gradient_header.dart';
import '../widgets/loading_section.dart';
import 'metrics.dart';
import 'session.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// For example "7 Mar 2026, 09:05", in local time.
String formatRunTime(DateTime t) =>
    '${t.day} ${_months[t.month - 1]} ${t.year}, ${_two(t.hour)}:${_two(t.minute)}';

/// A whole percentage, or a dash when there is nothing to divide.
String formatAccuracy(double? accuracy) =>
    accuracy == null ? '–' : '${(accuracy * 100).round()}%';

/// Minutes and seconds, for example "2:05".
String formatDuration(Duration d) => '${d.inMinutes}:${_two(d.inSeconds % 60)}';

/// Seconds to two places, for example "1.23 s", or a dash.
String formatSeconds(Duration? d) =>
    d == null ? '–' : '${(d.inMicroseconds / 1e6).toStringAsFixed(2)} s';

String _accuracyOf(OutcomeCounts c) =>
    formatAccuracy(accuracy(pops: c.pops, misses: c.misses));

/// A table with a header row. Each cell is read out with its row and column,
/// such as "Accuracy, Overall: 75%".
Widget _table(List<String> columns, List<(String, List<String>)> rows) {
  Widget cell(String text, {String? label, bool header = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Text(
      text,
      semanticsLabel: label,
      style: header
          ? HandsText.body.copyWith(color: HandsColors.tealHeading)
          : HandsText.body,
    ),
  );
  return Table(
    defaultColumnWidth: const IntrinsicColumnWidth(),
    children: [
      TableRow(
        children: [
          cell('', header: true),
          for (final c in columns) cell(c, header: true),
        ],
      ),
      for (final (name, values) in rows)
        TableRow(
          children: [
            cell(name, header: true),
            for (final (i, v) in values.indexed)
              cell(v, label: v.isEmpty ? null : '$name, ${columns[i]}: $v'),
          ],
        ),
    ],
  );
}

/// A gradient-headed page under My progress with [child] below.
Widget _page(String eyebrow, String title, Widget child) => Scaffold(
  body: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      GradientHeader(eyebrow: eyebrow, title: title),
      Expanded(child: SafeArea(top: false, child: child)),
    ],
  ),
);

/// A bordered card, as on My progress.
Widget _card(Widget child) => Container(
  padding: const EdgeInsets.all(HandsSizes.panelPad),
  decoration: BoxDecoration(
    border: Border.all(color: HandsColors.border, width: HandsSizes.borderW),
    borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
  ),
  child: child,
);

/// Every ended Exercise Run, newest first, under a summary of the completed
/// ones.
class AllRunsScreen extends StatefulWidget {
  const AllRunsScreen({super.key, required this.database});

  final HandsDatabase database;

  @override
  State<AllRunsScreen> createState() => _AllRunsScreenState();
}

class _AllRunsScreenState extends State<AllRunsScreen> {
  @override
  Widget build(BuildContext context) {
    return _page(
      'BALLOON TOUCH',
      'All runs',
      LoadingSection<List<RunRecord>>(
        load: widget.database.runs,
        placeholder: const [],
        builder: (context, runs) {
          if (runs.isEmpty) {
            return Center(
              child: Text(
                'No Exercise Runs yet',
                style: HandsText.sectionTitle,
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: HandsSizes.pagePadH,
              vertical: HandsSizes.progressPadTop,
            ),
            children: [
              _card(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: HandsSizes.controlGap,
                  children: [
                    Text(
                      'Summary of completed runs',
                      style: HandsText.sectionTitle,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _summary(runs),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: HandsSizes.gap),
              for (final record in runs) _row(record),
            ],
          );
        },
      ),
    );
  }

  Widget _summary(List<RunRecord> runs) {
    final columns = <String, ProgressStats>{
      'Overall': summarize(runs),
      for (final MapEntry(key: level, value: summary) in summarizeByLevel(
        runs,
      ).entries)
        'Level $level': summary,
    };
    List<String> each(String Function(ProgressStats) f) =>
        columns.values.map(f).toList();
    return _table(columns.keys.toList(), [
      ('Runs', each((s) => '${s.runs}')),
      ('Completed runs', each((s) => '${s.completed}')),
      ('Stopped runs', each((s) => '${s.stopped}')),
      ('Accuracy', each((s) => formatAccuracy(s.accuracy))),
      (
        'Overlapping Touches per run',
        each((s) => s.overlappingPerRun?.toStringAsFixed(1) ?? '–'),
      ),
      ('Reaction Time', each((s) => formatSeconds(s.reactionTime))),
      ('Pop touch duration', each((s) => formatSeconds(s.popDuration))),
    ]);
  }

  Widget _row(RunRecord record) {
    final run = record.run;
    final popped = record.trials
        .where((t) => t.status == TrialStatus.completed)
        .length;
    final duration = formatDuration(runDuration(record));
    return ListTile(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RunDetailScreen(record: record),
        ),
      ),
      minTileHeight: HandsSizes.minTouch + HandsSizes.gapS,
      shape: const Border(bottom: BorderSide(color: HandsColors.panel)),
      title: Text(formatRunTime(run.startedAt), style: HandsText.rowTitle),
      subtitle: Text(
        '$popped of ${run.balloonCount} balloons popped',
        style: HandsText.caption,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          if (run.outcome == RunOutcome.stopped)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: HandsSizes.pillPadH,
                vertical: HandsSizes.pillPadV,
              ),
              decoration: BoxDecoration(
                color: HandsColors.panel,
                borderRadius: BorderRadius.circular(HandsSizes.radiusPill),
              ),
              child: Text(
                'Stopped',
                style: HandsText.pill.copyWith(color: HandsColors.inkMuted),
              ),
            ),
          Text(
            'Level ${run.difficultyLevel}',
            semanticsLabel: 'Difficulty Level ${run.difficultyLevel}',
            style: HandsText.body,
          ),
          Text(
            'Accuracy ${formatAccuracy(runAccuracy(record))}',
            style: HandsText.rowValue,
          ),
          Text(
            duration,
            semanticsLabel: 'Duration $duration',
            style: HandsText.body,
          ),
        ],
      ),
    );
  }
}

/// One Exercise Run: each Trial's Zone, Reaction Time and outcome counts,
/// then the run's totals.
class RunDetailScreen extends StatelessWidget {
  const RunDetailScreen({super.key, required this.record});

  final RunRecord record;

  @override
  Widget build(BuildContext context) {
    final run = record.run;
    final details = trialDetails(record);
    final total = countOutcomes(record.actions);
    List<String> counts(OutcomeCounts c) => [
      '${c.pops}',
      '${c.misses}',
      '${c.overlapping}',
      _accuracyOf(c),
    ];
    return _page(
      'RUN DETAIL',
      '${formatRunTime(run.startedAt)}, Level ${run.difficultyLevel}',
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: HandsSizes.pagePadH,
          vertical: HandsSizes.progressPadTop,
        ),
        child: _card(
          // Sideways too, so every column is reachable on a narrow tablet.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _table(
              [
                'Zone',
                'Reaction Time',
                'Pops',
                'Misses',
                'Overlapping Touches',
                'Accuracy',
              ],
              [
                for (final d in details)
                  (
                    'Trial ${d.number}',
                    [
                      '${d.zone}',
                      formatSeconds(d.reactionTime),
                      ...counts(d.counts),
                    ],
                  ),
                (
                  'Total',
                  [
                    '',
                    'mean ${formatSeconds(mean([...details.map((d) => d.reactionTime).nonNulls]))}',
                    ...counts(total),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
