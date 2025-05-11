import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:alarm/alarm.dart';
import '../../core/services/build_alarm_settings.dart';
import '../../core/utils/permission_utils.dart';
import '../../data/datasources/db_local_datasource.dart';
import '../notifications/notifications_bloc.dart';
import '../notifications/notifications_event.dart';
import 'prayer_times_event.dart';
import 'prayer_times_state.dart';

class PrayerTimesBloc extends Bloc<PrayerTimesEvent, PrayerTimesState> {
  final DbLocalDatasource dbLocalDatasource;
  Timer? _countdownTimer;
  BuildContext? _savedContext;

  PrayerTimesBloc({required this.dbLocalDatasource})
      : super(PrayerTimesState.initial()) {
    on<LoadPrayerTimes>(_onLoadPrayerTimes);
    on<UpdateCoordinates>(_onUpdateCoordinates);
    on<SelectDate>(_onSelectDate);
    on<InitializePrayerTimes>(_onInitializePrayerTimes);
    on<SetPrayerAlarms>(_onSetPrayerAlarms);

    // Mulai timer untuk countdown
    _startCountdownTimer();
  }

  FutureOr<void> _onInitializePrayerTimes(
      InitializePrayerTimes event, Emitter<PrayerTimesState> emit) async {
    emit(state.copyWith(status: PrayerTimesStatus.loading));

    // Simpan context untuk digunakan nanti
    if (event.context != null) {
      _savedContext = event.context;
    }

    try {
      // Muat lokasi dari penyimpanan lokal
      await _loadLocation(emit);

      // Muat waktu sholat berdasarkan lokasi yang dimuat
      add(LoadPrayerTimes(
        date: DateTime.now(),
        coordinates: state.coordinates,
        context: _savedContext,
      ));

      // Set alarm untuk waktu sholat
      add(SetPrayerAlarms());
    } catch (e) {
      emit(state.copyWith(
        status: PrayerTimesStatus.error,
        errorMessage: 'Failed to initialize prayer times: $e',
      ));
    }
  }

  Future<void> _loadLocation(Emitter<PrayerTimesState> emit) async {
    await requestLocationPermission();
    final latLng = await dbLocalDatasource.getLatLng();

    if (latLng.isEmpty) {
      await _refreshLocation(emit);
    } else {
      double lat = latLng[0];
      double lng = latLng[1];

      final coordinates = Coordinates(lat, lng);
      String locationName = await _getLocationName(lat, lng);

      emit(state.copyWith(
        coordinates: coordinates,
        locationName: locationName,
      ));

      // Muat waktu sholat berdasarkan koordinat
      add(LoadPrayerTimes(
        date: state.selectedDate,
        coordinates: coordinates,
        context: _savedContext,
      ));
    }
  }

  Future<void> _refreshLocation(Emitter<PrayerTimesState> emit) async {
    await requestLocationPermission();
    final location = await determinePosition();
    final coordinates = Coordinates(location.latitude, location.longitude);
    String locationName =
        await _getLocationName(location.latitude, location.longitude);

    await dbLocalDatasource.saveLatLng(location.latitude, location.longitude);

    emit(state.copyWith(
      coordinates: coordinates,
      locationName: locationName,
    ));

    // Muat waktu sholat berdasarkan koordinat baru
    add(LoadPrayerTimes(
      date: state.selectedDate,
      coordinates: coordinates,
      context: _savedContext,
    ));
  }

