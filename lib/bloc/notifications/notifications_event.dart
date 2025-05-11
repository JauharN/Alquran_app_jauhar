import 'package:adhan/adhan.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNotifications extends NotificationsEvent {}

class ToggleNotifications extends NotificationsEvent {
  final bool enabled;

  const ToggleNotifications(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class SchedulePrayerNotifications extends NotificationsEvent {
  final Map<String, DateTime> prayerTimes;
  final String locationName;
  final Coordinates coordinates;

  const SchedulePrayerNotifications({
    required this.prayerTimes,
    required this.locationName,
    required this.coordinates,
  });

  @override
  List<Object?> get props => [prayerTimes, locationName, coordinates];
}

class CancelAllNotifications extends NotificationsEvent {}

// Tambahkan event baru
class UpdatePersistentNotification extends NotificationsEvent {
  final Coordinates coordinates;
  final String locationName;

  const UpdatePersistentNotification({
    required this.coordinates,
    required this.locationName,
  });

  @override
  List<Object?> get props => [coordinates, locationName];
}
