import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroTheme {
  static const Color background = Color(0xFF0B0E14);
  static const Color primary = Color(0xFF00FF9C); // Neon Green
  static const Color accent = Color(0xFFFF00FF);  // Magenta
  static const Color text = Color(0xFFE0E0E0);
  static const Color cardBg = Color(0xFF161B22);
  static const Color error = Color(0xFFFF3333);
  
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: cardBg,
        error: error,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.pressStart2p(color: primary),
        displayMedium: GoogleFonts.pressStart2p(color: text),
        displaySmall: GoogleFonts.pressStart2p(color: text, fontSize: 16),
        titleLarge: GoogleFonts.vt323(color: primary, fontSize: 24, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.vt323(color: text, fontSize: 20),
        bodyLarge: GoogleFonts.vt323(color: text, fontSize: 20),
        bodyMedium: GoogleFonts.vt323(color: text, fontSize: 18),
        labelLarge: GoogleFonts.pressStart2p(color: background, fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.pressStart2p(color: primary, fontSize: 16),
        iconTheme: const IconThemeData(color: primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          textStyle: GoogleFonts.pressStart2p(fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: primary, width: 2),
          ),
          elevation: 8,
          shadowColor: primary.withValues(alpha: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        labelStyle: GoogleFonts.vt323(color: primary, fontSize: 20),
        hintStyle: GoogleFonts.vt323(color: text.withValues(alpha: 0.5), fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 4,
        shadowColor: primary.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primary.withValues(alpha: 0.1), width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBg,
        contentTextStyle: GoogleFonts.vt323(color: primary, fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: primary),
        ),
      ),
    );
  }
}
