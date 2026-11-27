import 'package:flutter/material.dart';

import '../balloon_touch/balloon_illustration.dart';
import '../balloon_touch/exercise_screen.dart';
import '../balloon_touch/history_screen.dart';
import '../balloon_touch/session.dart';
import '../balloon_touch/setup_screen.dart';
import '../database.dart';
import '../theme.dart';
import 'exercise_art.dart';

/// The Patient's entry point, using the cream-and-green Home mockup.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.database,
    required this.patientId,
  });

  final HandsDatabase database;
  final String patientId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Session? _session;
  late Future<List<HistoryRow>> _history;

  bool get _canResume => _session?.status == SessionStatus.paused;

  @override
  void initState() {
    super.initState();
    _history = widget.database.history(patientId: widget.patientId);
  }

  void _refreshHistory() {
    if (!mounted) return;
    setState(() {
      _history = widget.database.history(patientId: widget.patientId);
    });
  }

  Future<void> _openBalloon() async {
    if (_canResume) {
      final session = _session!;
      session.resume();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ExerciseScreen(
            session: session,
            database: widget.database,
            onHome: _returnHome,
          ),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SetupScreen(
            database: widget.database,
            patientId: widget.patientId,
            onSessionStarted: (session) => _session = session,
            onHome: _returnHome,
          ),
        ),
      );
    }
    _refreshHistory();
  }

  Future<void> _returnHome() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() {});
    // Await the final snapshot before refreshing the saved-results preview.
    try {
      final session = _session;
      if (session != null) await widget.database.saveSession(session);
      _refreshHistory();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save progress. Please try again.'),
        ),
      );
    }
  }

  Future<void> _openResults() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(
          database: widget.database,
          patientId: widget.patientId,
        ),
      ),
    );
    _refreshHistory();
  }

  void _showProfile() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current patient ID'),
            const SizedBox(height: 12),
            SelectableText(widget.patientId),
            const SizedBox(height: 20),
            const Text(
              'Patient switching will be available in a future update.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: HandsColors.warmCream,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const Divider(color: HandsColors.sandBeige, height: 32),
                Text('My Games', style: handsText(26, HandsColors.forestSage)),
                const SizedBox(height: 20),
                _cards(),
                const SizedBox(height: 20),
                const Divider(color: HandsColors.sandBeige),
                const SizedBox(height: 20),
                _progress(),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _header() => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 24,
    runSpacing: 8,
    children: [
      Text('H.A.N.D.S', style: handsText(28, HandsColors.forestSage)),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: _showProfile,
            child: Text(
              'Profile',
              style: handsText(20, HandsColors.forestSage),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings, color: HandsColors.forestSage),
            onSelected: (value) {
              if (value == 'profile') _showProfile();
              if (value == 'results') _openResults();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('View profile')),
              PopupMenuItem(value: 'results', child: Text('View results')),
            ],
          ),
        ],
      ),
    ],
  );

  Widget _cards() => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 900
          ? 3
          : constraints.maxWidth >= 600
          ? 2
          : 1;
      final width = (constraints.maxWidth - 24 * (columns - 1)) / columns;
      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [
          _ExerciseCard(
            width: width,
            title: 'Balloon Pop',
            description: 'Touch the balloon, then lift your finger.',
            art: const BalloonIllustration(bodyWidth: 84),
            buttonText: _canResume ? 'Continue' : 'Start Now',
            onPressed: _openBalloon,
          ),
          _ExerciseCard(
            width: width,
            title: 'Line Tracing',
            description: 'Follow a path with your finger.',
            art: const ExerciseArt(tracing: true),
            buttonText: 'Coming later',
          ),
          _ExerciseCard(
            width: width,
            title: 'Drag and Drop',
            description: 'Move an object into its target.',
            art: const ExerciseArt(tracing: false),
            buttonText: 'Coming later',
          ),
        ],
      );
    },
  );

  Widget _progress() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: HandsColors.ivory,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          runSpacing: 12,
          children: [
            Text('My Progress', style: handsText(24, HandsColors.forestSage)),
            OutlinedButton(
              onPressed: _openResults,
              style: OutlinedButton.styleFrom(minimumSize: const Size(160, 48)),
              child: const Text('View Results'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_canResume)
          _progressRow(
            completed: _session!.exerciseRun.completedTrials,
            planned: _session!.exerciseRun.balloonCount,
            status: 'Session paused',
            onResume: _openBalloon,
          )
        else
          FutureBuilder<List<HistoryRow>>(
            future: _history,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return TextButton(
                  onPressed: _refreshHistory,
                  child: const Text('Results could not load. Tap to retry.'),
                );
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return const Text('Loading your progress…');
              }
              final rows = snapshot.data ?? [];
              if (rows.isEmpty) {
                return const Text(
                  'Ready when you are. Start Balloon Pop to see your progress here.',
                );
              }
              final latest = rows.first;
              return _progressRow(
                completed: latest.popped,
                planned: latest.balloonCount,
                status:
                    '${latest.stopped ? 'Last session stopped' : 'Last session completed'} · ${formatRunTime(latest.startedAt)}',
              );
            },
          ),
      ],
    ),
  );

  Widget _progressRow({
    required int completed,
    required int planned,
    required String status,
    VoidCallback? onResume,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Balloon Pop', style: handsText(20, HandsColors.forestSage)),
      const SizedBox(height: 6),
      Text('$completed of $planned balloons popped'),
      const SizedBox(height: 6),
      Text(status, style: const TextStyle(fontSize: 14)),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: planned == 0 ? 0 : (completed / planned).clamp(0, 1),
              minHeight: 16,
              color: HandsColors.charcoal,
              backgroundColor: HandsColors.sandBeige,
              borderRadius: BorderRadius.circular(8),
              semanticsLabel:
                  'Balloon progress: $completed of $planned balloons popped',
            ),
          ),
          if (onResume != null) ...[
            const SizedBox(width: 16),
            FilledButton(
              onPressed: onResume,
              style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
              child: const Text('Resume'),
            ),
          ],
        ],
      ),
    ],
  );
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.width,
    required this.title,
    required this.description,
    required this.art,
    required this.buttonText,
    this.onPressed,
  });

  final double width;
  final String title, description, buttonText;
  final Widget art;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: HandsColors.ivory,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              title,
              style: handsText(22, HandsColors.forestSage),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ExcludeSemantics(
              child: SizedBox(
                height: 130,
                child: Center(child: FittedBox(child: art)),
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Text(description, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size(140, 48),
                disabledBackgroundColor: HandsColors.sandBeige,
                disabledForegroundColor: HandsColors.forestSage,
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    ),
  );
}
