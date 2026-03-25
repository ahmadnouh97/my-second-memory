import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens
class AppColors {
  // Base
  static const background = Color(0xFF080B1E);
  static const surface = Color(0xFF0F1330);
  static const surfaceElevated = Color(0xFF161B3D);
  static const border = Color(0xFF252D5A);

  // Primary — Electric Indigo
  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4338CA);

  // Accent — Warm Amber (AI/sparkle)
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFCD34D);

  // Content type colours
  static const youtube = Color(0xFFEF4444);
  static const instagram = Color(0xFFA855F7);
  static const linkedin = Color(0xFF0A66C2);
  static const github = Color(0xFF6E7681);
  static const facebook = Color(0xFF1877F2);
  static const tiktok = Color(0xFF69C9D0);
  static const reddit = Color(0xFFFF4500);
  static const other = Color(0xFF6B7280);

  // Text
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF475569);

  // Semantic
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);

  // Gradients
  static const gradientStart = Color(0xFF0A0E27);
  static const gradientEnd = Color(0xFF1E1B4B);
}

/// Reusable gradient shorthands
class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );

  static LinearGradient cardGlass(Color accentColor) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentColor.withValues(alpha: 0.08),
          AppColors.surfaceElevated,
        ],
      );

  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryLight, AppColors.primaryDark],
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5),
      displayMedium: GoogleFonts.inter(
        fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      labelSmall: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted),
    );

    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.accent,
      onSecondary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceElevated,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.border,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w400),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.primary.withValues(alpha: 0.25),
        side: const BorderSide(color: AppColors.border),
        labelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      // Divider
      dividerTheme: const DividerThemeData(
          color: AppColors.border, thickness: 1, space: 1),
      // Icon
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
        contentTextStyle: GoogleFonts.inter(
            fontSize: 14, color: AppColors.textSecondary),
      ),
      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
