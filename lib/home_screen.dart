import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'balloon_touch/setup_screen.dart';
import 'database.dart';
import 'theme.dart';
import 'therapist_screen.dart';

// Red line icons from the Home mockup (docs/design/reference_mockups).
const _balloonIcon =
    '<svg viewBox="0 0 76 84" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="38" cy="32" rx="24" ry="29"/><path d="M26 20 Q30 11 38 9"/><path d="M34 61 L38 67 L42 61"/><path d="M38 67 Q32 74 40 82"/></svg>';
const _tracingIcon =
    '<svg viewBox="0 0 96 84" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M6 70 C28 10, 46 80, 64 36 S88 16, 90 12" stroke-dasharray="1 9"/><path d="M60 44 L72 30 L80 38 L68 52 Z"/><path d="M60 44 L56 58 L68 52"/></svg>';
const _newIcon =
    '<svg viewBox="0 0 84 84" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><circle cx="42" cy="42" r="34"/><path d="M42 26 V58 M26 42 H58"/></svg>';
const _personIcon =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/></svg>';
const _lockIcon =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/></svg>';
const _arrowIcon =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>';

Widget _icon(String svg, Color color, double height) => SvgPicture.string(
  svg,
  height: height,
  theme: SvgTheme(currentColor: color),
  excludeFromSemantics: true,
);

