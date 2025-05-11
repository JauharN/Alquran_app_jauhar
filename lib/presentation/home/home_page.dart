import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:intl/intl.dart';
import 'package:quran_flutter/quran_flutter.dart';

import '../../bloc/prayer_times/prayer_times_bloc.dart';
import '../../bloc/prayer_times/prayer_times_event.dart';
import '../../bloc/prayer_times/prayer_times_state.dart';
import '../../core/components/shadow_box.dart';
import '../../core/components/spaces.dart';
import '../../core/constants/colors.dart';
import '../../core/themes/text_styles.dart';
import '../../data/datasources/db_local_datasource.dart';
import '../../data/models/bookmark_model.dart';
import '../quran/ayat_page.dart';
import '../sholat/sholat_page.dart';
import 'widget/menu_grid.dart';
import 'widget/quran_progress_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String locationNow = 'Mengambil lokasi...';
  String? now;
  Verse? lastVerseRead;
  Verse? lastVerseReadTranslate;
  BookmarkModel? lastRead;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);

    // Atur tanggal hari ini
    now = DateFormat('dd MMMM yyyy').format(DateTime.now());

    // Ambil bookmark terakhir
    _getBookmark();

    // Muat waktu sholat
    context
        .read<PrayerTimesBloc>()
        .add(InitializePrayerTimes(context: context));

    setState(() => isLoading = false);
  }

  void _getBookmark() async {
    final bookmark = await DbLocalDatasource().getBookmark();
    if (!mounted) return;

    setState(() {
      lastRead = bookmark;
      if (bookmark != null) {
        lastVerseRead = Quran.getVerse(
          surahNumber: lastRead?.suratNumber ?? 1,
          verseNumber: lastRead?.ayatNumber ?? 1,
        );

        lastVerseReadTranslate = Quran.getVerse(
          surahNumber: lastRead?.suratNumber ?? 1,
          verseNumber: lastRead?.ayatNumber ?? 1,
          language: QuranLanguage.indonesian,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hijriDate =
        Hijriyah.fromDate(DateTime.now().toLocal()).toFormat("dd MMMM yyyy");

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              await _initializeData();
            },
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.secondary))
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    children: [
                      _buildHeader(context, state, hijriDate),
                      const SpaceHeight(16.0),
                      _buildNextPrayerCard(context, state),
                      const SpaceHeight(24.0),
                      _buildQuranProgressSection(),
                      const SpaceHeight(24.0),
                      _buildMenuGrid(context),
                      const SpaceHeight(24.0),
                      if (lastRead != null) _buildLastReadVerseCard(),
                    ],
                  ),
          );
        },
      ),
    );
  }

  // Header dengan informasi tanggal
  Widget _buildHeader(
      BuildContext context, PrayerTimesState state, String hijriDate) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.locationName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      now ?? "",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hijriDate,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Refresh location dan prayer times
              context
                  .read<PrayerTimesBloc>()
                  .add(InitializePrayerTimes(context: context));
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Card waktu sholat berikutnya dengan countdown
  Widget _buildNextPrayerCard(BuildContext context, PrayerTimesState state) {
    if (state.status != PrayerTimesStatus.loaded ||
        state.nextPrayer == null ||
        state.nextPrayerTime == null) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    // Map nama sholat dari English ke Indonesia
    final prayerNameMap = {
      'Fajr': 'Subuh',
      'Dhuhr': 'Dzuhur',
      'Asr': 'Ashar',
      'Maghrib': 'Maghrib',
      'Isha': 'Isya',
    };

    final prayerNameID = prayerNameMap[state.nextPrayer] ?? state.nextPrayer!;
    final formattedTime = DateFormat.Hm().format(state.nextPrayerTime!);

    // Format durasi countdown
    final hours = state.countdownDuration.inHours;
    final minutes = (state.countdownDuration.inMinutes % 60);
    final seconds = (state.countdownDuration.inSeconds % 60);
    final countdownText =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary,
            AppColors.secondary.withValues(alpha: 200),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 60),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements (Chinese style)
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 30),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 20),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: AppColors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Waktu Sholat Selanjutnya',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayerNameID,
                          style: AppTextStyles.displaySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedTime,
                          style: AppTextStyles.displayLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Countdown',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.white.withValues(alpha: 200),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            countdownText,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.white,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SholatPage()),
                        );
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Lihat Semua Jadwal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section untuk progress baca Al-Quran
  Widget _buildQuranProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Al-Quran',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Bacaan Terakhir',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                if (lastRead != null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AyatPage.ofSurah(
                        Quran.getSurah(lastRead!.suratNumber),
                        lastReading: true,
                        bookmark: lastRead,
                      ),
                    ),
                  );
                  _getBookmark();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Belum ada bacaan terakhir",
                        style: TextStyle(color: AppColors.black),
                      ),
                      backgroundColor: AppColors.white,
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Text(
                    'Lanjut Baca',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.secondary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        lastRead == null
            ? ShadowBox(
                color: AppColors.secondary.withValues(alpha: 50),
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        color: AppColors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada bookmark ayat',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mulai baca Al-Quran dan bookmark ayat untuk melihatnya di sini',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withValues(alpha: 200),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : QuranProgressWidget(
                surahName: lastRead?.suratName ?? '',
                surahNumber: lastRead?.suratNumber ?? 0,
                ayatNumber: lastRead?.ayatNumber ?? 0,
                surah: Quran.getSurah(lastRead?.suratNumber ?? 1),
                onContinueReading: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AyatPage.ofSurah(
                        Quran.getSurah(lastRead!.suratNumber),
                        lastReading: true,
                        bookmark: lastRead,
                      ),
                    ),
                  );
                  _getBookmark();
                },
              ),
      ],
    );
  }

  // Grid menu untuk fitur-fitur utama
  Widget _buildMenuGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        MenuGrid(
          onMenuSelected: (menu) {
            // Handle menu selection
            switch (menu) {
              case 'alquran':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SholatPage()),
                );
                break;
              case 'qibla':
                // Navigate to qibla compass
                break;
              case 'prayerTimes':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SholatPage()),
                );
                break;
              case 'settings':
                // Navigate to settings
                break;
            }
          },
        ),
      ],
    );
  }

  // Card untuk ayat terakhir yang dibaca
  Widget _buildLastReadVerseCard() {
    if (lastVerseRead == null || lastVerseReadTranslate == null) {
      return const SizedBox.shrink();
    }

    return ShadowBox(
      color: AppColors.primary.withValues(alpha: 150),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      borderRadius: 24,
      border: Border.all(
        color: AppColors.accent.withValues(alpha: 50),
        width: 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 100),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terakhir Dibaca',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Ayat ${lastRead?.ayatNumber} dari ${lastRead?.suratName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 180),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.white, height: 1, thickness: 0.5),
          const SizedBox(height: 16),
          Text(
            lastVerseRead!.text,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w400,
              color: AppColors.white,
              fontFamily: 'Uthmanic',
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            lastVerseReadTranslate!.text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
