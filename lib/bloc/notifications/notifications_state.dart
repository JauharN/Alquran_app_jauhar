import 'package:equatable/equatable.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  final bool notificationsEnabled;
  final NotificationStatus status;
  final String? errorMessage;

  const NotificationsState({
    this.notificationsEnabled = true,
    this.status = NotificationStatus.initial,
    this.errorMessage,
  });

  factory NotificationsState.initial() {
    return const NotificationsState();
  }

  NotificationsState copyWith({
    bool? notificationsEnabled,
    NotificationStatus? status,
    String? errorMessage,
  }) {
    return NotificationsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [notificationsEnabled, status, errorMessage];
}
