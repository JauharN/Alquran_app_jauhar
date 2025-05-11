// lib/data/datasources/db_local_datasource.dart

import 'package:flutter_alquran_jauhar_app/data/models/app_settings_model.dart';
import 'package:flutter_alquran_jauhar_app/data/models/bookmark_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DbLocalDatasource {
  // BOOKMARK METHODS
  Future<void> saveBookmark(BookmarkModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('surat', model.suratName);
    await prefs.setInt('suratNumber', model.suratNumber);
    await prefs.setInt('ayatNumber', model.ayatNumber);
  }

  Future<BookmarkModel?> getBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final surat = prefs.getString('surat');
    final suratNumber = prefs.getInt('suratNumber');
    final ayatNumber = prefs.getInt('ayatNumber');
    if (surat != null && suratNumber != null && ayatNumber != null) {
      return BookmarkModel(surat, suratNumber, ayatNumber);
    }
    return null;
  }

  // LOCATION METHODS
  Future<void> saveLatLng(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lat', lat);
    await prefs.setDouble('lng', lng);
  }

  Future<List<double>> getLatLng() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat');
    final lng = prefs.getDouble('lng');
    if (lat != null && lng != null) {
      return [lat, lng];
    }
    return [];
  }

  // SETTINGS METHODS
  Future<void> saveAppSettings(AppSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', jsonEncode(settings.toJson()));
  }

  Future<AppSettingsModel> getAppSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        return AppSettingsModel.fromJson(json);
      } catch (e) {
        // Return default settings if error
        return AppSettingsModel();
      }
    }
    return AppSettingsModel(); // Return default settings
  }

  // NOTIFICATION SETTINGS
  Future<void> savePrayerNotificationSettings(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayerNotificationEnabled', enabled);
  }

  Future<bool> getPrayerNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('prayerNotificationEnabled') ?? true;
  }

  // THEME SETTINGS
  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }
}
