import 'dart:developer';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alquran_jauhar_app/core/components/spaces.dart';
import 'package:flutter_alquran_jauhar_app/core/extensions/build_context_ext.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../../core/constants/colors.dart';
import '../../core/utils/permission_utils.dart';
import '../../data/datasources/db_local_datasource.dart';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage> {
  var myCoordinates = Coordinates(-7.7421697, 110.3751855);
  final params = CalculationMethod.singapore.getParameters();
  String? imsak;
  String? fajr;
  String? sunrise;
  String? dhuhr;
  String? asr;
  String? maghrib;
  String? isha;

  DateTime selectedDate = DateTime.now();
  String locationNow = 'Kab Sleman, Indonesia';

  @override
  void initState() {
    params.madhab = Madhab.shafi;
    // params.adjustments.fajr = 2;
    // params.adjustments.sunrise = 2;
    // params.adjustments.dhuhr = 3;
    // params.adjustments.asr = 3;
    // params.adjustments.maghrib = 4;
    // params.adjustments.isha = 2;

    loadLocation();
    super.initState();
  }

  // ketika pilih date otomatis data akan berubah pakai function ini berdasarkan date time
  void calculatePrayerTimes(DateTime date) {
    DateComponents dateComponents = DateComponents(
      date.year,
      date.month,
      date.day,
    );
    final prayerTimes = PrayerTimes(myCoordinates, dateComponents, params);

    setState(() {
      imsak = DateFormat.jm().format(
        prayerTimes.fajr.subtract(const Duration(minutes: 10)),
      );
      fajr = DateFormat.jm().format(prayerTimes.fajr);
      sunrise = DateFormat.jm().format(prayerTimes.sunrise);
      dhuhr = DateFormat.jm().format(prayerTimes.dhuhr);
      asr = DateFormat.jm().format(prayerTimes.asr);
      maghrib = DateFormat.jm().format(prayerTimes.maghrib);
      isha = DateFormat.jm().format(prayerTimes.isha);
      selectedDate = date;
    });
  }

  void onChangeDate(int days) {
    DateTime newDate = selectedDate.add(Duration(days: days));
    calculatePrayerTimes(newDate);
  }

  refreshLocation() async {
    await requestLocationPermission();
    final location = await determinePosition();
    // String latLng = '${location.latitude},${location.longitude}';
    myCoordinates = Coordinates(location.latitude, location.longitude);
    List<Placemark> placemarks = await placemarkFromCoordinates(
      location.latitude,
      location.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      locationNow = "${place.subAdministrativeArea}, ${place.country}";
      final prayerTimes = PrayerTimes.today(myCoordinates, params);

      imsak = DateFormat.jm().format(
        prayerTimes.fajr.subtract(const Duration(minutes: 10)),
      );
      fajr = DateFormat.jm().format(prayerTimes.fajr);
      sunrise = DateFormat.jm().format(prayerTimes.sunrise);
      dhuhr = DateFormat.jm().format(prayerTimes.dhuhr);
      asr = DateFormat.jm().format(prayerTimes.asr);
      maghrib = DateFormat.jm().format(prayerTimes.maghrib);
      isha = DateFormat.jm().format(prayerTimes.isha);
      setState(() {});
    }
    await DbLocalDatasource().saveLatLng(location.latitude, location.longitude);
  }

  loadLocation() async {
    await requestLocationPermission();
    final latLng = await DbLocalDatasource().getLatLng();
    if (latLng.isEmpty) {
      refreshLocation();
    } else {
      double lat = latLng[0];
      double lng = latLng[1];
      // myCoordinates = Coordinates(double.parse(lat), double.parse(lng));
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        myCoordinates = Coordinates(lat, lng);
        Placemark place = placemarks[0];
        locationNow = "${place.subAdministrativeArea}, ${place.country}";
        final prayerTimes = PrayerTimes.today(myCoordinates, params);

        imsak = DateFormat.jm().format(
          prayerTimes.fajr.subtract(const Duration(minutes: 10)),
        );
        fajr = DateFormat.jm().format(prayerTimes.fajr);
        sunrise = DateFormat.jm().format(prayerTimes.sunrise);
        dhuhr = DateFormat.jm().format(prayerTimes.dhuhr);
        asr = DateFormat.jm().format(prayerTimes.asr);
        maghrib = DateFormat.jm().format(prayerTimes.maghrib);
        isha = DateFormat.jm().format(prayerTimes.isha);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: AppColors.white,
            )),
        title: const Text('Sholat', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2050),
                initialDate: selectedDate, // Menggunakan tanggal saat ini
              );

              if (pickedDate != null) {
                selectedDate = pickedDate;
                calculatePrayerTimes(pickedDate);
              }
            },
            icon: const Icon(Icons.calendar_month, color: Colors.white),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  locationNow,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
              const SpaceWidth(10),
              IconButton(
                  onPressed: () {
                    log("Refresh Location");
                    refreshLocation();
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.white,
                  )),
            ],
          ),
          const SpaceHeight(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  onChangeDate(-1);
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 32.0,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                onPressed: () {
                  onChangeDate(1);
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 32.0,
                ),
              ),
            ],
          ),
          const SpaceHeight(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Imsak',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Text(
                  imsak ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subuh',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Text(
                  fajr ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Terbit',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Text(
                  sunrise ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dzuhur',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Text(
                  dhuhr ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ashar',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Text(
                  asr ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maghrib',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Text(
                  maghrib ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Isya',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Text(
                  isha ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
