import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adhan/adhan.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import '../../core/services/prayer_notification_service.dart';
import '../../core/services/background_service.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final PrayerNotificationService _notificationService =
      PrayerNotificationService();

  NotificationsBloc() : super(NotificationsState.initial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<ToggleNotifications>(_onToggleNotifications);
    on<SchedulePrayerNotifications>(_onSchedulePrayerNotifications);
    on<CancelAllNotifications>(_onCancelAllNotifications);
    on<UpdatePersistentNotification>(_onUpdatePersistentNotification);
  }

  FutureOr<void> _onInitializeNotifications(
      InitializeNotifications event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      await _notificationService.initialize();
      final enabled = await _notificationService.isNotificationEnabled();

      if (enabled) {
        // Mulai background service jika notifikasi diaktifkan
        await BackgroundService.initialize();
        await BackgroundService.startService();
      }

      emit(state.copyWith(
        status: NotificationStatus.success,
        notificationsEnabled: enabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: 'Failed to initialize notifications: $e',
      ));
    }
  }

  FutureOr<void> _onToggleNotifications(
      ToggleNotifications event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      await _notificationService.setNotificationEnabled(event.enabled);

      if (event.enabled) {
        // Mulai background service jika notifikasi diaktifkan
        await BackgroundService.initialize();
        await BackgroundService.startService();
      } else {
        // Hentikan background service jika notifikasi dinonaktifkan
        await BackgroundService.stopService();
        await _notificationService.cancelAllNotifications();
      }

      emit(state.copyWith(
        status: NotificationStatus.success,
        notificationsEnabled: event.enabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: 'Failed to toggle notifications: $e',
      ));
    }
  }

  FutureOr<void> _onSchedulePrayerNotifications(
      SchedulePrayerNotifications event,
      Emitter<NotificationsState> emit) async {
    if (!state.notificationsEnabled) return;

    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      // Hitung waktu sholat lengkap
      final coordinates = event.coordinates;
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(coordinates, params);

      // Jadwalkan notifikasi untuk semua waktu sholat
      await _notificationService.scheduleAllPrayerNotifications(
        prayerTimes: prayerTimes,
        locationName: event.locationName,
      );

      emit(state.copyWith(status: NotificationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: 'Failed to schedule notifications: $e',
      ));
    }
  }

  FutureOr<void> _onUpdatePersistentNotification(
      UpdatePersistentNotification event,
      Emitter<NotificationsState> emit) async {
    if (!state.notificationsEnabled) return;

    try {
      // Hitung waktu sholat
      final coordinates = event.coordinates;
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
      await _notificationService.updatePersistentPrayerTimesNotification(
        prayerTimes: prayerTimesMap,
        locationName: event.locationName,
        hijriDate: hijriDate,
        nextPrayer: nextPrayer,
      );
    } catch (e) {
      // Tidak perlu update state untuk operasi background
      print('Error updating persistent notification: $e');
    }
  }

  FutureOr<void> _onCancelAllNotifications(
      CancelAllNotifications event, Emitter<NotificationsState> emit) async {
    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      await _notificationService.cancelAllNotifications();
      emit(state.copyWith(status: NotificationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: 'Failed to cancel notifications: $e',
      ));
    }
  }
}
