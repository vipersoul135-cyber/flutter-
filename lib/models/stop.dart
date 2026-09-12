class Stop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String scheduledTime;
  final int order;

  Stop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.scheduledTime,
    required this.order,
  });

  Stop copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? scheduledTime,
    int? order,
  }) {
    return Stop(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledTime': scheduledTime,
      'order': order,
    };
  }

  factory Stop.fromMap(Map<String, dynamic> map) {
    return Stop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      scheduledTime: map['scheduledTime'] ?? '',
      order: map['order'] ?? 0,
    );
  }
}
