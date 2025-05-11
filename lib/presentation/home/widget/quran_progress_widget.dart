import 'package:flutter/material.dart';
import 'package:quran_flutter/quran_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/themes/text_styles.dart';

class QuranProgressWidget extends StatelessWidget {
  final String surahName;
  final int surahNumber;
  final int ayatNumber;
  final Surah surah;
  final VoidCallback onContinueReading;

  const QuranProgressWidget({
    super.key,
    required this.surahName,
    required this.surahNumber,
    required this.ayatNumber,
    required this.surah,
    required this.onContinueReading,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    final double progress =
        surah.verseCount > 0 ? ayatNumber / surah.verseCount : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 200),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 30),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$surahNumber',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surah.meaning,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withValues(alpha: 180),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ayat $ayatNumber dari ${surah.verseCount}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.white.withValues(alpha: 50),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.secondary),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: onContinueReading,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Lanjutkan Membaca'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
