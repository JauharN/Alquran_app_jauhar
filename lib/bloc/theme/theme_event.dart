import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeToggled extends ThemeEvent {
  final bool isDarkMode;

  const ThemeToggled(this.isDarkMode);

  @override
  List<Object> get props => [isDarkMode];
}

class ThemeInitialized extends ThemeEvent {}
