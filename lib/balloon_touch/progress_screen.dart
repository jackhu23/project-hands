import 'dart:math';

import 'package:flutter/material.dart';

import '../theme.dart';
import 'balloon_illustration.dart';
import 'session.dart';

/// The progress page, ported from the demo's `BalloonSessionHomeView`.
/// "Start New Session" returns to setup.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final run = session.exerciseRun;
    final done = run.completedTrials, planned = run.balloonCount;
    return Scaffold(
      backgroundColor: HandsColors.warmCream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        spacing: 16,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Text(
                                  'H.A.N.D.S',
                                  style: handsText(30, HandsColors.forestSage),
                                ),
                                const Spacer(),
                                const ExcludeSemantics(
                                  child: Icon(
                                    Icons.settings,
                                    size: 32,
                                    color: HandsColors.forestSage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: max(400, min(510, h * 0.6)),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: HandsColors.ivory,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              spacing: 16,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Your progress',
                                      style: handsText(
                                        24,
                                        HandsColors.forestSage,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$done/$planned',
                                      style: handsText(
                                        24,
                                        HandsColors.forestSage,
                                      ),
                                    ),
                                  ],
                                ),
                                Semantics(
                                  label: 'Progress',
                                  value: '$done of $planned balloons',
                                  child: LinearProgressIndicator(
                                    value: done / planned,
                                    minHeight: 14,
                                    color: HandsColors.forestSage,
                                    backgroundColor: HandsColors.sandBeige,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                // Scale down rather than overflow on short screens.
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: BalloonIllustration(
                                      bodyWidth: min(140, h * 0.2),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Session finished',
                                  style: handsText(25, HandsColors.forestSage),
                                ),
                                Text(
                                  'You completed $done of $planned balloons.',
                                  textAlign: TextAlign.center,
                                  style: handsText(17, HandsColors.forestSage),
                                ),
                              ],
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  shape: const StadiumBorder(),
                                  side: const BorderSide(
                                    color: HandsColors.oliveGreen,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'Start New Session',
                                  style: handsText(22, HandsColors.forestSage),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
