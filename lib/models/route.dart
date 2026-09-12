import 'stop.dart';

class BusRoute {
  final String id;
  final String name;
  final String startPoint;
  final String endPoint;
  final List<Stop> stops;

  BusRoute({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.stops,
  });

  BusRoute copyWith({
    String? id,
    String? name,
    String? startPoint,
    String? endPoint,
    List<Stop>? stops,
  }) {
    return BusRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      stops: stops ?? this.stops,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startPoint': startPoint,
      'endPoint': endPoint,
      'stops': stops.map((s) => s.toMap()).toList(),
    };
  }

  factory BusRoute.fromMap(Map<String, dynamic> map) {
    var rawStops = map['stops'] as List? ?? [];
    List<Stop> stopsList = rawStops.map((s) => Stop.fromMap(Map<String, dynamic>.from(s))).toList();
    // Sort stops by order
    stopsList.sort((a, b) => a.order.compareTo(b.order));

    return BusRoute(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      startPoint: map['startPoint'] ?? '',
      endPoint: map['endPoint'] ?? '',
      stops: stopsList,
    );
  }
}
