import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppConstants {
  // App Branding
  static const String appName = 'CAMPUS BUS LIVE';
  static const String subtitle = 'Smart College Bus Tracking';
  static const String collegeName = 'THANTHAI HANS ROEVER COLLEGE';
  static const String collegeShort = 'THRC';

  // Firestore Collection Names
  static const String colBuses = 'buses';
  static const String colRoutes = 'routes';
  static const String colStops = 'stops';
  static const String colStudents = 'students';
  static const String colAnnouncements = 'announcements';

  // Map Default Center (Thanthai Hans Roever College, Perambalur)
  static const LatLng collegeLocation = LatLng(11.2335, 78.8778);
  static const double defaultZoom = 11.0;

  // Preset Route coordinates for Trichy -> College Route
  // Useful for calculations and visual map overlays
  static const Map<String, LatLng> presetStopCoordinates = {
    'Trichy Central': LatLng(10.7963, 78.6856),
    'Srirangam': LatLng(10.8622, 78.6908),
    'Samayapuram': LatLng(10.9416, 78.7289),
    'Mannachanallur': LatLng(10.9067, 78.7011),
    'College': LatLng(11.2335, 78.8778),
  };
}
