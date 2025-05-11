import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../themes/app_theme.dart';

/// Widget container dengan shadow bergaya Chinese
///
/// Dapat diatur warna, border radius, shadow, dan lainnya
class ShadowBox extends StatelessWidget {
  /// Widget yang ditampilkan di dalam container
  final Widget child;

  /// Warna background
  final Color color;

  /// Border radius
  final double borderRadius;

  /// Padding dalam
  final EdgeInsetsGeometry padding;

  /// Margin luar
  final EdgeInsetsGeometry margin;

  /// Tinggi container (null = sesuai content)
  final double? height;

  /// Lebar container (null = sesuai content)
  final double? width;

  /// Apakah menggunakan shadow bergaya Chinese
  final bool useChineseShadow;

  /// Ukuran shadow (hanya berlaku jika useChineseShadow = false)
  final double elevation;

  /// Dekorasi tambahan (jika diberikan, color dan borderRadius akan diabaikan)
  final BoxDecoration? decoration;

  /// Border untuk container
  final Border? border;

  const ShadowBox({
    Key? key,
    required this.child,
    this.color = Colors.white,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.height,
    this.width,
    this.useChineseShadow = true,
    this.elevation = 4.0,
    this.decoration,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: decoration ??
          BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border,
            boxShadow: useChineseShadow
                ? AppTheme.chineseShadow
                : [
                    BoxShadow(
                      color: AppColors.black
                          .withValues(alpha: (elevation * 8).toDouble()),
                      blurRadius: elevation * 2,
                      offset: Offset(0, elevation),
                    ),
                  ],
          ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Container khusus untuk menampilkan informasi
class InfoBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final IconData? icon;
  final String? title;
  final EdgeInsetsGeometry margin;

  const InfoBox({
    Key? key,
    required this.child,
    this.color = Colors.white,
    this.icon,
    this.title,
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShadowBox(
      padding: const EdgeInsets.all(16),
      margin: margin,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || icon != null)
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon!, color: AppColors.primary),
                  const SizedBox(width: 8),
                ],
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          if (title != null || icon != null) const Divider(height: 16),
          child,
        ],
      ),
    );
  }
}

/// Card dengan pattern Chinese border khusus
class ChinesePatternCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ChinesePatternCard({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.red,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppTheme.chineseShadow,
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 50),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 50),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
