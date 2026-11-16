import 'package:flutter/material.dart';

/// The Balloon Touch demo's colours, identical on iPad and Android.
abstract final class HandsColors {
  static const charcoal = Color(0xFF34372E);
  static const forestSage = Color(0xFF4E5946);
  static const ivory = Color(0xFFFFFCF6);
  static const oliveGreen = Color(0xFF637B48);
  static const sandBeige = Color(0xFFE9E1D0);
  static const warmCream = Color(0xFFF7F3EA);
}

/// Bundled Paytone One, so text looks the same on every OS.
const handsFont = 'PaytoneOne';

/// A Paytone One style in [color] (Charcoal by default).
TextStyle handsText(double size, [Color color = HandsColors.charcoal]) =>
    TextStyle(fontFamily: handsFont, fontSize: size, color: color);

final handsTheme = ThemeData(
  fontFamily: handsFont,
  colorScheme: ColorScheme.fromSeed(
    seedColor: HandsColors.oliveGreen,
    primary: HandsColors.oliveGreen,
    surface: HandsColors.warmCream,
    onSurface: HandsColors.charcoal,
  ),
  scaffoldBackgroundColor: HandsColors.warmCream,
);
