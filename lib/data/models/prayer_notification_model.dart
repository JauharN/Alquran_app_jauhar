class PrayerNotificationModel {
  final int id;
  final String prayerName;
  final DateTime prayerTime;
  final String locationName;
  final bool enabled;

  PrayerNotificationModel({
    required this.id,
    required this.prayerName,
    required this.prayerTime,
    required this.locationName,
    this.enabled = true,
  });

  PrayerNotificationModel copyWith({
    int? id,
    String? prayerName,
    DateTime? prayerTime,
    String? locationName,
    bool? enabled,
  }) {
    return PrayerNotificationModel(
      id: id ?? this.id,
      prayerName: prayerName ?? this.prayerName,
      prayerTime: prayerTime ?? this.prayerTime,
      locationName: locationName ?? this.locationName,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prayerName': prayerName,
      'prayerTime': prayerTime.toIso8601String(),
      'locationName': locationName,
      'enabled': enabled,
    };
  }

  factory PrayerNotificationModel.fromJson(Map<String, dynamic> json) {
    return PrayerNotificationModel(
      id: json['id'],
      prayerName: json['prayerName'],
      prayerTime: DateTime.parse(json['prayerTime']),
      locationName: json['locationName'],
      enabled: json['enabled'] ?? true,
    );
  }
}
