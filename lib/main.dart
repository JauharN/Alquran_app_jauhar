import 'package:adhan/adhan.dart';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'core/services/build_alarm_settings.dart';
import 'core/utils/permission_utils.dart';
import 'package:geocoding/geocoding.dart';
import 'core/constants/colors.dart';
import 'core/utils/permission.dart';
import 'data/datasources/db_local_datasource.dart';
import 'presentation/home/main_page.dart';
import 'package:quran_flutter/quran_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Quran.initialize();
  await Alarm.init();
  AlarmPermissions.checkNotificationPermission();
  if (Alarm.android) {
    AlarmPermissions.checkAndroidScheduleExactAlarmPermission();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  var myCoordinates = Coordinates(-7.7421697, 110.3751855);
  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double? volume;
  late Duration? fadeDuration;
  late bool staircaseFade;
  late String assetAudio;
  String locationNow = 'Kab Sleman, Indonesia';

  @override
  void initState() {
    // selectedDateTime = DateTime.now().add(const Duration(hours: 12));
    // selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
    loopAudio = true;
    vibrate = true;
    // volume = null;
    volume = 0.5;
    fadeDuration = null;
    staircaseFade = false;
    assetAudio = 'assets/audios/mecca.mp3';
    loadLocation().then((_) {
      _setPrayerAlarms();
    });
    super.initState();
  }

  Future<void> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String city = placemark.locality ?? "Unknown";
        setState(() {
          locationNow = city; // Set nama kota
        });
        print("Location: $city");
      }
    } catch (e) {
      print("Error getting location name: $e");
    }
  }

  refreshLocation() async {
    await requestLocationPermission();
    final location = await determinePosition();
    myCoordinates = Coordinates(location.latitude, location.longitude);
    String latLng = '${location.latitude},${location.longitude}';
    await getLocationName(location.latitude, location.longitude);
    await DbLocalDatasource().saveLatLng(location.latitude, location.longitude);
  }

  Future<void> loadLocation() async {
    await requestLocationPermission();
    final latLng = await DbLocalDatasource().getLatLng();

    if (latLng.isEmpty) {
      await refreshLocation();
    } else {
      double lat = latLng[0];
      double lng = latLng[1];

      myCoordinates = Coordinates(lat, lng);
      await getLocationName(lat, lng);
    }
  }

  Future<void> _setPrayerAlarms() async {
    // Koordinat lokasi
    // var myCoordinates = Coordinates(-7.7421697, 110.3751855);
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    // Hitung waktu sholat untuk hari ini
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

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
    await Alarm.stopAll(); // Membatalkan semua alarm yang sudah ada

    for (int i = 0; i < prayerTimesList.length; i++) {
      DateTime prayerTime = prayerTimesList[i];

      // Jika waktu sholat sudah lewat untuk hari ini, atur alarm untuk besok
      if (prayerTime.isBefore(now)) {
        prayerTime = prayerTime.add(const Duration(days: 1));
      }

      // Set alarm untuk waktu sholat yang valid
      Alarm.set(
        alarmSettings: buildAlarmSettings(
          staircaseFade: staircaseFade,
          volume: volume!,
          fadeDuration: fadeDuration,
          selectedDateTime: prayerTime,
          loopAudio: loopAudio,
          vibrate: vibrate,
          assetAudio: assetAudio,
          adhan: prayerNames[i],
          locationNow: locationNow,
        ),
      ).then((res) {
        // log('Alarm untuk ${prayerNames[i]} diatur pada $prayerTime');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}
