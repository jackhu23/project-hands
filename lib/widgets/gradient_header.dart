import 'package:flutter/material.dart';

import '../theme.dart';
import 'line_icon.dart';

/// An Exercise hub's header: back button, eyebrow, title, logo and pill tabs.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.tabs,
    required this.selectedTab,
  });

  final String eyebrow, title;
  final List<String> tabs;
  final int selectedTab;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(gradient: HandsGradients.brand),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          HandsSizes.pagePadH,
          HandsSizes.headerPadTop,
          HandsSizes.pagePadH,
          HandsSizes.headerPadBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: HandsSizes.headerGap,
          children: [
            Row(
              spacing: HandsSizes.headerGap,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Back',
                  style: IconButton.styleFrom(
                    fixedSize: const Size.square(HandsSizes.backButton),
                    backgroundColor: HandsColors.onTealFill,
                    side: const BorderSide(color: HandsColors.onTealLine),
                  ),
                  icon: lineIcon(
                    backIcon,
                    HandsColors.white,
                    HandsSizes.ctaIcon,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eyebrow, style: HandsText.eyebrowOnTeal),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(title, style: HandsText.screenTitle),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/logos/carle-health-white.png',
                  height: HandsSizes.headerLogoH,
                  semanticLabel: 'Carle Health',
                ),
              ],
            ),
            Padding(
              // Lines the tabs up with the title.
              padding: const EdgeInsets.only(
                left: HandsSizes.backButton + HandsSizes.headerGap,
              ),
              child: Row(
                spacing: HandsSizes.controlGap,
                children: [
                  for (final (i, tab) in tabs.indexed)
                    _Tab(label: tab, selected: i == selectedTab),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: Container(
      height: HandsSizes.minTouch,
      padding: const EdgeInsets.symmetric(horizontal: HandsSizes.tabPadH),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? HandsColors.white : null,
        border: selected
            ? null
            : Border.all(
                color: HandsColors.onTealLine,
                width: HandsSizes.borderW,
              ),
        borderRadius: BorderRadius.circular(HandsSizes.radiusPill),
      ),
      child: Text(
        label,
        style: selected
            ? HandsText.tab.copyWith(color: HandsColors.tealDeep)
            : HandsText.tab,
      ),
    ),
  );
}
