import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alquran_jauhar_app/data/models/bookmark_model.dart';
import 'package:quran_flutter/quran_flutter.dart';
import '../../core/components/spaces.dart';
import '../../core/constants/colors.dart';
import '../../data/datasources/db_local_datasource.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:intl/intl.dart';

import '../quran/ayat_page.dart';
import '../sholat/sholat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String locationNow = 'Sleman, Indonesia';
  PrayerTimes? prayerTimes;
  String nextPrayerName = 'Tidak diketahui';

  String? nextPrayerTime;
  Duration countdownDuration = Duration.zero;
  Timer? countdownTimer;
  String? now;
  Verse? lastVerseRead;
  Verse? lastVerseReadTranslate;

  BookmarkModel? lastRead;

  void _getBookmark() async {
    final bookmark = await DbLocalDatasource().getBookmark();
    setState(() {
      lastRead = bookmark;
      lastVerseRead = Quran.getVerse(
        surahNumber: lastRead?.suratNumber ?? 1,
        verseNumber: lastRead?.ayatNumber ?? 1,
      );

      lastVerseReadTranslate = Quran.getVerse(
        surahNumber: lastRead?.suratNumber ?? 1,
        verseNumber: lastRead?.ayatNumber ?? 1,
        language: QuranLanguage.indonesian,
      );
    });
  }

  void _startCountdown() {
    countdownTimer?.cancel(); // Pastikan timer sebelumnya dihentikan
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (countdownDuration.inSeconds > 0) {
          countdownDuration -= const Duration(seconds: 1);
        } else {
          _calculatePrayerTimes(); // Jika waktu habis, hitung ulang waktu sholat
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _calculatePrayerTimes() async {
    List latLng = await DbLocalDatasource().getLatLng();
    double? lat;
    double? lng;

    if (latLng.isNotEmpty) {
      lat = latLng[0];
      lng = latLng[1];
    } else {
      lat = -6.91746;
      lng = 107.61913;
    }

    // Lokasi (ganti dengan koordinat lokasi pengguna)
    final myCoordinates = Coordinates(lat!, lng!); // Contoh Jakarta
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(myCoordinates, date, params);

    // Dapatkan waktu sholat dalam urutan yang benar
    final times = {
      'Fajr': prayerTimes.fajr,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    // Ambil waktu saat ini
    DateTime now = DateTime.now();
    String? upcomingPrayer;
    DateTime? upcomingTime;

    for (var entry in times.entries) {
      if (entry.value.isAfter(now)) {
        upcomingPrayer = entry.key;
        upcomingTime = entry.value;
        break;
      }
    }

    // Jika sudah lewat Isya, maka tampilkan Subuh hari berikutnya
    if (upcomingPrayer == null) {
      upcomingPrayer = "Fajr";
      upcomingTime = PrayerTimes(
        myCoordinates,
        DateComponents.from(DateTime.now().add(const Duration(days: 1))),
        params,
      ).fajr;
    }
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      // myCoordinates = Coordinates(double.parse(lat), double.parse(lng));
      Placemark place = placemarks[0];
      locationNow = "${place.subAdministrativeArea}, ${place.country}";
    }
    setState(() {
      nextPrayerName = upcomingPrayer!;
      nextPrayerTime = DateFormat.Hm().format(upcomingTime!);
      countdownDuration = upcomingTime.difference(now);
    });

    _startCountdown();

    // geocoding  from lat lng
  }

  @override
  void initState() {
    now = DateFormat('dd MMMM yyyy').format(DateTime.now());
    _calculatePrayerTimes();
    // Verse verse = Quran.getVerse(surahNumber: 1, verseNumber: 5);
    // print(verse.text);

    _getBookmark();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SpaceHeight(42.0),
          Container(
            padding: const EdgeInsets.all(20.0),
            height: 320.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              image: DecorationImage(
                image: AssetImage(
                  DateTime.now().hour >= 6 && DateTime.now().hour < 18
                      ? 'assets/images/duhur.png' // jam 6 am - 6 pm
                      : 'assets/images/banner.png', // jam 6 pm - 6 am
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationNow,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      now ?? '',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                    // SizedBox(height: 10.0),
                    Text(
                      Hijriyah.fromDate(
                        DateTime.now().toLocal(),
                      ).toFormat("dd MMMM yyyy"),
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      '$nextPrayerName | $nextPrayerTime',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '- ${_formatDuration(countdownDuration)}',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SholatPage()));
                    },
                    child: const Text('Lihat Semua'),
                  ),
                )
              ],
            ),
          ),
          const SpaceHeight(24.0),
          lastRead == null
              ? const Center(
                  child: Text(
                    'Belum ada Bookmark ayat',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Text(
                      'Bacaan Terakhir (${lastRead?.suratName ?? ''} : ${lastRead?.ayatNumber})',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
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
                      child: const Text(
                        'Lanjut Baca',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
          const SpaceHeight(24.0),
          lastRead == null
              ? const SizedBox()
              : Card(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(
                      lastVerseRead!.text,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white,
                          fontFamily: 'Uthmanic'),
                    ),
                    subtitle: Text(
                      lastVerseReadTranslate!.text,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
          // ListView.builder(
          //   padding: EdgeInsets.zero,
          //   itemBuilder: (context, index) {
          //     return const Card(
          //       color: Colors.transparent,
          //       child: ListTile(
          //         title: Text(
          //           'Ayat',
          //           textAlign: TextAlign.right,
          //           style: TextStyle(
          //             fontSize: 22.0,
          //             fontWeight: FontWeight.w400,
          //             color: AppColors.white,
          //           ),
          //         ),
          //         subtitle: Text(
          //           'Terjemah',
          //           style: TextStyle(
          //             fontSize: 12.0,
          //             fontWeight: FontWeight.w400,
          //             color: AppColors.white,
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          //   itemCount: 10,
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          // ),
        ],
      ),
    );
  }
}
