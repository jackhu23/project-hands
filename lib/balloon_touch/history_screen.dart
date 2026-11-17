import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../database.dart';
import '../theme.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// For example "7 Mar 2026, 09:05", in local time.
String formatRunTime(DateTime t) =>
    '${t.day} ${_months[t.month - 1]} ${t.year}, ${_two(t.hour)}:${_two(t.minute)}';

/// Minutes and seconds, for example "2:05".
String formatDuration(Duration d) => '${d.inMinutes}:${_two(d.inSeconds % 60)}';

/// Past Exercise Runs, newest first. The look is provisional until the
/// design round.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.database});

  final HandsDatabase database;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late var _rows = widget.database.history();

  Future<void> _clearAll() async {
    await widget.database.clearAll();
    if (!mounted) return;
    setState(() {
      _rows = widget.database.history();
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
        future: _rows,
        builder: (context, snapshot) {
          final rows = snapshot.data;
          if (rows == null) return const SizedBox.shrink();
          if (rows.isEmpty) {
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
              for (final run in rows)
                ListTile(
                  title: Text(
                    formatRunTime(run.startedAt),
                    style: handsText(20),
                  ),
                  subtitle: Text(
                    '${run.popped} of ${run.balloonCount} balloons popped',
                    style: handsText(17, HandsColors.forestSage),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 24,
                    children: [
                      if (run.stopped) Text('Stopped', style: handsText(17)),
                      Text(
                        formatDuration(run.duration),
                        semanticsLabel:
                            'Duration ${formatDuration(run.duration)}',
                        style: handsText(20),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
