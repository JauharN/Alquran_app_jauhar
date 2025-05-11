import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:adhan/adhan.dart';
import '../constants/colors.dart';

class PrayerNotificationService {
  static final PrayerNotificationService _instance =
      PrayerNotificationService._internal();

  factory PrayerNotificationService() {
    return _instance;
  }

  PrayerNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _ongoingNotificationId = 100;

  /// Inisialisasi notifikasi
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    // Inisialisasi plugin notifikasi
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notifikasi diklik
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    _initialized = true;
  }

  /// Cek apakah notifikasi diaktifkan
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('prayerNotificationEnabled') ?? true;
  }

  /// Aktifkan/nonaktifkan notifikasi
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayerNotificationEnabled', enabled);

    if (!enabled) {
      await cancelAllNotifications();
    }
  }

  /// Update notifikasi persisten waktu sholat
  Future<void> updatePersistentPrayerTimesNotification({
    required Map<String, DateTime> prayerTimes,
    required String locationName,
    required String hijriDate,
    required String nextPrayer,
  }) async {
    if (!await isNotificationEnabled()) return;

    await initialize();

    final translatedNames = {
      'Fajr': 'Subuh',
      'Sunrise': 'Terbit',
      'Dhuhr': 'Dzuhur',
      'Asr': 'Ashar',
      'Maghrib': 'Maghrib',
      'Isha': 'Isya',
    };

    Map<String, String> formattedTimes = {};
    prayerTimes.forEach((key, value) {
      formattedTimes[translatedNames[key] ?? key] =
          DateFormat.Hm().format(value);
    });

    // Siapkan style untuk notifikasi
    const String androidPlatformChannelId = 'prayer_times_ongoing';

    // Buat notification details
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidPlatformChannelId,
      'Prayer Times',
      channelDescription: 'Ongoing notification for prayer times',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      color: AppColors.primary,
      colorized: true,
      styleInformation: BigTextStyleInformation(
        _buildNotificationContent(
            formattedTimes, locationName, hijriDate, nextPrayer),
        htmlFormatBigText: true,
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // Tampilkan notifikasi persisten
    await flutterLocalNotificationsPlugin.show(
      _ongoingNotificationId,
      '<font color="#E6B325">Waktu Sholat</font>',
      _buildNotificationContentShort(formattedTimes, nextPrayer),
      notificationDetails,
    );
  }

  /// Membangun konten notifikasi
  String _buildNotificationContent(Map<String, String> prayerTimes,
      String locationName, String hijriDate, String nextPrayer) {
    final translatedNextPrayer = {
          'Fajr': 'Subuh',
          'Dhuhr': 'Dzuhur',
          'Asr': 'Ashar',
          'Maghrib': 'Maghrib',
          'Isha': 'Isya',
        }[nextPrayer] ??
        nextPrayer;

    String content = '<b>$locationName</b> | $hijriDate<br>';

    prayerTimes.forEach((key, value) {
      if (key == translatedNextPrayer) {
        content += '<b>$key: <font color="#E6B325">$value</font></b><br>';
      } else {
        content += '$key: $value<br>';
      }
    });

    return content;
  }

  /// Membangun konten singkat notifikasi
  String _buildNotificationContentShort(
      Map<String, String> prayerTimes, String nextPrayer) {
    final translatedNextPrayer = {
          'Fajr': 'Subuh',
          'Dhuhr': 'Dzuhur',
          'Asr': 'Ashar',
          'Maghrib': 'Maghrib',
          'Isha': 'Isya',
        }[nextPrayer] ??
        nextPrayer;

    String content = '';
    prayerTimes.forEach((key, value) {
      if (content.isNotEmpty) content += ' | ';
      if (key == translatedNextPrayer) {
        content += '<b>$key: <font color="#E6B325">$value</font></b>';
      } else {
        content += '$key: $value';
      }
    });

    return content;
  }

  /// Jadwalkan notifikasi untuk waktu sholat berikutnya
  Future<void> schedulePrayerNotification({
    required String prayerName,
    required DateTime prayerTime,
    required String locationName,
  }) async {
    if (!await isNotificationEnabled()) return;

    await initialize();

    // Skip jika waktu sholat sudah lewat
    if (prayerTime.isBefore(DateTime.now())) return;

    final translatedName = {
          'Fajr': 'Subuh',
          'Dhuhr': 'Dzuhur',
          'Asr': 'Ashar',
          'Maghrib': 'Maghrib',
          'Isha': 'Isya',
        }[prayerName] ??
        prayerName;

    // Buat notification details
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'prayer_time_alert',
      'Prayer Time Alerts',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      color: AppColors.primary,
      sound: RawResourceAndroidNotificationSound('mecca'),
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // Jadwalkan notifikasi dengan parameter yang benar
    await flutterLocalNotificationsPlugin.zonedSchedule(
      prayerTime.millisecondsSinceEpoch ~/ 1000, // ID unik berdasarkan waktu
      'Waktu Sholat $translatedName',
      'Telah masuk waktu sholat $translatedName untuk $locationName',
      tz.TZDateTime.from(prayerTime, tz.local),
      notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // Parameter yang diperlukan
    );
  }

  /// Jadwalkan semua notifikasi waktu sholat untuk hari ini
  Future<void> scheduleAllPrayerNotifications({
    required PrayerTimes prayerTimes,
    required String locationName,
  }) async {
    if (!await isNotificationEnabled()) return;

    // Cancel semua notifikasi yang ada terlebih dahulu
    await cancelScheduledNotifications();

    // Map waktu sholat
    final prayers = {
      'Fajr': prayerTimes.fajr,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    // Jadwalkan notifikasi untuk setiap waktu sholat
    for (var entry in prayers.entries) {
      await schedulePrayerNotification(
        prayerName: entry.key,
        prayerTime: entry.value,
        locationName: locationName,
      );
    }
  }

  /// Batalkan notifikasi persisten
  Future<void> cancelPersistentNotification() async {
    await initialize();
    await flutterLocalNotificationsPlugin.cancel(_ongoingNotificationId);
  }

  /// Batalkan semua notifikasi terjadwal
  Future<void> cancelScheduledNotifications() async {
    await initialize();
    await flutterLocalNotificationsPlugin.cancelAll();
    // Notifikasi persisten perlu dikembalikan
    // (dihandle oleh updatePersistentPrayerTimesNotification)
  }

  /// Batalkan semua notifikasi
  Future<void> cancelAllNotifications() async {
    await initialize();
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
