import 'dart:developer';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alquran_jauhar_app/bloc/prayer_times/prayer_times_bloc.dart';
import 'package:flutter_alquran_jauhar_app/bloc/prayer_times/prayer_times_event.dart';
import 'package:flutter_alquran_jauhar_app/bloc/prayer_times/prayer_times_state.dart';
import 'package:flutter_alquran_jauhar_app/core/components/spaces.dart';
import 'package:flutter_alquran_jauhar_app/core/extensions/build_context_ext.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../../core/constants/colors.dart';
import '../../core/components/gradient_container.dart';
import '../../core/components/shadow_box.dart';
import '../../core/themes/text_styles.dart';
import '../../core/utils/permission_utils.dart';
import '../../data/datasources/db_local_datasource.dart';

class SholatPage extends StatefulWidget {
  const SholatPage({super.key});

  @override
  State<SholatPage> createState() => _SholatPageState();
}

class _SholatPageState extends State<SholatPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
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
          ),
        ),
        title: const Text(
          'Jadwal Sholat',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2050),
                    initialDate: state.selectedDate,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.secondary,
                            onPrimary: AppColors.white,
                            surface: AppColors.primary,
                            onSurface: AppColors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    context.read<PrayerTimesBloc>().add(SelectDate(pickedDate));
                  }
                },
                icon: const Icon(Icons.calendar_month, color: Colors.white),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
        builder: (context, state) {
          if (state.status == PrayerTimesStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          if (state.status == PrayerTimesStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Terjadi Kesalahan',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Tidak dapat memuat jadwal sholat',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 200.0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<PrayerTimesBloc>()
                          .add(InitializePrayerTimes(context: context));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildContent(state);
        },
      ),
    );
  }

  Widget _buildContent(PrayerTimesState state) {
    final formattedDate = DateFormat('dd MMMM yyyy').format(state.selectedDate);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildLocationHeader(state),
        const SpaceHeight(16.0),
        _buildDateSelector(state, formattedDate),
        const SpaceHeight(24.0),
        FadeTransition(
          opacity: _fadeAnimation!,
          child: _buildPrayerTimesList(state),
        ),
      ],
    );
  }

  Widget _buildLocationHeader(PrayerTimesState state) {
    return GradientContainer(
      gradientType: GradientType.secondary,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: AppColors.white,
          ),
          const SpaceWidth(12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white.withValues(alpha: 180.0),
                  ),
                ),
                const SpaceHeight(4.0),
                Text(
                  state.locationName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _refreshLocation(context);
            },
            icon: const Icon(
              Icons.refresh,
              color: AppColors.white,
            ),
            tooltip: 'Perbarui Lokasi',
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(PrayerTimesState state, String formattedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            final previousDay =
                state.selectedDate.subtract(const Duration(days: 1));
            context.read<PrayerTimesBloc>().add(SelectDate(previousDay));
          },
          icon: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 50.0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20.0,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2050),
              initialDate: state.selectedDate,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.secondary,
                      onPrimary: AppColors.white,
                      surface: AppColors.primary,
                      onSurface: AppColors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              context.read<PrayerTimesBloc>().add(SelectDate(pickedDate));
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.white,
                  size: 16.0,
                ),
                const SpaceWidth(8.0),
                Text(
                  formattedDate,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final nextDay = state.selectedDate.add(const Duration(days: 1));
            context.read<PrayerTimesBloc>().add(SelectDate(nextDay));
          },
          icon: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 50.0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimesList(PrayerTimesState state) {
    if (state.prayerTimes == null) {
      return const Center(
        child: Text(
          'Tidak ada data jadwal sholat',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Data waktu sholat
    final prayerTimes = {
      'Imsak': state.imsak,
      'Subuh': state.prayerTimes!.fajr,
      'Terbit': state.prayerTimes!.sunrise,
      'Dzuhur': state.prayerTimes!.dhuhr,
      'Ashar': state.prayerTimes!.asr,
      'Maghrib': state.prayerTimes!.maghrib,
      'Isya': state.prayerTimes!.isha,
    };

    // Urutan waktu sholat untuk memastikan tampilan yang konsisten
    final orderedPrayers = [
      'Imsak',
      'Subuh',
      'Terbit',
      'Dzuhur',
      'Ashar',
      'Maghrib',
      'Isya',
    ];

    return ShadowBox(
      padding: const EdgeInsets.all(0),
      borderRadius: 16.0,
      color: AppColors.primary.withValues(alpha: 100.0),
      border: Border.all(
        color: AppColors.secondary.withValues(alpha: 50.0),
        width: 1.0,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Center(
              child: Text(
                'Jadwal Waktu Sholat',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderedPrayers.length,
            itemBuilder: (context, index) {
              final prayerName = orderedPrayers[index];
              final prayerTime = prayerTimes[prayerName];

              // Tentukan apakah ini waktu sholat selanjutnya
              final bool isNext = state.nextPrayer != null &&
                  (prayerName == 'Subuh' && state.nextPrayer == 'Fajr' ||
                      prayerName == 'Dzuhur' && state.nextPrayer == 'Dhuhr' ||
                      prayerName == 'Ashar' && state.nextPrayer == 'Asr' ||
                      prayerName == 'Maghrib' &&
                          state.nextPrayer == 'Maghrib' ||
                      prayerName == 'Isya' && state.nextPrayer == 'Isha');

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: isNext
                      ? AppColors.secondary.withValues(alpha: 50.0)
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (isNext)
                          const Icon(
                            Icons.arrow_right,
                            color: AppColors.secondary,
                            size: 24.0,
                          ),
                        Text(
                          prayerName,
                          style: TextStyle(
                            color: isNext ? AppColors.secondary : Colors.white,
                            fontSize: 18.0,
                            fontWeight:
                                isNext ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      prayerTime != null
                          ? DateFormat.Hm().format(prayerTime)
                          : '-',
                      style: TextStyle(
                        color: isNext ? AppColors.secondary : Colors.white,
                        fontSize: 18.0,
                        fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              color: Colors.grey,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _refreshLocation(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Memperbarui lokasi...'),
          backgroundColor: AppColors.secondary,
          duration: Duration(seconds: 2),
        ),
      );

      await requestLocationPermission();
      final location = await determinePosition();
      final coordinates = Coordinates(location.latitude, location.longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      String locationName = "Lokasi Anda";
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        locationName =
            "${placemark.subAdministrativeArea ?? placemark.locality ?? "Lokasi Anda"}, ${placemark.country ?? ""}";
      }

      context.read<PrayerTimesBloc>().add(
            UpdateCoordinates(
              coordinates: coordinates,
              locationName: locationName,
            ),
          );

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log("Error refreshing location: $e");
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
