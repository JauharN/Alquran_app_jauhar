import 'package:flutter/material.dart';
import 'package:quran_flutter/enums/quran_language.dart';
import 'package:quran_flutter/models/verse.dart';

import '../../../core/constants/colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../core/components/shadow_box.dart';

class AyatWidget extends StatelessWidget {
  final Verse verse;
  final QuranLanguage translationLanguage;
  final Map<int, Map<int, Verse>> translatedVerses;
  final bool isTranslationEnabled;
  final double arabicFontSize;
  final double translationFontSize;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const AyatWidget({
    super.key,
    required this.verse,
    required this.translationLanguage,
    required this.translatedVerses,
    this.isTranslationEnabled = true,
    this.arabicFontSize = 28.0,
    this.translationFontSize = 14.0,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return ShadowBox(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(0),
      borderRadius: 16,
      color: AppColors.primary.withValues(alpha: 50.0),
      border: Border.all(
        color: AppColors.secondary.withValues(alpha: 30.0),
        width: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerseHeader(),
          _buildArabicText(),
          if (isTranslationEnabled) _buildTranslation(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildVerseHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 30.0),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                verse.verseNumber.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Surah ${verse.surahNumber} : ${verse.verseNumber}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArabicText() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.secondary.withValues(alpha: 30.0),
            width: 1,
          ),
        ),
      ),
      child: Text(
        verse.text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: arabicFontSize,
          height: 1.7,
          color: AppColors.white,
          fontFamily: 'Uthmanic',
        ),
      ),
    );
  }

  Widget _buildTranslation() {
    final translatedVerse =
        translatedVerses[verse.surahNumber]![verse.verseNumber];

    if (translatedVerse == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terjemahan:',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 150.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            translatedVerse.text,
            textAlign:
                translationLanguage.isRTL ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: translationFontSize,
              height: 1.5,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: onBookmark,
            icon: const Icon(Icons.bookmark_outline,
                color: AppColors.secondary, size: 18),
            label: const Text(
              'Bookmark',
              style: TextStyle(color: AppColors.secondary, fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: AppColors.secondary.withValues(alpha: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined,
                color: AppColors.secondary, size: 18),
            label: const Text(
              'Bagikan',
              style: TextStyle(color: AppColors.secondary, fontSize: 12),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: AppColors.secondary.withValues(alpha: 20.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
