import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../themes/text_styles.dart';
import 'gradient_container.dart';

/// Widget untuk menampilkan kartu waktu sholat dengan tema Chinese
class PrayerCard extends StatelessWidget {
  /// Judul waktu sholat (e.g., Fajr, Dhuhr, etc.)
  final String title;

  /// Waktu sholat dalam format DateTime
  final DateTime time;

  /// Apakah waktu sholat ini active/next
  final bool isActive;

  /// Callback ketika kartu ditekan
  final VoidCallback? onTap;

  /// Format waktu (default: HH:mm)
  final String Function(DateTime)? timeFormatter;

  const PrayerCard({
    Key? key,
    required this.title,
    required this.time,
    this.isActive = false,
    this.onTap,
    this.timeFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedTime = timeFormatter != null
        ? timeFormatter!(time)
        : DateFormat.Hm().format(time);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.black,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            Text(
              formattedTime,
              style: AppTextStyles.titleLarge.copyWith(
                color: isActive ? AppColors.primary : AppColors.black,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan waktu sholat berikutnya dengan highlight
class NextPrayerCard extends StatelessWidget {
  /// Nama waktu sholat berikutnya
  final String prayerName;

  /// Waktu sholat berikutnya
  final DateTime prayerTime;

  /// Durasi countdown ke waktu sholat berikutnya
  final Duration countdownDuration;

  /// Lokasi saat ini
  final String location;

  /// Tanggal Hijriyah
  final String hijriDate;

  const NextPrayerCard({
    Key? key,
    required this.prayerName,
    required this.prayerTime,
    required this.countdownDuration,
    required this.location,
    required this.hijriDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat.Hm().format(prayerTime);
    final hours = countdownDuration.inHours;
    final minutes = (countdownDuration.inMinutes % 60);
    final seconds = (countdownDuration.inSeconds % 60);

    final countdownText =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return GradientContainer(
      gradientType: GradientType.secondary,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                location,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
              Text(
                hijriDate,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerName,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedTime,
                    style: AppTextStyles.displayMedium.copyWith(
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
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    countdownText,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications,
                color: AppColors.white,
              ),
              label: Text(
                'Lihat Jadwal',
                style: AppTextStyles.buttonText,
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan semua waktu sholat hari ini
class PrayerTimesCard extends StatelessWidget {
  /// Map dari nama waktu sholat ke waktu (DateTime)
  final Map<String, DateTime> prayerTimes;

  /// Nama waktu sholat berikutnya
  final String? nextPrayer;

  /// Callback ketika header diklik
  final VoidCallback? onHeaderTap;

  const PrayerTimesCard({
    Key? key,
    required this.prayerTimes,
    this.nextPrayer,
    this.onHeaderTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortedPrayers = [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha',
    ];

    final translatedNames = {
      'Fajr': 'Subuh',
      'Sunrise': 'Terbit',
      'Dhuhr': 'Dzuhur',
      'Asr': 'Ashar',
      'Maghrib': 'Maghrib',
      'Isha': 'Isya',
    };

    return ChineseBorderContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            onTap: onHeaderTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Jadwal Waktu Sholat',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            color: AppColors.primary,
            thickness: 1,
          ),
          const SizedBox(height: 8),
          ...sortedPrayers.map((prayerName) {
            if (!prayerTimes.containsKey(prayerName)) {
              return const SizedBox.shrink();
            }

            final isNext = prayerName == nextPrayer;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: PrayerCard(
                title: translatedNames[prayerName] ?? prayerName,
                time: prayerTimes[prayerName]!,
                isActive: isNext,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
