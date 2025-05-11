import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTextStyles {
  // Private constructor untuk singleton
  AppTextStyles._();

  // Font weights yang umum digunakan
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    color: AppColors.black,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: bold,
    color: AppColors.black,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: bold,
    color: AppColors.black,
    letterSpacing: -0.25,
  );

  // Headline styles
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: bold,
    color: AppColors.black,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: bold,
    color: AppColors.black,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: semiBold,
    color: AppColors.black,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    color: AppColors.black,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: semiBold,
    color: AppColors.black,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    color: AppColors.black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.black,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.black,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    color: AppColors.black,
  );

  // Specialized styles untuk UI components
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    color: AppColors.white,
  );

  static const TextStyle navBarSelected = TextStyle(
    fontSize: 14,
    fontWeight: semiBold,
    color: AppColors.secondary,
  );

  static const TextStyle navBarUnselected = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.white,
  );

  static const TextStyle chipText = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    color: AppColors.black,
  );

  // Specialized styles untuk aplikasi
  static const TextStyle quranArabic = TextStyle(
    fontSize: 28,
    fontWeight: medium,
    color: AppColors.black,
    fontFamily: 'Uthmanic',
  );

  static const TextStyle quranTranslation = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.black,
  );

  static const TextStyle prayerTime = TextStyle(
    fontSize: 24,
    fontWeight: bold,
    color: AppColors.white,
  );

  static const TextStyle prayerName = TextStyle(
    fontSize: 16,
    fontWeight: semiBold,
    color: AppColors.white,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    color: AppColors.white,
  );

  static const TextStyle chineseTitle = TextStyle(
    fontSize: 20,
    fontWeight: bold,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );
}

// Extension untuk modifikasi TextStyle
extension TextStyleExtensions on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);

  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  TextStyle withSize(double size) => copyWith(fontSize: size);

  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);

  TextStyle withHeight(double height) => copyWith(height: height);
}
