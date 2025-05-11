import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

abstract class PrayerTimesEvent extends Equatable {
  const PrayerTimesEvent();

  @override
  List<Object?> get props => [];
}

class InitializePrayerTimes extends PrayerTimesEvent {
  final BuildContext? context;

  const InitializePrayerTimes({this.context});

  @override
  List<Object?> get props => [context];
}

class LoadPrayerTimes extends PrayerTimesEvent {
  final DateTime date;
  final Coordinates coordinates;
  final BuildContext? context;

  const LoadPrayerTimes({
    required this.date,
    required this.coordinates,
    this.context,
  });

  @override
  List<Object?> get props => [date, coordinates, context];
}

class UpdateCoordinates extends PrayerTimesEvent {
  final Coordinates coordinates;
  final String locationName;

  const UpdateCoordinates({
    required this.coordinates,
    required this.locationName,
  });

  @override
  List<Object?> get props => [coordinates, locationName];
}

class SelectDate extends PrayerTimesEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SetPrayerAlarms extends PrayerTimesEvent {}
