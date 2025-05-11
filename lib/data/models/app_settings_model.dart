class AppSettingsModel {
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool alarmEnabled;
  final double alarmVolume;
  final bool vibrationEnabled;

  AppSettingsModel({
    this.darkModeEnabled = false,
    this.notificationsEnabled = true,
    this.alarmEnabled = true,
    this.alarmVolume = 0.5,
    this.vibrationEnabled = true,
  });

  AppSettingsModel copyWith({
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    bool? alarmEnabled,
    double? alarmVolume,
    bool? vibrationEnabled,
  }) {
    return AppSettingsModel(
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      alarmVolume: alarmVolume ?? this.alarmVolume,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'darkModeEnabled': darkModeEnabled,
      'notificationsEnabled': notificationsEnabled,
      'alarmEnabled': alarmEnabled,
      'alarmVolume': alarmVolume,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      darkModeEnabled: json['darkModeEnabled'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      alarmEnabled: json['alarmEnabled'] ?? true,
      alarmVolume: json['alarmVolume'] ?? 0.5,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }
}
