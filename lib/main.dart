// Update lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adhan/adhan.dart';
import 'package:alarm/alarm.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'core/utils/permission.dart';
import 'data/datasources/db_local_datasource.dart';
import 'core/themes/app_theme.dart';
import 'core/services/prayer_notification_service.dart';
import 'core/services/background_service.dart';
import 'bloc/bloc_providers.dart';
import 'bloc/theme/theme_bloc.dart';
import 'bloc/theme/theme_state.dart';
import 'bloc/prayer_times/prayer_times_bloc.dart';
import 'bloc/prayer_times/prayer_times_event.dart';
import 'bloc/notifications/notifications_bloc.dart';
import 'bloc/notifications/notifications_event.dart';
import 'presentation/home/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi packages
  await Quran.initialize();
  await Alarm.init();

  // Cek permission
  AlarmPermissions.checkNotificationPermission();
  if (Alarm.android) {
    AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
  }

  // Inisialisasi notifikasi service
  final notificationService = PrayerNotificationService();
  await notificationService.initialize();

  // Inisialisasi background service
  await BackgroundService.initialize();

  // Jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: BlocProviders.getProviders(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'Quran & Prayer Times',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode == ThemeMode.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            home: Builder(
              builder: (context) {
                // Inisialisasi waktu sholat dan notifikasi dengan context
                Future.delayed(Duration.zero, () {
                  context
                      .read<PrayerTimesBloc>()
                      .add(InitializePrayerTimes(context: context));
                  context
                      .read<NotificationsBloc>()
                      .add(InitializeNotifications());
                });

                return const MainPage();
              },
            ),
          );
        },
      ),
    );
  }
}
