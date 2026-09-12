import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/stop.dart';

class MapService {
  /// Generate camera update to fit bus, college and stop positions.
  LatLngBounds getBoundsForRoute(LatLng busLoc, LatLng collegeLoc, List<Stop> stops) {
    List<LatLng> points = [busLoc, collegeLoc];
    for (var stop in stops) {
      points.add(LatLng(stop.latitude, stop.longitude));
    }

    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Create Polyline for routing
  Polyline createPolyline(String id, List<LatLng> points, Color color) {
    return Polyline(
      polylineId: PolylineId(id),
      points: points,
      color: color,
      width: 5,
      jointType: JointType.round,
      endCap: Cap.roundCap,
      startCap: Cap.roundCap,
    );
  }
}
