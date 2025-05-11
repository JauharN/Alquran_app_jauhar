import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeToggled>(_onThemeToggled);
  }

  FutureOr<void> _onThemeInitialized(
      ThemeInitialized event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;

    emit(state.copyWith(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    ));
  }

  FutureOr<void> _onThemeToggled(
      ThemeToggled event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', event.isDarkMode);

    emit(state.copyWith(
      themeMode: event.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    ));
  }
}