  Future<String> _getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String city =
            placemark.locality ?? placemark.subAdministrativeArea ?? "Unknown";
        return city;
      }
    } catch (e) {
      print("Error getting location name: $e");
    }
    return "Unknown Location";
  }

  FutureOr<void> _onLoadPrayerTimes(
      LoadPrayerTimes event, Emitter<PrayerTimesState> emit) async {
    emit(state.copyWith(status: PrayerTimesStatus.loading));

    // Simpan context jika tersedia
    if (event.context != null) {
      _savedContext = event.context;
    }

    try {
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;

      final dateComponents = DateComponents.from(event.date);
      final prayerTimes = PrayerTimes(
        event.coordinates,
        dateComponents,
        params,
      );

      // Cari waktu sholat berikutnya
      final nextPrayerInfo = _getNextPrayer(prayerTimes);

      emit(state.copyWith(
        status: PrayerTimesStatus.loaded,
        prayerTimes: prayerTimes,
        selectedDate: event.date,
        nextPrayer: nextPrayerInfo['name'],
        nextPrayerTime: nextPrayerInfo['time'],
      ));

      // Update notifikasi persisten jika context tersedia
      if (_savedContext != null) {
        try {
          final notificationBloc =
              BlocProvider.of<NotificationsBloc>(_savedContext!);
          notificationBloc.add(UpdatePersistentNotification(
            coordinates: event.coordinates,
            locationName: state.locationName,
          ));
        } catch (e) {
          print('Error updating notification: $e');
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: PrayerTimesStatus.error,
        errorMessage: 'Failed to load prayer times: $e',
      ));
    }
  }

  FutureOr<void> _onSetPrayerAlarms(
      SetPrayerAlarms event, Emitter<PrayerTimesState> emit) async {
    if (state.prayerTimes == null) return;

    try {
      final params = CalculationMethod.singapore.getParameters();
      params.madhab = Madhab.shafi;

      // Hitung waktu sholat untuk hari ini
      final prayerTimes = PrayerTimes.today(state.coordinates, params);

      // List waktu adzan
      List<DateTime> prayerTimesList = [
        prayerTimes.fajr,
        prayerTimes.dhuhr,
        prayerTimes.asr,
        prayerTimes.maghrib,
        prayerTimes.isha,
      ];

      // Nama adzan
      List<String> prayerNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
      DateTime now = DateTime.now();

      // Cancel all existing alarms before setting new ones
      await Alarm.stopAll();

      for (int i = 0; i < prayerTimesList.length; i++) {
        DateTime prayerTime = prayerTimesList[i];

        // Jika waktu sholat sudah lewat untuk hari ini, atur alarm untuk besok
        if (prayerTime.isBefore(now)) {
          prayerTime = prayerTime.add(const Duration(days: 1));
        }

        // Set alarm untuk waktu sholat yang valid
        Alarm.set(
          alarmSettings: buildAlarmSettings(
            staircaseFade: false,
            volume: 0.5,
            fadeDuration: null,
            selectedDateTime: prayerTime,
            loopAudio: true,
            vibrate: true,
            assetAudio: 'assets/audios/mecca.mp3',
            adhan: prayerNames[i],
            locationNow: state.locationName,
          ),
        );
      }
    } catch (e) {
      print("Error setting prayer alarms: $e");
    }
  }

  FutureOr<void> _onUpdateCoordinates(
      UpdateCoordinates event, Emitter<PrayerTimesState> emit) async {
    emit(state.copyWith(
      coordinates: event.coordinates,
      locationName: event.locationName,
    ));

    // Setelah koordinat diupdate, muat waktu sholat baru
    add(LoadPrayerTimes(
      date: state.selectedDate,
      coordinates: event.coordinates,
      context: _savedContext,
    ));

    // Simpan koordinat baru ke local storage
    await dbLocalDatasource.saveLatLng(
        event.coordinates.latitude, event.coordinates.longitude);

    // Update alarm sholat dengan lokasi baru
    add(SetPrayerAlarms());
  }

  FutureOr<void> _onSelectDate(
      SelectDate event, Emitter<PrayerTimesState> emit) {
    emit(state.copyWith(selectedDate: event.date));

    // Muat waktu sholat untuk tanggal yang dipilih
    add(LoadPrayerTimes(
      date: event.date,
      coordinates: state.coordinates,
      context: _savedContext,
    ));
  }

  // Mencari waktu sholat berikutnya
  Map<String, dynamic> _getNextPrayer(PrayerTimes prayerTimes) {
    final now = DateTime.now();
    final times = {
      'Fajr': prayerTimes.fajr,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    // Cari waktu sholat berikutnya
    for (var entry in times.entries) {
      if (entry.value.isAfter(now)) {
        return {'name': entry.key, 'time': entry.value};
      }
    }

    // Jika semua waktu sholat untuk hari ini sudah lewat, gunakan Fajr hari berikutnya
    final tomorrowDate = DateTime.now().add(const Duration(days: 1));
    final tomorrowDateComponents = DateComponents.from(tomorrowDate);

    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    final tomorrowPrayerTimes = PrayerTimes(
      state.coordinates,
      tomorrowDateComponents,
      params,
    );

    return {'name': 'Fajr', 'time': tomorrowPrayerTimes.fajr};
  }

  // Timer untuk memperbarui countdown setiap detik
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.nextPrayerTime != null) {
        final now = DateTime.now();
        if (now.isAfter(state.nextPrayerTime!)) {
          // Jika waktu sholat berikutnya telah tiba, perbarui waktu sholat
          add(LoadPrayerTimes(
            date: state.selectedDate,
            coordinates: state.coordinates,
            context: _savedContext,
          ));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
