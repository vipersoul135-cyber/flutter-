import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  Future<bool> requestPermission() async {
    // Stub for location permission request
    // Automatically succeeds in sandbox/demo mode
    return true;
  }

  Future<bool> isLocationEnabled() async {
    return true;
  }

  Future<LatLng> getCurrentLocation() async {
    // Return Thanthai Hans Roever College coordinates by default
    return const LatLng(11.2335, 78.8778);
  }
}
