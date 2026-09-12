import 'package:cloud_firestore/cloud_firestore.dart';

class BusLocation {
  final String busId;
  final double latitude;
  final double longitude;
  final double speed;
  final DateTime timestamp;
  final double heading;

  BusLocation({
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.timestamp,
    this.heading = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'timestamp': Timestamp.fromDate(timestamp),
      'heading': heading,
    };
  }

  factory BusLocation.fromMap(Map<String, dynamic> map) {
    DateTime ts;
    if (map['timestamp'] is Timestamp) {
      ts = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      ts = DateTime.parse(map['timestamp']);
    } else {
      ts = DateTime.now();
    }

    return BusLocation(
      busId: map['busId'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
      timestamp: ts,
      heading: (map['heading'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