/// Home, "Today's plan": the hero with the Plan, and a card per Exercise.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.database,
    required this.patientId,
  });

  final HandsDatabase database;
  final String patientId;

  void _open(BuildContext context, Widget Function() page) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => page()));

  @override
  Widget build(BuildContext context) {
    final cards = [
      _ExerciseCard(
        icon: _balloonIcon,
        eyebrow: 'READY WHEN YOU ARE',
        title: 'Balloon Touch',
        body: 'Pop each balloon with one finger.',
        cta: 'Start',
        // Until the Balloon Touch hub lands.
        onTap: () => _open(
          context,
          () => SetupScreen(database: database, patientId: patientId),
        ),
      ),
      const _ExerciseCard(
        icon: _tracingIcon,
        eyebrow: 'COMING SOON',
        title: 'Tracing',
        body: 'Follow the path with your finger or stylus.',
      ),
      const _ExerciseCard(
        icon: _newIcon,
        eyebrow: 'COMING IN SPRING',
        title: 'New exercise',
        body: "A third exercise will appear here when it's ready.",
      ),
    ];
    final still = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          final heroH = (box.maxHeight / 2).clamp(
            HandsSizes.heroMinH,
            HandsSizes.heroMaxH,
          );
          return Stack(
            // Every child is positioned, so the Stack fills the screen and
            // the cards below the hero still take taps.
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: _Hero(
                  height: heroH,
                  patientId: patientId,
                  onTherapist: () =>
                      _open(context, () => TherapistScreen(database: database)),
                ),
              ),
              Positioned(
                left: HandsSizes.heroPadH,
                right: HandsSizes.heroPadH,
                top: heroH - HandsSizes.cardOverlap,
                bottom: HandsSizes.gap,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: HandsSizes.exerciseCardMaxH,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: HandsSizes.gap,
                      children: [
                        for (final (i, card) in cards.indexed)
                          Expanded(
                            child: still
                                ? card
                                : card
                                      .animate(delay: HandsMotion.stagger * i)
                                      .fadeIn(duration: HandsMotion.entrance)
                                      .slideY(
                                        begin: HandsSizes.entranceSlide,
                                        end: 0,
                                        duration: HandsMotion.entrance,
                                        curve: Curves.easeOut,
                                      ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.height,
    required this.patientId,
    required this.onTherapist,
  });

  final double height;
  final String patientId;
  final VoidCallback onTherapist;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE · d MMMM').format(DateTime.now());
    return Container(
      height: height,
      decoration: const BoxDecoration(gradient: HandsGradients.brand),
      padding: const EdgeInsets.fromLTRB(
        HandsSizes.heroPadH,
        HandsSizes.heroPadTop,
        HandsSizes.heroPadH,
        0,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/logos/carle-health-white.png',
                  height: HandsSizes.logoH,
                  semanticLabel: 'Carle Health',
                ),
                const SizedBox(width: HandsSizes.gap),
                // The whole ID stays readable: it scales down, never cut off.
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: HandsSizes.chipH,
                      padding: const EdgeInsets.symmetric(
                        horizontal: HandsSizes.pillPadH,
                      ),
                      decoration: BoxDecoration(
                        color: HandsColors.onTealFill,
                        border: Border.all(color: HandsColors.onTealLine),
                        borderRadius: BorderRadius.circular(
                          HandsSizes.radiusPill,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: HandsSizes.gapXS,
                        children: [
                          _icon(
                            _personIcon,
                            HandsColors.white,
                            HandsSizes.chipIcon,
                          ),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Patient $patientId',
                                style: HandsText.chip,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: HandsSizes.gapS),
                FilledButton.icon(
                  onPressed: onTherapist,
                  style: FilledButton.styleFrom(
                    backgroundColor: HandsColors.panel,
                    foregroundColor: HandsColors.tealDeep,
                    minimumSize: const Size(0, HandsSizes.minTouch),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        HandsSizes.radiusCard,
                      ),
                    ),
                  ),
                  icon: _icon(
                    _lockIcon,
                    HandsColors.tealDeep,
                    HandsSizes.chipIcon,
                  ),
                  label: Text('Therapist', style: HandsText.buttonSmall),
                ),
              ],
            ),
            const SizedBox(height: HandsSizes.heroGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: HandsSizes.gapS,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: HandsSizes.pillPadH,
                          vertical: HandsSizes.pillPadV,
                        ),
                        decoration: BoxDecoration(
                          color: HandsColors.pinkPill,
                          borderRadius: BorderRadius.circular(
                            HandsSizes.radiusPill,
                          ),
                        ),
                        child: Text(date.toUpperCase(), style: HandsText.pill),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Today's plan", style: HandsText.heroTitle),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: HandsSizes.gap),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: HandsSizes.planMaxW,
                    ),
                    child: const _PlanChecklist(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Today's Plan. No Plan can be set yet, so it shows its empty state.
class _PlanChecklist extends StatelessWidget {
  const _PlanChecklist();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(HandsSizes.gapXS),
    decoration: BoxDecoration(
      color: HandsColors.onTealFill,
      border: Border.all(color: HandsColors.onTealLine),
      borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
    ),
    child: Container(
      constraints: const BoxConstraints(minHeight: HandsSizes.planRowH),
      padding: const EdgeInsets.symmetric(horizontal: HandsSizes.pillPadH),
      alignment: Alignment.centerLeft,
      child: Text(
        "Your therapist hasn't set a plan yet",
        style: HandsText.bodyOnTeal,
      ),
    ),
  );
}

/// An Exercise's card. Without [onTap] it is a dashed placeholder.
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.cta,
    this.onTap,
  });

  final String icon, eyebrow, title, body;
  final String? cta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final placeholder = onTap == null;
    final radius = BorderRadius.circular(HandsSizes.radiusCard);
    final content = Padding(
      padding: const EdgeInsets.all(HandsSizes.cardPad),
      child: Column(
        children: [
          // Scales down rather than overflowing on a short card.
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: box.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _icon(icon, HandsColors.red, HandsSizes.iconSize),
                      const SizedBox(height: HandsSizes.gap),
                      Text(eyebrow, style: HandsText.eyebrow),
                      const SizedBox(height: HandsSizes.gapXS),
                      Text(title, style: HandsText.cardTitle),
                      const SizedBox(height: HandsSizes.gapXS),
                      Text(body, style: HandsText.body),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (cta case final cta?)
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: HandsSizes.gapXS,
                  children: [
                    Text(cta, style: HandsText.link),
                    _icon(_arrowIcon, HandsColors.tealDeep, HandsSizes.ctaIcon),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: HandsColors.white,
        borderRadius: radius,
        border: placeholder
            ? null
            : Border.all(color: HandsColors.border, width: HandsSizes.borderW),
        boxShadow: const [
          BoxShadow(
            color: HandsColors.shadow,
            blurRadius: HandsSizes.shadowBlur,
            offset: Offset(0, HandsSizes.shadowDy),
          ),
        ],
      ),
      child: placeholder
          ? CustomPaint(foregroundPainter: _DashedBorder(), child: content)
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: Semantics(button: true, child: content),
              ),
            ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HandsColors.borderStrong
      ..style = PaintingStyle.stroke
      ..strokeWidth = HandsSizes.dashedBorderW;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(HandsSizes.dashedBorderW / 2),
          const Radius.circular(HandsSizes.radiusCard),
        ),
      );
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += HandsSizes.dash * 2) {
        canvas.drawPath(metric.extractPath(d, d + HandsSizes.dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => false;
}
