import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:adhan/adhan.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:intl/intl.dart';
import '../../data/datasources/db_local_datasource.dart';
import 'prayer_notification_service.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();

  factory BackgroundService() {
    return _instance;
  }

  BackgroundService._internal();

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Konfigurasi service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'prayer_times_service',
        initialNotificationTitle: 'Waktu Sholat',
        initialNotificationContent: 'Mempersiapkan jadwal sholat...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  // Fungsi yang dipanggil saat service berjalan
  static Future<void> onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }

    // Inisialisasi service notifikasi
    final notificationService = PrayerNotificationService();
    await notificationService.initialize();

    // Jadwalkan timer untuk update notifikasi setiap menit
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      _updatePrayerTimes(service);
    });

    // Update pertama kali
    _updatePrayerTimes(service);

    // Listen untuk perintah dari aplikasi utama
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  // Update waktu sholat
  static Future<void> _updatePrayerTimes(ServiceInstance service) async {
    try {
      final notificationService = PrayerNotificationService();
      final dbLocalDatasource = DbLocalDatasource();

      // Ambil lokasi dari penyimpanan lokal
      final latLng = await dbLocalDatasource.getLatLng();
      if (latLng.isEmpty) return;

      double lat = latLng[0];
      double lng = latLng[1];

      // Dapatkan nama lokasi
      String locationName = "Unknown Location";
      try {
        // Gunakan geocoding untuk mendapatkan nama lokasi
        // (perlu implementasi khusus - gunakan package geocoding)
        locationName = await _getLocationName(lat, lng);
      } catch (e) {
        debugPrint('Error getting location name: $e');
      }

      // Hitung waktu sholat
      final coordinates = Coordinates(lat, lng);
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(coordinates, params);
      final hijriDate =
          Hijriyah.fromDate(DateTime.now().toLocal()).toFormat("dd MMMM yyyy");

      // Map waktu sholat
      final prayerTimesMap = {
        'Fajr': prayerTimes.fajr,
        'Dhuhr': prayerTimes.dhuhr,
        'Asr': prayerTimes.asr,
        'Maghrib': prayerTimes.maghrib,
        'Isha': prayerTimes.isha,
      };

      // Cari waktu sholat berikutnya
      String nextPrayer = 'Fajr';
      DateTime now = DateTime.now();
      for (var entry in prayerTimesMap.entries) {
        if (entry.value.isAfter(now)) {
          nextPrayer = entry.key;
          break;
        }
      }

      // Update notifikasi persisten
      await notificationService.updatePersistentPrayerTimesNotification(
        prayerTimes: prayerTimesMap,
        locationName: locationName,
        hijriDate: hijriDate,
        nextPrayer: nextPrayer,
      );

      // Kirim informasi ke aplikasi utama jika sedang berjalan
      service.invoke('updatePrayerTimes', {
        'nextPrayer': nextPrayer,
        'prayerTimes': prayerTimesMap
            .map((key, value) => MapEntry(key, DateFormat.Hm().format(value))),
        'locationName': locationName,
      });
    } catch (e) {
      debugPrint('Error updating prayer times: $e');
    }
  }

  // Mendapatkan nama lokasi dari koordinat (simplifikasi)
  static Future<String> _getLocationName(double lat, double lng) async {
    // Di implementasi sebenarnya, gunakan geocoding package
    // untuk mendapatkan nama lokasi dari koordinat
    return "Lokasi Anda";
  }

  // Handler untuk iOS background task
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  // Mulai service
  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  // Hentikan service
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
  }
}
