import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';
import 'balloon_illustration.dart';
import 'exercise_screen.dart';

const _minBalloons = 1, _maxBalloons = 30;

/// Balloon Touch setup, ported from the demo's `BalloonSetupView`.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _balloonCount = ValueNotifier(_minBalloons);

  @override
  void dispose() {
    _balloonCount.dispose();
    super.dispose();
  }

  void _start() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ExerciseScreen(balloonCount: _balloonCount.value),
    ),
  );

  // Quirk carried over: the sheet repeats the card's + and − control.
  void _showSettings() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: HandsColors.warmCream,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 28,
        children: [
          Text('Practice settings', style: handsText(28)),
          ValueListenableBuilder(
            valueListenable: _balloonCount,
            builder: (_, count, _) => Row(
              children: [
                Text('Repetitions: $count', style: handsText(20)),
                const Spacer(),
                _CountButtons(_balloonCount),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: HandsColors.oliveGreen,
              minimumSize: const Size(120, 52),
            ),
            child: Text('Done', style: handsText(20, HandsColors.ivory)),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final sideBySide = size.width >= 700 && size.width > size.height;
            final cardHeight = sideBySide
                ? (size.height - 210).clamp(320.0, 480.0)
                : 340.0;
            final cards = [
              _BalloonCard(height: cardHeight),
              _CountCard(height: cardHeight, count: _balloonCount),
            ];

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 24,
                      children: [
                        _header(),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: sideBySide ? 1040 : 520,
                          ),
                          child: sideBySide
                              ? Row(
                                  spacing: 40,
                                  children: [
                                    for (final card in cards)
                                      Expanded(child: card),
                                  ],
                                )
                              : Column(spacing: 24, children: cards),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _start,
                              style: FilledButton.styleFrom(
                                backgroundColor: HandsColors.oliveGreen,
                                minimumSize: const Size.fromHeight(58),
                                shape: const StadiumBorder(
                                  side: BorderSide(
                                    color: HandsColors.ivory,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Start Now',
                                style: handsText(28, HandsColors.ivory),
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
          },
        ),
      ),
    );
  }

  Widget _header() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        tooltip: 'Back',
        iconSize: 36,
        color: HandsColors.forestSage,
        icon: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text('H.A.N.D.S', style: handsText(30, HandsColors.forestSage)),
          Text('Balloon Practice', style: handsText(24)),
        ],
      ),
      const Spacer(),
      IconButton(
        onPressed: _showSettings,
        tooltip: 'Practice settings',
        iconSize: 44,
        color: HandsColors.forestSage,
        icon: const Icon(Icons.settings),
      ),
    ],
  );
}

class _Card extends StatelessWidget {
  const _Card({
    required this.height,
    required this.padding,
    required this.child,
  });

  final double height, padding;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: double.infinity,
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: HandsColors.ivory,
      borderRadius: BorderRadius.circular(32),
    ),
    child: child,
  );
}

class _BalloonCard extends StatelessWidget {
  const _BalloonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => _Card(
    height: height,
    padding: 20,
    child: Column(
      children: [
        const Spacer(),
        BalloonIllustration(bodyWidth: min(180, height * 0.38)),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'Touch the balloon',
            textAlign: TextAlign.center,
            style: handsText(24, HandsColors.forestSage),
          ),
        ),
      ],
    ),
  );
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.height, required this.count});

  final double height;
  final ValueNotifier<int> count;

  @override
  Widget build(BuildContext context) {
    final box = min(180.0, height * 0.38);
    return _Card(
      height: height,
      padding: 24,
      child: Column(
        children: [
          const Spacer(),
          Text(
            'Number of repetitions',
            textAlign: TextAlign.center,
            style: handsText(24),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder(
            valueListenable: count,
            builder: (_, value, _) => Container(
              width: box,
              height: box,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: HandsColors.warmCream,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Semantics(
                label: '$value repetitions',
                liveRegion: true,
                excludeSemantics: true,
                child: Text('$value', style: handsText(48)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const ShapeDecoration(
              color: HandsColors.warmCream,
              shape: StadiumBorder(),
            ),
            child: _CountButtons(count),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// − and + buttons that keep [count] within 1–30.
class _CountButtons extends StatelessWidget {
  const _CountButtons(this.count);

  final ValueNotifier<int> count;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: count,
    builder: (_, value, _) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        _button(Icons.remove, 'Decrease repetitions', value > _minBalloons, -1),
        _button(Icons.add, 'Increase repetitions', value < _maxBalloons, 1),
      ],
    ),
  );

  Widget _button(IconData icon, String label, bool enabled, int step) =>
      IconButton(
        onPressed: enabled ? () => count.value += step : null,
        tooltip: label,
        iconSize: 24,
        color: HandsColors.charcoal,
        disabledColor: HandsColors.charcoal.withValues(alpha: 0.3),
        style: IconButton.styleFrom(
          fixedSize: const Size(60, 50),
          shape: const RoundedRectangleBorder(),
        ),
        icon: Icon(icon, weight: 700),
      );
}
