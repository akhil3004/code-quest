import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StarWarsRetroColors {
  static const Color background = Color(0xFF0B0F1A);
  static const Color primaryNeon = Color(0xFF00FFCC);
  static const Color accentPurple = Color(0xFFB983FF);
  static const Color gold = Color(0xFFFFD166);
  static const Color dangerRed = Color(0xFFFF4D6D);
  static const Color textSoft = Color(0xFFF5F7FF);
  static const Color surfaceDark = Color(0xFF101321);
}

class StarWarsRetroTheme {
  static ThemeData get theme {
    final base = ThemeData.dark();
    final colorScheme = base.colorScheme.copyWith(
      primary: StarWarsRetroColors.primaryNeon,
      secondary: StarWarsRetroColors.accentPurple,
      surface: StarWarsRetroColors.surfaceDark,
      error: StarWarsRetroColors.dangerRed,
      onPrimary: StarWarsRetroColors.background,
      onSecondary: StarWarsRetroColors.textSoft,
      onSurface: StarWarsRetroColors.textSoft,
      onError: StarWarsRetroColors.background,
    );

    final textTheme = TextTheme(
      displayLarge: GoogleFonts.pressStart2p(
        color: StarWarsRetroColors.primaryNeon,
        fontSize: 32,
        letterSpacing: 4,
      ),
      displayMedium: GoogleFonts.pressStart2p(
        color: StarWarsRetroColors.textSoft,
        fontSize: 24,
        letterSpacing: 3,
      ),
      titleLarge: GoogleFonts.orbitron(
        color: StarWarsRetroColors.textSoft,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
      titleMedium: GoogleFonts.orbitron(
        color: StarWarsRetroColors.textSoft,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
      ),
      bodyLarge: GoogleFonts.shareTechMono(
        color: StarWarsRetroColors.textSoft,
        fontSize: 16,
        height: 1.4,
      ),
      bodyMedium: GoogleFonts.shareTechMono(
        color: StarWarsRetroColors.textSoft.withValues(alpha: 0.9),
        fontSize: 14,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.pressStart2p(
        color: StarWarsRetroColors.background,
        fontSize: 11,
        letterSpacing: 2,
      ),
    );

    final elevatedButtonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: GoogleFonts.pressStart2p(fontSize: 11, letterSpacing: 1.5),
      backgroundColor: StarWarsRetroColors.primaryNeon,
      foregroundColor: StarWarsRetroColors.background,
      overlayColor:
          StarWarsRetroColors.accentPurple.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(
          color: StarWarsRetroColors.primaryNeon,
          width: 1.6,
        ),
      ),
      elevation: 6,
      shadowColor: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.4),
    );

    return base.copyWith(
      scaffoldBackgroundColor: StarWarsRetroColors.background,
      colorScheme: colorScheme,
      primaryColor: StarWarsRetroColors.primaryNeon,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.pressStart2p(
          color: StarWarsRetroColors.primaryNeon,
          fontSize: 16,
          letterSpacing: 3,
        ),
        iconTheme: const IconThemeData(
          color: StarWarsRetroColors.primaryNeon,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: elevatedButtonStyle),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: StarWarsRetroColors.primaryNeon,
          textStyle: GoogleFonts.pressStart2p(fontSize: 10),
        ),
      ),
      cardTheme: CardThemeData(
        color: StarWarsRetroColors.surfaceDark.withValues(alpha: 0.85),
        elevation: 8,
        shadowColor: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: StarWarsRetroColors.surfaceDark,
        contentTextStyle: GoogleFonts.shareTechMono(
          color: StarWarsRetroColors.primaryNeon,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StarWarsRetroColors.surfaceDark.withValues(alpha: 0.9),
        labelStyle: GoogleFonts.orbitron(
          color: StarWarsRetroColors.accentPurple,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
        hintStyle: GoogleFonts.shareTechMono(
          color: StarWarsRetroColors.textSoft.withValues(alpha: 0.5),
          fontSize: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: StarWarsRetroColors.primaryNeon.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: StarWarsRetroColors.primaryNeon,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.12),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeSlidePageTransitionsBuilder(),
          TargetPlatform.iOS: _FadeSlidePageTransitionsBuilder(),
          TargetPlatform.macOS: _FadeSlidePageTransitionsBuilder(),
          TargetPlatform.windows: _FadeSlidePageTransitionsBuilder(),
          TargetPlatform.linux: _FadeSlidePageTransitionsBuilder(),
        },
      ),
    );
  }
}

class _FadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}
