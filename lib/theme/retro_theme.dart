import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'star_wars_retro_theme.dart';

class RetroTheme {
  static const Color background = StarWarsRetroColors.background;
  static const Color primary = StarWarsRetroColors.primaryNeon;
  static const Color accent = StarWarsRetroColors.accentPurple;
  static const Color text = StarWarsRetroColors.textSoft;
  static const Color cardBg = StarWarsRetroColors.surfaceDark;
  static const Color error = StarWarsRetroColors.dangerRed;
  static const Color gold = StarWarsRetroColors.gold;

  static ThemeData get theme => StarWarsRetroTheme.theme;

  static TextStyle get titlePixel =>
      GoogleFonts.pressStart2p(color: primary, fontSize: 16, letterSpacing: 3);

  static TextStyle get hudLabel =>
      GoogleFonts.orbitron(color: text, fontSize: 12, letterSpacing: 1.2);

  static TextStyle get bodyMono =>
      GoogleFonts.shareTechMono(color: text, fontSize: 14, height: 1.4);
}
