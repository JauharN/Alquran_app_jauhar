import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import 'dart:math' as math;

class CompassWidget extends StatelessWidget {
  final double rotation;
  final double qiblaRotation;
  final bool isCalibrating;
  final Animation<double>? animation;

  const CompassWidget({
    Key? key,
    required this.rotation,
    required this.qiblaRotation,
    this.isCalibrating = false,
    this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Lingkaran Luar - Dekoratif dengan tema Chinese
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 5,
            ),
          ),
        ),

        // Lingkaran Tengah - Dekorasi dengan tema Chinese
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 100),
              width: 2,
            ),
          ),
        ),

        // Lingkaran dalam dengan Tanda Mata Angin
        Transform.rotate(
          angle: rotation,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 150),
                width: 1,
              ),
            ),
            child: CustomPaint(
              painter: CompassPainter(
                isCalibrating: isCalibrating,
                animation: animation,
              ),
            ),
          ),
        ),

        // Panah Arah Kiblat
        Transform.rotate(
          angle: qiblaRotation,
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Shadow for the arrow
                  Container(
                    height: 100,
                    width: 16,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 150),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 100),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 4,
                        height: 100,
                        color: AppColors.secondary,
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.secondary,
                        size: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  final bool isCalibrating;
  final Animation<double>? animation;

  CompassPainter({
    this.isCalibrating = false,
    this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Titik kardinal kompas
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Gambar lingkaran
    canvas.drawCircle(center, radius, paint);

    // Text painter untuk arah
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Gambar arah kardinal
    for (int i = 0; i < directions.length; i++) {
      final angle = (i * (3.14159 * 2 / 8)); // 8 arah
      final x = center.dx + radius * 0.8 * -sin(angle);
      final y = center.dy - radius * 0.8 * cos(angle);

      final textStyle = TextStyle(
        color: directions[i] == 'N' ? AppColors.red : AppColors.white,
        fontSize: directions[i] == 'N' ||
                directions[i] == 'S' ||
                directions[i] == 'E' ||
                directions[i] == 'W'
            ? 16
            : 12,
        fontWeight: directions[i] == 'N' ? FontWeight.bold : FontWeight.normal,
      );

      textPainter.text = TextSpan(
        text: directions[i],
        style: textStyle,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Tambahkan tanda pada kompas
    for (int i = 0; i < 72; i++) {
      final angle = (i * (3.14159 * 2 / 72));
      final outerX = center.dx + radius * 0.95 * -sin(angle);
      final outerY = center.dy - radius * 0.95 * cos(angle);
      final innerX = center.dx +
          radius *
              (i % 9 == 0
                  ? 0.85
                  : 0.9) * // Tanda lebih panjang di tiap 40 derajat
              -sin(angle);
      final innerY =
          center.dy - radius * (i % 9 == 0 ? 0.85 : 0.9) * cos(angle);

      final linePaint = Paint()
        ..color = i % 9 == 0
            ? AppColors.secondary
            : AppColors.white.withValues(alpha: 150)
        ..strokeWidth = i % 9 == 0 ? 2 : 1;

      canvas.drawLine(
        Offset(outerX, outerY),
        Offset(innerX, innerY),
        linePaint,
      );
    }

    // Efek animasi kalibrasi
    if (isCalibrating && animation != null) {
      final calibrationPaint = Paint()
        ..color =
            AppColors.secondary.withValues(alpha: (100.0 * animation!.value))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawCircle(center, radius * 0.97, calibrationPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return isCalibrating;
  }

  // Helper untuk sin dan cos yang menerima input dalam radian
  double sin(double angle) => math.sin(angle);
  double cos(double angle) => math.cos(angle);
}
