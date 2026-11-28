import 'package:flutter/material.dart';

import '../database.dart';
import '../theme.dart';
import 'exercise_screen.dart';
import 'session.dart';

/// "Well done!" once every balloon in [session]'s run is popped. Go again
/// starts a run with the same settings; Back to today's plan goes Home.
class RunCompleteScreen extends StatelessWidget {
  const RunCompleteScreen({
    super.key,
    required this.session,
    required this.database,
  });

  final Session session;
  final HandsDatabase database;

  void _goAgain(BuildContext context) {
    final run = session.exerciseRun;
    // Created once here, not in the route builder, which can run again.
    final next = Session(
      patientId: session.patientId,
      balloonCount: run.balloonCount,
      difficultyLevel: run.difficultyLevel,
      onChange: session.onChange,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ExerciseScreen(session: next, database: database),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = session.exerciseRun.balloonCount;
    final radius = BorderRadius.circular(HandsSizes.radiusCard);
    const size = Size(HandsSizes.completeButtonW, HandsSizes.completeButtonH);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: HandsGradients.brand),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: HandsSizes.completeGap,
                    children: [
                      Container(
                        height: HandsSizes.completePillH,
                        padding: const EdgeInsets.symmetric(
                          horizontal: HandsSizes.completePillPadH,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: HandsColors.pinkPill,
                          borderRadius: BorderRadius.circular(
                            HandsSizes.radiusPill,
                          ),
                        ),
                        child: Text('RUN COMPLETE', style: HandsText.pill),
                      ),
                      Text('Well done!', style: HandsText.heroTitle),
                      Text(
                        n == 1
                            ? 'You popped the balloon.'
                            : 'You popped all $n balloons.',
                        style: HandsText.completeBody,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: HandsSizes.pauseGap,
                          runSpacing: HandsSizes.pauseGap,
                          children: [
                            OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst),
                              style: OutlinedButton.styleFrom(
                                fixedSize: size,
                                foregroundColor: HandsColors.white,
                                side: const BorderSide(
                                  color: HandsColors.onTealOutline,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: radius,
                                ),
                              ),
                              child: Text(
                                "Back to today's plan",
                                style: HandsText.completeButton,
                              ),
                            ),
                            FilledButton(
                              onPressed: () => _goAgain(context),
                              style: FilledButton.styleFrom(
                                fixedSize: size,
                                backgroundColor: HandsColors.white,
                                foregroundColor: HandsColors.tealDeep,
                                shape: RoundedRectangleBorder(
                                  borderRadius: radius,
                                ),
                              ),
                              child: Text(
                                'Go again',
                                style: HandsText.completeButton.copyWith(
                                  color: HandsColors.tealDeep,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: HandsSizes.completeLogoBottom,
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    'assets/logos/carle-health-white.png',
                    height: HandsSizes.runLogoH,
                    semanticLabel: 'Carle Health',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
