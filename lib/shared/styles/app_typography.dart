import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central typography — loads Inter via google_fonts (Vietnamese + Latin).
abstract final class AppTypography {
  static TextTheme apply(TextTheme base) => GoogleFonts.interTextTheme(base);

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );
}
