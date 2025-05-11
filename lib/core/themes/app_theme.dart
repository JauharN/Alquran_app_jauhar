import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import 'text_styles.dart';

class AppTheme {
  // Private constructor untuk singleton
  AppTheme._();

  // Radius standar untuk aplikasi
  static const double borderRadius = 16.0;
  static const double cardElevation = 4.0;

  // Light Theme (Tema utama aplikasi)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.light,
        surfaceContainerHighest: AppColors.primary,
        error: AppColors.red,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        onSurfaceVariant: AppColors.white,
        onError: AppColors.white,
        brightness: Brightness.light,
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: AppColors.card,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.heading,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2.0),
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.secondary,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.white,
        selectedLabelStyle: AppTextStyles.navBarSelected,
        unselectedLabelStyle: AppTextStyles.navBarUnselected,
        type: BottomNavigationBarType.fixed,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.grey.withValues(alpha: 0.3),
        thickness: 1,
        space: 16,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.light,
        selectedColor: AppColors.secondary,
        labelStyle: AppTextStyles.chipText,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius / 2),
        ),
      ),
    );
  }

  // Dark Theme (Tema malam)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Color(0xFF1E1E1E),
        surfaceContainerHighest: AppColors.background,
        error: AppColors.red,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onSurfaceVariant: AppColors.white,
        onError: AppColors.white,
        brightness: Brightness.dark,
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: const Color(0xFF262626),
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.heading,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        filled: true,
        fillColor: const Color(0xFF303030),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.primary,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge:
            AppTextStyles.displayLarge.copyWith(color: AppColors.white),
        displayMedium:
            AppTextStyles.displayMedium.copyWith(color: AppColors.white),
        displaySmall:
            AppTextStyles.displaySmall.copyWith(color: AppColors.white),
        headlineMedium:
            AppTextStyles.headlineMedium.copyWith(color: AppColors.white),
        headlineSmall:
            AppTextStyles.headlineSmall.copyWith(color: AppColors.white),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.white),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.white.withValues(alpha: 7.0),
        selectedLabelStyle: AppTextStyles.navBarSelected,
        unselectedLabelStyle: AppTextStyles.navBarUnselected,
        type: BottomNavigationBarType.fixed,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.grey.withValues(alpha: 30),
        thickness: 1,
        space: 16,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF323232),
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.chipText.copyWith(color: AppColors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius / 2),
        ),
      ),
    );
  }

  // Definisi gradients untuk tema Chinese
  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          Color(0xFFD4A017), // Variasi kuning emas
        ],
      );

  static LinearGradient get secondaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.secondary,
          Color(0xFF0F2E68), // Variasi biru tua
        ],
      );

  static LinearGradient get cardGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE6B325), // Kuning emas
          Color(0xFFD4A017), // Variasi kuning emas
        ],
      );

  // Shadow styles untuk tema Chinese
  static List<BoxShadow> get chineseShadow => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.red.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}

// Extension untuk akses mudah theme context
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
