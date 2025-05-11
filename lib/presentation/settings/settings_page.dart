// lib/presentation/settings/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/notifications/notifications_bloc.dart';
import '../../bloc/notifications/notifications_event.dart';
import '../../bloc/notifications/notifications_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../core/constants/colors.dart';
import '../../core/themes/text_styles.dart';
import '../../core/components/shadow_box.dart';
import '../../data/models/app_settings_model.dart';
import '../../data/datasources/db_local_datasource.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DbLocalDatasource _dbLocalDatasource = DbLocalDatasource();
  AppSettingsModel _settings = AppSettingsModel();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final settings = await _dbLocalDatasource.getAppSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: AppTextStyles.heading,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildAppearanceSection(),
                const SizedBox(height: 24),
                _buildNotificationSection(),
                const SizedBox(height: 24),
                _buildAlarmSection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildAppearanceSection() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return ShadowBox(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tampilan',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text(
                  'Mode Gelap',
                  style: AppTextStyles.titleMedium,
                ),
                subtitle: const Text(
                  'Mengubah tampilan aplikasi menjadi mode gelap',
                  style: AppTextStyles.bodySmall,
                ),
                value: state.isDarkMode,
                activeColor: AppColors.secondary,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ThemeToggled(value));
                  _saveThemeSetting(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationSection() {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        return ShadowBox(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifikasi',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text(
                  'Notifikasi Waktu Sholat',
                  style: AppTextStyles.titleMedium,
                ),
                subtitle: const Text(
                  'Menampilkan notifikasi persisten jadwal waktu sholat',
                  style: AppTextStyles.bodySmall,
                ),
                value: state.notificationsEnabled,
                activeColor: AppColors.secondary,
                onChanged: (value) {
                  context
                      .read<NotificationsBloc>()
                      .add(ToggleNotifications(value));
                  _saveNotificationSetting(value);
                },
              ),
              const SizedBox(height: 8),
              if (state.status == NotificationStatus.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              if (state.status == NotificationStatus.failure)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    state.errorMessage ??
                        'Terjadi kesalahan saat mengatur notifikasi',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlarmSection() {
    return ShadowBox(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alarm Adzan',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'Aktifkan Alarm Adzan',
              style: AppTextStyles.titleMedium,
            ),
            subtitle: const Text(
              'Membunyikan adzan saat waktu sholat tiba',
              style: AppTextStyles.bodySmall,
            ),
            value: _settings.alarmEnabled,
            activeColor: AppColors.secondary,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(alarmEnabled: value);
              });
              _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Volume Adzan',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Slider(
            value: _settings.alarmVolume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            activeColor: AppColors.secondary,
            inactiveColor: AppColors.grey,
            label: '${(_settings.alarmVolume * 10).round()}',
            onChanged: _settings.alarmEnabled
                ? (value) {
                    setState(() {
                      _settings = _settings.copyWith(alarmVolume: value);
                    });
                  }
                : null,
            onChangeEnd: (value) {
              _saveSettings();
            },
          ),
          SwitchListTile(
            title: const Text(
              'Aktifkan Getar',
              style: AppTextStyles.titleMedium,
            ),
            subtitle: const Text(
              'Mengaktifkan getar saat waktu sholat tiba',
              style: AppTextStyles.bodySmall,
            ),
            value: _settings.vibrationEnabled,
            activeColor: AppColors.secondary,
            onChanged: _settings.alarmEnabled
                ? (value) {
                    setState(() {
                      _settings = _settings.copyWith(vibrationEnabled: value);
                    });
                    _saveSettings();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return ShadowBox(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tentang Aplikasi',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Versi Aplikasi'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline, color: AppColors.secondary),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Kebijakan Privasi'),
            leading: const Icon(Icons.privacy_tip_outlined,
                color: AppColors.secondary),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Syarat dan Ketentuan'),
            leading: const Icon(Icons.description_outlined,
                color: AppColors.secondary),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    await _dbLocalDatasource.saveAppSettings(_settings);
  }

  Future<void> _saveThemeSetting(bool isDarkMode) async {
    setState(() {
      _settings = _settings.copyWith(darkModeEnabled: isDarkMode);
    });
    await _dbLocalDatasource.saveThemeMode(isDarkMode);
    await _saveSettings();
  }

  Future<void> _saveNotificationSetting(bool enabled) async {
    setState(() {
      _settings = _settings.copyWith(notificationsEnabled: enabled);
    });
    await _dbLocalDatasource.savePrayerNotificationSettings(enabled);
    await _saveSettings();
  }
}
