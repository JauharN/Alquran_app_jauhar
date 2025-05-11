import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhan/adhan.dart';
import '../../bloc/prayer_times/prayer_times_bloc.dart';
import '../../bloc/prayer_times/prayer_times_state.dart';
import '../../core/constants/colors.dart';
import '../../core/themes/text_styles.dart';
import 'widget/compass_widget.dart';

class QiblaCompassPage extends StatefulWidget {
  const QiblaCompassPage({Key? key}) : super(key: key);

  @override
  State<QiblaCompassPage> createState() => _QiblaCompassPageState();
}

class _QiblaCompassPageState extends State<QiblaCompassPage>
    with TickerProviderStateMixin {
  double? _direction;
  double? _qiblaDirection;
  bool _hasPermission = false;
  Animation<double>? _animation;
  AnimationController? _animationController;
  bool _isCalibrating = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _initAnimation();
    _initCompass();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _checkPermission() async {
    try {
      bool hasPermission = await FlutterCompass.events != null;
      setState(() {
        _hasPermission = hasPermission;
      });
    } catch (e) {
      debugPrint("Error checking compass permission: $e");
      setState(() {
        _hasPermission = false;
      });
    }
  }

  void _initCompass() {
    FlutterCompass.events?.listen((CompassEvent event) {
      if (!mounted) return;

      setState(() {
        _direction = event.heading;

        // Setelah mendapatkan arah kompas, hitung arah kiblat
        _calculateQiblaDirection();
      });
    });
  }

  void _calculateQiblaDirection() {
    final prayerTimesState = context.read<PrayerTimesBloc>().state;

    if (prayerTimesState.coordinates.latitude != 0 &&
        prayerTimesState.coordinates.longitude != 0) {
      // Koordinat Ka'bah (Mekah)
      final makkah = Coordinates(21.3891, 39.8579);

      // Koordinat pengguna saat ini
      final userCoordinates = prayerTimesState.coordinates;

      // Hitung arah kiblat dengan metode yang benar
      // Menggunakan rumus Haversine yang lebih sederhana untuk menghitung bearing
      final double qibla = _calculateQiblaAngle(userCoordinates.latitude,
          userCoordinates.longitude, makkah.latitude, makkah.longitude);

      setState(() {
        _qiblaDirection = qibla;
      });
    }
  }

// Fungsi untuk menghitung sudut arah kiblat menggunakan rumus Haversine
  double _calculateQiblaAngle(
      double lat1, double lon1, double lat2, double lon2) {
    // Konversi derajat ke radian
    lat1 = _toRadians(lat1);
    lon1 = _toRadians(lon1);
    lat2 = _toRadians(lat2);
    lon2 = _toRadians(lon2);

    // Hitung perbedaan longitude
    double dLon = lon2 - lon1;

    // Rumus untuk menghitung bearing (sudut)
    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    // Konversi radian ke derajat dan normalisasi (0-360)
    double angle = _toDegrees(math.atan2(y, x));
    angle = (angle + 360) % 360;

    return angle;
  }

// Helper: Konversi derajat ke radian
  double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

// Helper: Konversi radian ke derajat
  double _toDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }

  Future<void> _calibrateCompass() async {
    setState(() {
      _isCalibrating = true;
    });

    // Animasi kalibrasi
    _animationController?.reset();
    _animationController?.repeat();

    // Tunggu beberapa saat untuk simulasi kalibrasi
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isCalibrating = false;
    });

    _animationController?.stop();
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
        title: const Text(
          'Arah Kiblat',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
      ),
      body: BlocBuilder<PrayerTimesBloc, PrayerTimesState>(
        builder: (context, state) {
          if (!_hasPermission) {
            return _buildNoPermissionView();
          }

          if (_direction == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          return _buildCompassView(state);
        },
      ),
    );
  }

  Widget _buildNoPermissionView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 50),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.compass_calibration_outlined,
                  color: AppColors.white,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Akses Sensor Kompas Diperlukan',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Untuk menentukan arah kiblat, aplikasi memerlukan akses ke sensor kompas perangkat Anda.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _checkPermission();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassView(PrayerTimesState state) {
    // Hitung rotasi jarum kompas (180 - arah untuk membalik arah kompas)
    final double compassRotation = ((_direction ?? 0) * (math.pi / 180) * -1);

    // Hitung perbedaan antara arah kiblat dan kompas
    final double qiblaArrowRotation =
        ((_qiblaDirection ?? 0) * (math.pi / 180));

    // Arah sebenarnya menunjuk ke kiblat
    final double actualQiblaRotation = compassRotation + qiblaArrowRotation;

    // Ikon utara untuk membantu orientasi
    final double northRotation = compassRotation;

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Lokasi: ${state.locationName}',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _direction != null ? '${_direction!.toStringAsFixed(1)}°' : '0°',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _qiblaDirection != null
              ? 'Arah Kiblat: ${_qiblaDirection!.toStringAsFixed(1)}°'
              : 'Arah Kiblat: Menghitung...',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dekorasi latar belakang lingkaran dengan style Chinese
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 80),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 100),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 60),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),

                // Kompas utama
                CompassWidget(
                  rotation: compassRotation,
                  qiblaRotation: actualQiblaRotation,
                  isCalibrating: _isCalibrating,
                  animation: _animation,
                ),

                // Indikator utara
                Transform.rotate(
                  angle: northRotation,
                  child: Align(
                    alignment: const Alignment(0, -0.8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 200),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'N',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                // Logo Ka'bah di tengah
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 80),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.secondary,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _isCalibrating ? null : _calibrateCompass,
          icon: const Icon(Icons.sync),
          label: Text(_isCalibrating ? 'Kalibrasi...' : 'Kalibrasi Kompas'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            disabledBackgroundColor: AppColors.grey,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 100),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Putar perangkat dalam pola angka 8 untuk meningkatkan akurasi kompas',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
