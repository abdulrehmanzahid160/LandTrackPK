import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF01411C);
  static const Color primaryContainer = Color(0xFFB7F0C8);
  static const Color onPrimaryContainer = Color(0xFF002111);
  static const Color secondary = Color(0xFF1B2A4A);
  static const Color tertiary = Color(0xFFC9A84C); // Accent Gold
  static const Color tertiaryContainer = Color(0xFFFFF0BC);
  static const Color onTertiaryContainer = Color(0xFF231B00);
  static const Color background = Color(0xFFFCF9F8);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F0F5);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onTertiary = Colors.white;
  static const Color onBackground = Color(0xFF1B1B1B);
  static const Color onSurface = Color(0xFF1B1B1B);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double edgeMargin = 20.0;
}

class AppDecorations {
  static BoxDecoration certificateCard = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: AppColors.outlineVariant, width: 1.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0, 4),
        blurRadius: 20,
      ),
    ],
  );

  static BoxDecoration officialCard = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: AppColors.outlineVariant),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0, 2),
        blurRadius: 10,
      ),
    ],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final TextTheme baseTextTheme = GoogleFonts.publicSansTextTheme();
    final TextTheme headlineTextTheme = GoogleFonts.sourceSerif4TextTheme();

    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        error: AppColors.error,
        onError: Colors.white,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.background,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headlineTextTheme.displayLarge?.copyWith(color: AppColors.onBackground),
        displayMedium: headlineTextTheme.displayMedium?.copyWith(color: AppColors.onBackground),
        displaySmall: headlineTextTheme.displaySmall?.copyWith(color: AppColors.onBackground),
        headlineLarge: headlineTextTheme.headlineLarge?.copyWith(color: AppColors.onBackground),
        headlineMedium: headlineTextTheme.headlineMedium?.copyWith(color: AppColors.onBackground),
        headlineSmall: headlineTextTheme.headlineSmall?.copyWith(color: AppColors.onBackground),
        titleLarge: headlineTextTheme.titleLarge?.copyWith(color: AppColors.onBackground, fontWeight: FontWeight.w600),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headlineTextTheme.titleLarge?.copyWith(
          color: AppColors.onBackground,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
        hintStyle: TextStyle(color: AppColors.outline),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Alias for backwards compatibility
  static ThemeData get themeData => lightTheme;
}
