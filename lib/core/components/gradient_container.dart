import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../themes/app_theme.dart';

enum GradientType {
  primary,
  secondary,
  card,
  custom,
}

/// Komponen container dengan gradient yang mengikuti tema Chinese
///
/// Dapat digunakan sebagai wrapper untuk berbagai UI element dengan
/// style gradient yang konsisten
class GradientContainer extends StatelessWidget {
  /// Konten yang akan ditampilkan di dalam container
  final Widget child;

  /// Tipe gradient yang akan digunakan (primary, secondary, atau card)
  final GradientType gradientType;

  /// Gradient kustom jika gradientType adalah custom
  final Gradient? customGradient;

  /// Border radius untuk container
  final double borderRadius;

  /// Ukuran shadow (0 = tidak ada shadow)
  final double elevation;

  /// Padding dalam container
  final EdgeInsetsGeometry padding;

  /// Margin di luar container
  final EdgeInsetsGeometry margin;

  /// Tinggi container (null = ukuran content)
  final double? height;

  /// Lebar container (null = ukuran content)
  final double? width;

  /// Constraint tambahan
  final BoxConstraints? constraints;

  /// Constructor untuk GradientContainer
  const GradientContainer({
    Key? key,
    required this.child,
    this.gradientType = GradientType.primary,
    this.customGradient,
    this.borderRadius = 16.0,
    this.elevation = 4.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.height,
    this.width,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pilih gradient berdasarkan tipe
    Gradient gradient;
    switch (gradientType) {
      case GradientType.primary:
        gradient = AppTheme.primaryGradient;
        break;
      case GradientType.secondary:
        gradient = AppTheme.secondaryGradient;
        break;
      case GradientType.card:
        gradient = AppTheme.cardGradient;
        break;
      case GradientType.custom:
        gradient = customGradient ?? AppTheme.primaryGradient;
        break;
    }

    return Container(
      height: height,
      width: width,
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.black
                      .withValues(alpha: (elevation * 8).toDouble()),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Gradient Container dengan tema Chinese
class ChineseGradientContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? height;
  final double? width;

  const ChineseGradientContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE6B325), // Kuning emas
            Color(0xFFCD8500), // Emas tua
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.chineseShadow,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Container dengan border pattern Chinese
class ChineseBorderContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? height;
  final double? width;

  const ChineseBorderContainer({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.primary,
          width: 2.0,
        ),
        boxShadow: AppTheme.chineseShadow,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
