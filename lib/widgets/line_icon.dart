import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Thin stroke icons from the mockups (docs/design/reference_mockups).
const arrowIcon =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></svg>';
const backIcon =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M11 6l-6 6 6 6"/></svg>';
const noteIcon =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>';

/// An SVG line icon in [color], decorative only.
Widget lineIcon(String svg, Color color, double height) => SvgPicture.string(
  svg,
  height: height,
  theme: SvgTheme(currentColor: color),
  excludeFromSemantics: true,
);
