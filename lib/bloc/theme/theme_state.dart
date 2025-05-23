import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;

class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  factory ThemeState.initial() {
    return const ThemeState(themeMode: ThemeMode.light);
  }

  ThemeState copyWith({
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  @override
  List<Object> get props => [themeMode];
}
