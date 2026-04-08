import 'package:flutter/material.dart';

class AppTheme {
  // Premium University Theme Colors
  static const Color richBrown = Color(0xFF8B4513);
  static const Color darkBrown = Color(0xFF5C2E0F);
  static const Color golden = Color(0xFFD4AF37);
  static const Color accentGold = Color(0xFFC9A961);
  static const Color cream = Color(0xFFFFFDD0);
  static const Color lightCream = Color(0xFFFFFEF5);
  static const Color surfaceLight = Color(0xFFFAF8F3);
  static const Color textDark = Color(0xFF1A1410);
  static const Color textMuted = Color(0xFF6B5B4F);
  static const Color shadowColor = Color(0x1A000000);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: richBrown,
      brightness: Brightness.light,
      primary: richBrown,
      secondary: golden,
      tertiary: accentGold,
      surface: lightCream,
      onPrimary: cream,
      onSecondary: darkBrown,
      onSurface: textDark,
    ),
    scaffoldBackgroundColor: lightCream,
    fontFamily: 'Georgia',
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: richBrown,
      foregroundColor: cream,
      elevation: 8,
      surfaceTintColor: richBrown,
      shadowColor: shadowColor,
      titleTextStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: cream,
        letterSpacing: 0.5,
        fontFamily: 'Georgia',
      ),
      iconTheme: const IconThemeData(color: cream, size: 24),
    ),
    cardTheme: CardThemeData(
      color: lightCream,
      elevation: 8,
      shadowColor: shadowColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: golden.withOpacity(0.3), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(
        color: darkBrown.withOpacity(0.7),
        fontWeight: FontWeight.w500,
        fontFamily: 'Georgia',
      ),
      hintStyle: TextStyle(color: textMuted.withOpacity(0.6)),
      prefixIconColor: richBrown,
      suffixIconColor: richBrown,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: golden.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: golden.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: richBrown, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 8,
        shadowColor: richBrown.withOpacity(0.3),
        minimumSize: const Size.fromHeight(56),
        backgroundColor: richBrown,
        foregroundColor: cream,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontFamily: 'Georgia',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 2,
        shadowColor: golden.withOpacity(0.2),
        minimumSize: const Size.fromHeight(56),
        foregroundColor: richBrown,
        side: const BorderSide(color: richBrown, width: 2.5),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontFamily: 'Georgia',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: richBrown,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Georgia',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: darkBrown,
      contentTextStyle: const TextStyle(
        color: cream,
        fontFamily: 'Georgia',
        fontSize: 15,
      ),
      elevation: 8,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: golden.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: golden.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: richBrown, width: 2),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightCream,
      selectedItemColor: richBrown,
      unselectedItemColor: textMuted.withOpacity(0.6),
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: richBrown,
      linearMinHeight: 4,
    ),
  );

  // Utility gradients for enhanced UI
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [richBrown, darkBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accentGradient = const LinearGradient(
    colors: [golden, accentGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightCream, surfaceLight],
  );

  static BoxShadow premiumShadow = BoxShadow(
    color: shadowColor,
    blurRadius: 16,
    offset: const Offset(0, 8),
    spreadRadius: 0,
  );

  static BoxShadow softShadow = BoxShadow(
    color: shadowColor,
    blurRadius: 8,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );
}
