import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/datasources/db_local_datasource.dart';
import 'theme/theme_bloc.dart';
import 'theme/theme_event.dart';
import 'prayer_times/prayer_times_bloc.dart';
import 'notifications/notifications_bloc.dart';
import 'notifications/notifications_event.dart';

class BlocProviders {
  BlocProviders._();

  static List<BlocProvider> getProviders() {
    return [
      BlocProvider<ThemeBloc>(
        create: (context) {
          final bloc = ThemeBloc();
          // Initialize theme from saved preferences
          bloc.add(ThemeInitialized());
          return bloc;
        },
      ),
      BlocProvider<PrayerTimesBloc>(
        create: (context) {
          final bloc = PrayerTimesBloc(
            dbLocalDatasource: DbLocalDatasource(),
          );
          return bloc;
        },
      ),
      BlocProvider<NotificationsBloc>(
        create: (context) {
          final bloc = NotificationsBloc();
          // Initialize notification settings
          bloc.add(InitializeNotifications());
          return bloc;
        },
      ),
    ];
  }
}
