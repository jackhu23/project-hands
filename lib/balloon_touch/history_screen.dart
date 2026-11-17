import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../database.dart';
import '../theme.dart';
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
      style: handsText(
        17,
        header ? HandsColors.forestSage : HandsColors.charcoal,
      ),
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
              cell(v, label: '$name, ${columns[i]}: $v'),
          ],
        ),
    ],
  );
}

/// Past Exercise Runs, newest first, under a summary of the completed ones.
/// The look is provisional until the design round.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.database});

  final HandsDatabase database;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late var _runs = widget.database.runs();

  Future<void> _clearAll() async {
    await widget.database.clearAll();
    if (!mounted) return;
    setState(() {
      _runs = widget.database.runs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HandsColors.warmCream,
      appBar: AppBar(
        backgroundColor: HandsColors.warmCream,
        title: Text('History', style: handsText(28, HandsColors.forestSage)),
        actions: [
          // Compiled out of release builds, so a Patient can't wipe history.
          if (kDebugMode)
            TextButton(
              onPressed: _clearAll,
              child: Text(
                'Clear all data',
                style: handsText(17, HandsColors.oliveGreen),
              ),
            ),
        ],
      ),
      body: FutureBuilder(
        future: _runs,
        builder: (context, snapshot) {
          final runs = snapshot.data;
          if (runs == null) return const SizedBox.shrink();
          if (runs.isEmpty) {
            return Center(
              child: Text(
                'No Exercise Runs yet',
                style: handsText(24, HandsColors.forestSage),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Summary of completed runs',
                style: handsText(22, HandsColors.forestSage),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _summary(runs),
              ),
              const SizedBox(height: 24),
              for (final record in runs) _row(record),
            ],
          );
        },
      ),
    );
  }

  Widget _summary(List<RunRecord> runs) {
    final columns = <String, RunSummary>{
      'Overall': summarize(runs),
      for (final MapEntry(key: level, value: summary) in summarizeByLevel(
        runs,
      ).entries)
        'Level $level': summary,
    };
    List<String> each(String Function(RunSummary) f) =>
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
      title: Text(formatRunTime(run.startedAt), style: handsText(20)),
      subtitle: Text(
        '$popped of ${run.balloonCount} balloons popped',
        style: handsText(17, HandsColors.forestSage),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          if (run.outcome == RunOutcome.stopped)
            Text('Stopped', style: handsText(17)),
          Text(
            'Level ${run.difficultyLevel}',
            semanticsLabel: 'Difficulty Level ${run.difficultyLevel}',
            style: handsText(17),
          ),
          Text(
            'Accuracy ${_accuracyOf(countOutcomes(record.actions))}',
            style: handsText(17),
          ),
          Text(
            duration,
            semanticsLabel: 'Duration $duration',
            style: handsText(20),
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
    return Scaffold(
      backgroundColor: HandsColors.warmCream,
      appBar: AppBar(
        backgroundColor: HandsColors.warmCream,
        title: Text(
          '${formatRunTime(run.startedAt)}, Level ${run.difficultyLevel}',
          style: handsText(28, HandsColors.forestSage),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                formatSeconds(
                  mean([...details.map((d) => d.reactionTime).nonNulls]),
                ),
                ...counts(total),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
