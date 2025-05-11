import 'package:flutter/material.dart';
import 'package:flutter_alquran_jauhar_app/data/datasources/db_local_datasource.dart';
import 'package:flutter_alquran_jauhar_app/data/models/bookmark_model.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/colors.dart';
import '../../core/extensions/build_context_ext.dart';
import '../../core/themes/text_styles.dart';
import '../../core/components/shadow_box.dart';
import '../../core/components/gradient_container.dart';
import 'widget/ayat_widget.dart';

class AyatPage extends StatefulWidget {
  final Surah? surah;
  final Juz? juz;
  final QuranPage? page;
  final bool lastReading;
  final BookmarkModel? bookmarkModel;

  const AyatPage({
    super.key,
    this.surah,
    this.juz,
    this.page,
    this.lastReading = false,
    this.bookmarkModel,
  });

  factory AyatPage.ofSurah(
    Surah surah, {
    bool lastReading = false,
    BookmarkModel? bookmark,
  }) =>
      AyatPage(
        surah: surah,
        lastReading: lastReading,
        bookmarkModel: bookmark,
      );

  @override
  State<AyatPage> createState() => _AyatPageState();
}

class _AyatPageState extends State<AyatPage>
    with SingleTickerProviderStateMixin {
  Surah? surah;
  Juz? juz;
  QuranPage? page;
  final List<dynamic> surahVersList = [];
  QuranLanguage translationLanguage = QuranLanguage.indonesian;
  Map<int, Map<int, Verse>> translatedVerses = {};
  int lastReadIndex = 0;
  ItemScrollController itemScrollController = ItemScrollController();
  bool _isTranslationEnabled = true;
  double _arabicFontSize = 28.0;
  double _translationFontSize = 14.0;

  // Animasi
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  Future<void> scrollToLastRead() async {
    lastReadIndex =
        widget.bookmarkModel != null ? widget.bookmarkModel!.ayatNumber : 0;

    if (itemScrollController.isAttached) {
      await itemScrollController.scrollTo(
        duration: const Duration(seconds: 1),
        index: widget.lastReading ? lastReadIndex : 0,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void initState() {
    _initAnimation();

    surah = widget.surah;
    juz = widget.juz;
    page = widget.page;
    translatedVerses = Quran.getQuranVerses(language: translationLanguage);

    // Tambahkan bismillah dan ayat-ayat surah ke list
    if (surah != null) {
      if (surah!.number != 9) {
        // Surah At-Taubah tidak dimulai dengan bismillah
        surahVersList.add(surah);
      }
      surahVersList.addAll(Quran.getSurahVersesAsList(surah!.number));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToLastRead();
    });

    super.initState();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _toggleTranslation() {
    setState(() {
      _isTranslationEnabled = !_isTranslationEnabled;
    });
  }

  void _increaseFontSize() {
    setState(() {
      _arabicFontSize = _arabicFontSize >= 40.0 ? 40.0 : _arabicFontSize + 2.0;
      _translationFontSize =
          _translationFontSize >= 20.0 ? 20.0 : _translationFontSize + 1.0;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _arabicFontSize = _arabicFontSize <= 20.0 ? 20.0 : _arabicFontSize - 2.0;
      _translationFontSize =
          _translationFontSize <= 10.0 ? 10.0 : _translationFontSize - 1.0;
    });
  }

  void _shareVerse(Verse verse) {
    final translatedVerse =
        translatedVerses[verse.surahNumber]![verse.verseNumber];
    final surahInfo = Quran.getSurah(verse.surahNumber);

    final textToShare =
        "Surah ${surahInfo.nameEnglish} (${verse.surahNumber}:${verse.verseNumber})\n\n"
        "${verse.text}\n\n"
        "${translatedVerse!.text}\n\n"
        "Dibagikan dari aplikasi Muslim App";

    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          surah != null
              ? 'Surah ${surah!.nameEnglish}'
              : juz != null
                  ? 'Juz ${juz!.number}'
                  : 'Page ${page?.number}',
          style: AppTextStyles.heading.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: _toggleTranslation,
            icon: Icon(
              _isTranslationEnabled
                  ? Icons.translate
                  : Icons.translate_outlined,
              color: Colors.white,
            ),
            tooltip: 'Tampilkan/Sembunyikan Terjemahan',
          ),
          IconButton(
            onPressed: _increaseFontSize,
            icon: const Icon(Icons.zoom_in, color: Colors.white),
            tooltip: 'Perbesar Font',
          ),
          IconButton(
            onPressed: _decreaseFontSize,
            icon: const Icon(Icons.zoom_out, color: Colors.white),
            tooltip: 'Perkecil Font',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSurahInfo(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation!,
              child: ScrollablePositionedList.builder(
                itemScrollController: itemScrollController,
                itemCount: surahVersList.length,
                itemBuilder: (context, index) {
                  dynamic item = surahVersList[index];

                  if (item is Surah && surah!.number != 9) {
                    return _buildBismillah();
                  } else if (item is Verse) {
                    return AyatWidget(
                      verse: item,
                      translationLanguage: translationLanguage,
                      translatedVerses: translatedVerses,
                      isTranslationEnabled: _isTranslationEnabled,
                      arabicFontSize: _arabicFontSize,
                      translationFontSize: _translationFontSize,
                      onBookmark: () => _showBookmarkDialog(item),
                      onShare: () => _shareVerse(item),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scrollToLastRead,
        backgroundColor: AppColors.secondary,
        tooltip: 'Pergi ke Bookmark',
        child: const Icon(Icons.bookmark, color: Colors.white),
      ),
    );
  }

  Widget _buildSurahInfo() {
    if (surah == null) return const SizedBox.shrink();

    // Konversi SurahType ke string yang dapat dibaca
    String typeText =
        surah!.type == SurahType.meccan ? "Makkiyah" : "Madaniyah";

    return GradientContainer(
      gradientType: GradientType.secondary,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            surah!.name, // Nama dalam bahasa Arab
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Uthmanic',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            surah!.nameEnglish,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$typeText · ${surah!.verseCount} Ayat', // Menggunakan variabel typeText
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 200.0),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 30.0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Arti: ${surah!.meaning}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return ShadowBox(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      color: AppColors.primary.withValues(alpha: 80.0),
      border: Border.all(
        color: AppColors.secondary.withValues(alpha: 50.0),
        width: 1,
      ),
      child: const Column(
        children: [
          Text(
            Quran.bismillah,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontFamily: 'Uthmanic',
            ),
          ),
        ],
      ),
    );
  }

  void _showBookmarkDialog(Verse verse) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColors.secondary,
              width: 1,
            ),
          ),
          title: Text(
            "Simpan Bacaan Terakhir",
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_added,
                color: AppColors.secondary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Apakah Anda ingin menyimpan bacaan terakhir di ${surah!.nameEnglish}, Ayat ${verse.verseNumber}?",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
              ),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                BookmarkModel model = BookmarkModel(
                  surah!.nameEnglish,
                  surah!.number,
                  verse.verseNumber,
                );
                await DbLocalDatasource().saveBookmark(model);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Bacaan terakhir disimpan!",
                      style: TextStyle(color: AppColors.white),
                    ),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
              ),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }
}
