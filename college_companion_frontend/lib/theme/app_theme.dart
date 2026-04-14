import 'package:flutter/material.dart';

class AppTheme {
  // Indigo / purple palette
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color backgroundLavender = Color(0xFFF8F7FF);
  static const Color primaryLight = Color(0xFFF5F3FF);
  static const Color primaryAccent = Color(0xFF7C3AED);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFF1A1A1A);
  static const Color accentSoft = Color(0xFFEDE9FE);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color shadowColor = Color(0x1A000000);

  // Backward-compatible aliases for existing screens.
  static const Color richBrown = primaryDark;
  static const Color darkBrown = primaryDark;
  static const Color golden = primaryAccent;
  static const Color accentGold = primaryAccent;
  static const Color cream = surface;
  static const Color lightCream = primaryLight;
  static const Color surfaceLight = accentSoft;
  static const Color textDark = onPrimary;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF4F46E5),
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryDark,
      secondary: primaryAccent,
      tertiary: primaryAccent,
      surface: surface,
      onPrimary: onPrimary,
      onSecondary: onPrimary,
      onSurface: onPrimary,
    ),
    scaffoldBackgroundColor: backgroundLavender,
    fontFamily: 'Georgia',
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: primaryDark,
      foregroundColor: surface,
      elevation: 8,
      surfaceTintColor: primaryDark,
      shadowColor: shadowColor,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: surface,
        letterSpacing: 0.5,
        fontFamily: 'Georgia',
      ),
      iconTheme: IconThemeData(color: surface, size: 24),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 8,
      shadowColor: shadowColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accentSoft, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: accentSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(
        color: onPrimary.withOpacity(0.7),
        fontWeight: FontWeight.w500,
        fontFamily: 'Georgia',
      ),
      hintStyle: TextStyle(color: textMuted.withOpacity(0.6)),
      prefixIconColor: primaryDark,
      suffixIconColor: primaryDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accentSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accentSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryDark, width: 2.5),
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
        shadowColor: primaryDark.withOpacity(0.3),
        minimumSize: const Size.fromHeight(56),
        backgroundColor: primaryDark,
        foregroundColor: surface,
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
        shadowColor: primaryAccent.withOpacity(0.2),
        minimumSize: const Size.fromHeight(56),
        foregroundColor: primaryDark,
        side: const BorderSide(color: primaryDark, width: 2.5),
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
        foregroundColor: primaryDark,
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
      backgroundColor: primaryDark,
      contentTextStyle: const TextStyle(
        color: surface,
        fontFamily: 'Georgia',
        fontSize: 15,
      ),
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: accentSoft, thickness: 1),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primaryDark,
      unselectedItemColor: textMuted.withOpacity(0.6),
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      linearMinHeight: 4,
    ),
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient iconGradientA = LinearGradient(
    colors: [Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient iconGradientB = LinearGradient(
    colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLavender, surface],
  );

  static Widget appBarFlexibleSpace() {
    return Stack(
      children: [
        Container(decoration: const BoxDecoration(gradient: primaryGradient)),
        Positioned(
          top: -24,
          right: -28,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -16,
          left: -10,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  static Widget headerPullUpLayer() {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Container(
        height: 24,
        decoration: BoxDecoration(
          color: backgroundLavender,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
    );
  }

  static const BoxShadow premiumShadow = BoxShadow(
    color: shadowColor,
    blurRadius: 16,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  static const BoxShadow softShadow = BoxShadow(
    color: shadowColor,
    blurRadius: 8,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );
}
