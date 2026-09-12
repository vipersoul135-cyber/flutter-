import 'package:cloud_firestore/cloud_firestore.dart';
import 'bus_location.dart';

class Bus {
  final String id;
  final String name;
  final String number;
  final String routeId;
  final String routeName;
  final String status; // 'live' (or 'online'), 'at_stop', 'delayed', 'offline', 'not_started'
  final BusLocation? currentLocation;
  final String? nextStopName;
  final int? etaMinutes;
  final DateTime? lastUpdated;

  Bus({
    required this.id,
    required this.name,
    required this.number,
    required this.routeId,
    required this.routeName,
    required this.status,
    this.currentLocation,
    this.nextStopName,
    this.etaMinutes,
    this.lastUpdated,
  });

  bool get isOnline => status == 'live' || status == 'at_stop' || status == 'delayed';

  Bus copyWith({
    String? id,
    String? name,
    String? number,
    String? routeId,
    String? routeName,
    String? status,
    BusLocation? currentLocation,
    String? nextStopName,
    int? etaMinutes,
    DateTime? lastUpdated,
  }) {
    return Bus(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      nextStopName: nextStopName ?? this.nextStopName,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'routeId': routeId,
      'routeName': routeName,
      'status': status,
      'currentLocation': currentLocation?.toMap(),
      'nextStopName': nextStopName,
      'etaMinutes': etaMinutes,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  factory Bus.fromMap(Map<String, dynamic> map) {
    DateTime? lastUp;
    if (map['lastUpdated'] is Timestamp) {
      lastUp = (map['lastUpdated'] as Timestamp).toDate();
    } else if (map['lastUpdated'] is String) {
      lastUp = DateTime.parse(map['lastUpdated']);
    }

    return Bus(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      number: map['number'] ?? '',
      routeId: map['routeId'] ?? '',
      routeName: map['routeName'] ?? '',
      status: map['status'] ?? 'not_started',
      currentLocation: map['currentLocation'] != null
          ? BusLocation.fromMap(Map<String, dynamic>.from(map['currentLocation']))
          : null,
      nextStopName: map['nextStopName'],
      etaMinutes: map['etaMinutes'],
      lastUpdated: lastUp,
    );
  }
}
