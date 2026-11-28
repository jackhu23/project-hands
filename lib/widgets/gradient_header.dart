import 'package:flutter/material.dart';

import '../theme.dart';
import 'line_icon.dart';

/// An Exercise hub's header: back button, eyebrow, title, logo and pill tabs.
/// Pages without tabs leave [tabs] empty.
class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.semanticsLabel,
    this.tabs = const [],
    this.selectedTab = 0,
    this.onTab,
    this.backLabel = 'Back',
    this.onBack,
  });

  final String eyebrow, title;
  final String? subtitle;

  /// Read for the title and subtitle together, in place of their text.
  final String? semanticsLabel;
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int>? onTab;
  final String backLabel;

  /// Pops when null.
  final VoidCallback? onBack;

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
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  tooltip: backLabel,
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
                      Semantics(
                        header: true,
                        label: semanticsLabel,
                        excludeSemantics: semanticsLabel != null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(title, style: HandsText.screenTitle),
                            ),
                            if (subtitle != null)
                              Text(subtitle!, style: HandsText.bannerMeta),
                          ],
                        ),
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
            if (tabs.isNotEmpty)
              Padding(
                // Lines the tabs up with the title.
                padding: const EdgeInsets.only(
                  left: HandsSizes.backButton + HandsSizes.headerGap,
                ),
                child: Row(
                  spacing: HandsSizes.controlGap,
                  children: [
                    for (final (i, tab) in tabs.indexed)
                      _Tab(
                        label: tab,
                        selected: i == selectedTab,
                        onTap: onTab == null ? null : () => onTab!(i),
                      ),
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
  const _Tab({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    selected: selected,
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
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
    ),
  );
}
