import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/colors.dart';

/// Utility untuk membangun dan menampilkan notifikasi
class NotificationBuilder {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi plugin notifikasi
  static Future<void> initialize() async {
    // Inisialisasi plugin dengan setting default untuk Android dan iOS
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
        // Callback saat notifikasi ditekan
        print('Notification clicked: ${response.payload}');
      },
    );
  }

  /// Membuat dan menampilkan notifikasi sederhana
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'quran_app_channel',
      'Quran App Notifications',
      channelDescription: 'Notifications from Quran App',
      importance: Importance.high,
      priority: Priority.high,
      color: AppColors.primary,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Membuat dan menampilkan notifikasi waktu sholat
  static Future<void> showPrayerNotification({
    required String prayerName,
    required String locationName,
    String? payload,
    int id = 0,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'prayer_times_channel',
      'Prayer Times Notifications',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      color: AppColors.primary,
      sound: const RawResourceAndroidNotificationSound('mecca'),
      styleInformation: const BigTextStyleInformation(''),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      'Waktu Sholat $prayerName',
      'Telah memasuki waktu sholat $prayerName untuk $locationName',
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Membuat notifikasi ongoing (persistent) untuk waktu sholat
  static Future<void> showOngoingPrayerTimesNotification({
    required Map<String, String> prayerTimes,
    required String locationName,
    required String hijriDate,
    int id = 1,
  }) async {
    // Buat konten untuk notifikasi
    String content = 'Jadwal Sholat untuk $locationName\n$hijriDate\n\n';
    prayerTimes.forEach((key, value) {
      content += '$key: $value\n';
    });

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'prayer_times_persistent',
      'Persistent Prayer Times',
      channelDescription: 'Persistent notification for prayer times',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      color: AppColors.primary,
      styleInformation: BigTextStyleInformation(content),
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      'Jadwal Waktu Sholat',
      content,
      platformChannelSpecifics,
    );
  }

  /// Membatalkan notifikasi berdasarkan ID
  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Membatalkan semua notifikasi
  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
