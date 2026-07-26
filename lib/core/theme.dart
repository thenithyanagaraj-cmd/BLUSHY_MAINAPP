import 'package:flutter/material.dart';

class BlushyColors {
  // Brand Colors
  static const Color background = Color(0xFFFAF6F0); // 90% neutral interface
  static const Color primary = Color(0xFFDD0D22);    // 10% strategic brand red
  static const Color secondary = Color(0xFFFF9B9E);  // Blush pink
  static const Color accent = Color(0xFFFF4A00);     // Spark orange

  // Neutral Colors
  static const Color surface = Color(0xFFFDFAF6);
  static const Color border = Color(0xFFEFEAE2);
  static const Color textDark = Color(0xFF1C1917);
  static const Color textMuted = Color(0xFF78716C);
  static const Color textLight = Color(0xFFA8A29E);
  
  // Custom Status Backgrounds (extremely soft)
  static const Color lutealSoft = Color(0xFFFDF2F2);
  static const Color lutealText = Color(0xFF9B1C1C);
}

class BlushyTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: BlushyColors.background,
      colorScheme: const ColorScheme.light(
        primary: BlushyColors.primary,
        secondary: BlushyColors.secondary,
        surface: BlushyColors.surface,
        error: BlushyColors.accent,
      ),
      fontFamily: 'Courier', // Fallback to Courier/Georgia for elegant editorial layout headings if platform sans isn't styled
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: BlushyColors.textDark,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: BlushyColors.textDark,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: BlushyColors.textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: BlushyColors.textDark,
          height: 1.5,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: BlushyColors.textMuted,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: BlushyColors.textDark,
          letterSpacing: 0.8,
        ),
      ),
      cardTheme: CardThemeData(
        color: BlushyColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: BlushyColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
