import 'package:equatable/equatable.dart';
import 'package:adhan/adhan.dart';

enum PrayerTimesStatus { initial, loading, loaded, error }

class PrayerTimesState extends Equatable {
  final PrayerTimesStatus status;
  final PrayerTimes? prayerTimes;
  final String? errorMessage;
  final DateTime selectedDate;
  final Coordinates coordinates;
  final String locationName;
  final String? nextPrayer;
  final DateTime? nextPrayerTime;

  const PrayerTimesState({
    this.status = PrayerTimesStatus.initial,
    this.prayerTimes,
    this.errorMessage,
    required this.selectedDate,
    required this.coordinates,
    this.locationName = "Unknown Location",
    this.nextPrayer,
    this.nextPrayerTime,
  });

  factory PrayerTimesState.initial() {
    return PrayerTimesState(
      selectedDate: DateTime.now(),
      coordinates: Coordinates(0, 0), // Default coordinates
    );
  }

  PrayerTimesState copyWith({
    PrayerTimesStatus? status,
    PrayerTimes? prayerTimes,
    String? errorMessage,
    DateTime? selectedDate,
    Coordinates? coordinates,
    String? locationName,
    String? nextPrayer,
    DateTime? nextPrayerTime,
  }) {
    return PrayerTimesState(
      status: status ?? this.status,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      errorMessage: errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
      coordinates: coordinates ?? this.coordinates,
      locationName: locationName ?? this.locationName,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      nextPrayerTime: nextPrayerTime ?? this.nextPrayerTime,
    );
  }

  // Mendapatkan waktu sholat sebagai Map untuk akses mudah
  Map<String, DateTime> get prayerTimesMap {
    if (prayerTimes == null) {
      return {};
    }

    return {
      'Fajr': prayerTimes!.fajr,
      'Sunrise': prayerTimes!.sunrise,
      'Dhuhr': prayerTimes!.dhuhr,
      'Asr': prayerTimes!.asr,
      'Maghrib': prayerTimes!.maghrib,
      'Isha': prayerTimes!.isha,
    };
  }

  // Menghitung waktu imsak (10 menit sebelum Fajr)
  DateTime? get imsak {
    if (prayerTimes == null) return null;
    return prayerTimes!.fajr.subtract(const Duration(minutes: 10));
  }

  // Menghitung durasi countdown ke waktu sholat berikutnya
  Duration get countdownDuration {
    if (nextPrayerTime == null) return Duration.zero;
    final now = DateTime.now();
    if (nextPrayerTime!.isBefore(now)) return Duration.zero;
    return nextPrayerTime!.difference(now);
  }

  @override
  List<Object?> get props => [
        status,
        prayerTimes,
        errorMessage,
        selectedDate,
        coordinates,
        locationName,
        nextPrayer,
        nextPrayerTime
      ];
}
