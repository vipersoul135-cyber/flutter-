import 'dart:math';
import '../models/bus_location.dart';
import '../models/stop.dart';

class EtaService {
  /// Calculate ETA in minutes.
  /// If speed is too low, we estimate based on average speed (e.g. 30 km/h).
  /// If parameters are missing, returns null.
  int? calculateEta({
    required BusLocation? location,
    required Stop? targetStop,
  }) {
    if (location == null || targetStop == null) return null;

    double distKm = _distanceBetween(
      location.latitude,
      location.longitude,
      targetStop.latitude,
      targetStop.longitude,
    );

    // If less than 100 meters, ETA is 0 (arrived)
    if (distKm < 0.1) return 0;

    // Use current speed if > 5 km/h, otherwise assume average speed of 30 km/h
    double speedKmh = location.speed > 5 ? location.speed : 30.0;

    double timeHours = distKm / speedKmh;
    double timeMinutes = timeHours * 60;

    // Add extra buffer for traffic/stoppings (e.g. 1.2x factor + 1 minute)
    return max(1, (timeMinutes * 1.2).round() + 1);
  }

  String formatEta(int? minutes) {
    if (minutes == null) return 'ETA unavailable';
    if (minutes == 0) return 'Arrived';
    if (minutes == 1) return '1 min';
    return '$minutes mins';
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
