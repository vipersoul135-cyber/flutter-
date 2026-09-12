import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Firebase imports (conditionally safe)
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bus.dart';
import '../models/bus_location.dart';
import '../models/route.dart';
import '../models/stop.dart';
import '../models/student.dart';
import '../models/timetable.dart';
import '../core/constants/app_constants.dart';

class FirebaseService extends ChangeNotifier {
  bool _isFirebaseInitialized = false;
  bool _useDemoMode = true;
  SharedPreferences? _prefs;

  // App State variables
  Student? _currentStudent;
  String? _currentDriverBusId;
  bool _isAdmin = false;

  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  List<Bus> _buses = [];
  List<BusRoute> _routes = [];
  List<String> _announcements = [];
  List<Timetable> _timetables = [];

  // Active tracking state
  Timer? _simulationTimer;
  int _simulationPathIndex = 0;
  bool _isDriverTrackingActive = false;

  // Getters
  bool get isFirebaseInitialized => _isFirebaseInitialized;
  bool get useDemoMode => _useDemoMode;
  Student? get currentStudent => _currentStudent;
  String? get currentDriverBusId => _currentDriverBusId;
  bool get isAdmin => _isAdmin;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get selectedLanguage => _selectedLanguage;
  List<Bus> get buses => _buses;
  List<BusRoute> get routes => _routes;
  List<String> get announcements => _announcements;
  List<Timetable> get timetables => _timetables;
  bool get isDriverTrackingActive => _isDriverTrackingActive;

  // Dense GPS polyline coordinates for Trichy -> Srirangam -> Samayapuram -> Mannachanallur -> College
  // Generated for a smooth simulated live tracking experience.
  static final List<LatLngMock> _simulatedPath = _generateSimulatedPath();

  FirebaseService() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool('dark_mode') ?? false;
    _notificationsEnabled = _prefs?.getBool('notifications') ?? true;
    _selectedLanguage = _prefs?.getString('language') ?? 'English';

    try {
      // Try initializing Firebase
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;
      _useDemoMode = false;
      print("Firebase successfully initialized. Connecting to remote cloud database.");
    } catch (e) {
      _isFirebaseInitialized = false;
      _useDemoMode = true;
      print("Firebase config not found or failed. Running in visual DEMO MODE.");
    }

    _loadInitialData();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _prefs?.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  void toggleNotifications(bool val) {
    _notificationsEnabled = val;
    _prefs?.setBool('notifications', val);
    notifyListeners();
  }

  void changeLanguage(String lang) {
    _selectedLanguage = lang;
    _prefs?.setString('language', lang);
    notifyListeners();
  }

  void _loadInitialData() {
    // Standard mock announcements
    _announcements = [
      "📢 College Day celebration transport routes updated for tomorrow evening.",
      "⚠️ BUS 15 delayed by 15 mins near Samayapuram toll due to road work.",
      "✅ Semester exam special buses will run at 04:30 PM on all routes.",
    ];

    // Initialize mock stops for Route 1 (Trichy Route)
    List<Stop> stops1 = [
      Stop(id: 's1', name: 'Trichy Central', latitude: 10.7963, longitude: 78.6856, scheduledTime: '07:00 AM', order: 0),
      Stop(id: 's2', name: 'Srirangam', latitude: 10.8622, longitude: 78.6908, scheduledTime: '07:15 AM', order: 1),
      Stop(id: 's3', name: 'Samayapuram', latitude: 10.9416, longitude: 78.7289, scheduledTime: '07:30 AM', order: 2),
      Stop(id: 's4', name: 'Mannachanallur', latitude: 10.9067, longitude: 78.7011, scheduledTime: '07:45 AM', order: 3),
      Stop(id: 's5', name: 'College', latitude: 11.2335, longitude: 78.8778, scheduledTime: '08:15 AM', order: 4),
    ];

    // Initialize mock stops for Route 2 (Thuraiyur Route)
    List<Stop> stops2 = [
      Stop(id: 's2_1', name: 'Thuraiyur Stand', latitude: 11.1417, longitude: 78.5972, scheduledTime: '07:10 AM', order: 0),
      Stop(id: 's2_2', name: 'Uppiliapuram', latitude: 11.2425, longitude: 78.5085, scheduledTime: '07:30 AM', order: 1),
      Stop(id: 's2_3', name: 'College', latitude: 11.2335, longitude: 78.8778, scheduledTime: '08:15 AM', order: 2),
    ];

    _routes = [
      BusRoute(id: 'r1', name: 'Trichy → College', startPoint: 'Trichy Central', endPoint: 'College', stops: stops1),
      BusRoute(id: 'r2', name: 'Thuraiyur → College', startPoint: 'Thuraiyur Stand', endPoint: 'College', stops: stops2),
    ];

    _buses = [
      Bus(
        id: 'b12',
        name: 'BUS 12',
        number: 'TN 48 AM 1212',
        routeId: 'r1',
        routeName: 'Trichy → College',
        status: 'not_started',
        currentLocation: BusLocation(
          busId: 'b12',
          latitude: 10.7963,
          longitude: 78.6856,
          speed: 0.0,
          timestamp: DateTime.now(),
        ),
        nextStopName: 'Trichy Central',
        etaMinutes: 0,
        lastUpdated: DateTime.now(),
      ),
      Bus(
        id: 'b15',
        name: 'BUS 15',
        number: 'TN 48 AM 1215',
        routeId: 'r1',
        routeName: 'Trichy → College',
        status: 'delayed',
        currentLocation: BusLocation(
          busId: 'b15',
          latitude: 10.9416,
          longitude: 78.7289,
          speed: 15.0,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        nextStopName: 'Mannachanallur',
        etaMinutes: 15,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      Bus(
        id: 'b18',
        name: 'BUS 18',
        number: 'TN 48 AM 1218',
        routeId: 'r1',
        routeName: 'Trichy → College',
        status: 'offline',
        currentLocation: BusLocation(
          busId: 'b18',
          latitude: 10.8622,
          longitude: 78.6908,
          speed: 0.0,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        ),
        nextStopName: 'Samayapuram',
        etaMinutes: null,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      Bus(
        id: 'b20',
        name: 'BUS 20',
        number: 'TN 48 AM 1220',
        routeId: 'r2',
        routeName: 'Thuraiyur → College',
        status: 'not_started',
        currentLocation: BusLocation(
          busId: 'b20',
          latitude: 11.1417,
          longitude: 78.5972,
          speed: 0.0,
          timestamp: DateTime.now(),
        ),
        nextStopName: 'Thuraiyur Stand',
        etaMinutes: 0,
        lastUpdated: DateTime.now(),
      ),
    ];

    // Build Timetables
    _timetables = [
      Timetable(
        busId: 'b12',
        routeId: 'r1',
        schedules: stops1.map((s) => TimetableItem(stopName: s.name, time: s.scheduledTime)).toList(),
      ),
      Timetable(
        busId: 'b15',
        routeId: 'r1',
        schedules: stops1.map((s) => TimetableItem(stopName: s.name, time: s.scheduledTime)).toList(),
      ),
      Timetable(
        busId: 'b20',
        routeId: 'r2',
        schedules: stops2.map((s) => TimetableItem(stopName: s.name, time: s.scheduledTime)).toList(),
      ),
    ];

    // Reload student local selection if any
    String? storedBusId = _prefs?.getString('student_bus_id');
    String? storedStopId = _prefs?.getString('student_stop_id');

    if (_currentStudent != null) {
      _currentStudent = _currentStudent!.copyWith(
        selectedBusId: storedBusId,
        selectedStopId: storedStopId,
      );
    }
  }

  // --- AUTHENTICATION ---
  Future<bool> signInStudent(String regNo, String password) async {
    // Simulated credentials validation
    if (regNo.isNotEmpty && password.length >= 4) {
      String? storedBusId = _prefs?.getString('student_bus_id');
      String? storedStopId = _prefs?.getString('student_stop_id');

      _currentStudent = Student(
        regNo: regNo.toUpperCase(),
        name: 'Vignesh Roever',
        email: '${regNo.toLowerCase()}@roever.edu.in',
        department: 'Computer Applications (BCA)',
        year: 'III Year',
        college: AppConstants.collegeName,
        selectedBusId: storedBusId,
        selectedStopId: storedStopId,
        role: 'student',
      );
      _currentDriverBusId = null;
      _isAdmin = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signInDriver(String busId, String password) async {
    // Validate driver bus registration ID
    var exists = _buses.any((b) => b.id.toLowerCase() == busId.toLowerCase() || b.name.toLowerCase() == busId.toLowerCase());
    if (exists && password.length >= 4) {
      // Find matching bus
      Bus matchingBus = _buses.firstWhere(
        (b) => b.id.toLowerCase() == busId.toLowerCase() || b.name.toLowerCase() == busId.toLowerCase(),
      );
      _currentDriverBusId = matchingBus.id;
      _currentStudent = null;
      _isAdmin = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signInAdmin(String adminId, String password) async {
    if (adminId.toLowerCase() == 'admin' && password == 'admin123') {
      _isAdmin = true;
      _currentStudent = null;
      _currentDriverBusId = null;
      notifyListeners();
      return true;
    }
    return false;
  }

  void signOut() {
    _currentStudent = null;
    _currentDriverBusId = null;
    _isAdmin = false;
    _isDriverTrackingActive = false;
    _simulationTimer?.cancel();
    notifyListeners();
  }

  // --- STUDENT PREFERENCES ---
  Future<void> setSelectedBus(String? busId) async {
    if (busId != null) {
      await _prefs?.setString('student_bus_id', busId);
    } else {
      await _prefs?.remove('student_bus_id');
    }
    if (_currentStudent != null) {
      _currentStudent = _currentStudent!.copyWith(selectedBusId: busId);
      notifyListeners();
    }
  }

  Future<void> setSelectedStop(String? stopId) async {
    if (stopId != null) {
      await _prefs?.setString('student_stop_id', stopId);
    } else {
      await _prefs?.remove('student_stop_id');
    }
    if (_currentStudent != null) {
      _currentStudent = _currentStudent!.copyWith(selectedStopId: stopId);
      notifyListeners();
    }
  }

  // --- TRIP TRACKING (DRIVER) ---
  void startDriverTracking(String busId) {
    if (_isDriverTrackingActive) return;

    _isDriverTrackingActive = true;
    _simulationPathIndex = 0;

    // Start simulation timer
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_simulationPathIndex >= _simulatedPath.length) {
        _simulationPathIndex = 0; // Loop tracking
      }

      LatLngMock currentLatLng = _simulatedPath[_simulationPathIndex];
      double currentSpeed = 35.0 + Random().nextInt(25); // 35 - 60 km/h
      double headingAngle = _calculateHeading(_simulationPathIndex);

      _updateBusLiveLocation(
        busId: busId,
        lat: currentLatLng.lat,
        lng: currentLatLng.lng,
        speed: currentSpeed,
        heading: headingAngle,
      );

      _simulationPathIndex++;
    });

    notifyListeners();
  }

  void stopDriverTracking(String busId) {
    _simulationTimer?.cancel();
    _isDriverTrackingActive = false;

    // Update status to offline or not_started
    int index = _buses.indexWhere((b) => b.id == busId);
    if (index != -1) {
      _buses[index] = _buses[index].copyWith(
        status: 'not_started',
        currentLocation: BusLocation(
          busId: busId,
          latitude: _buses[index].currentLocation?.latitude ?? 10.7963,
          longitude: _buses[index].currentLocation?.longitude ?? 78.6856,
          speed: 0.0,
          timestamp: DateTime.now(),
        ),
        nextStopName: 'Not Started',
        etaMinutes: null,
        lastUpdated: DateTime.now(),
      );
    }

    notifyListeners();
  }

  double _calculateHeading(int index) {
    if (index >= _simulatedPath.length - 1) return 0.0;
    LatLngMock p1 = _simulatedPath[index];
    LatLngMock p2 = _simulatedPath[index + 1];
    double dLon = (p2.lng - p1.lng);
    double y = sin(dLon) * cos(p2.lat);
    double x = cos(p1.lat) * sin(p2.lat) - sin(p1.lat) * cos(p2.lat) * cos(dLon);
    double angle = atan2(y, x) * 180 / pi;
    return (angle + 360) % 360;
  }

  void _updateBusLiveLocation({
    required String busId,
    required double lat,
    required double lng,
    required double speed,
    required double heading,
  }) {
    int index = _buses.indexWhere((b) => b.id == busId);
    if (index == -1) return;

    Bus bus = _buses[index];
    BusRoute route = _routes.firstWhere((r) => r.id == bus.routeId);

    // Determine the next stop and calculate ETA dynamically
    String nextStop = 'College';
    int etaVal = 5;
    Stop? activeStop;

    for (int i = 0; i < route.stops.length; i++) {
      Stop s = route.stops[i];
      double dist = _distanceBetween(lat, lng, s.latitude, s.longitude);
      // If we are very close to a stop (within 200m), we are 'at_stop'
      if (dist < 0.25) {
        activeStop = s;
        break;
      }
    }

    String statusStr = 'live';
    if (activeStop != null) {
      statusStr = 'at_stop';
      nextStop = activeStop.name;
      etaVal = 0;
    } else {
      // Find the first stop in order that the bus has not passed yet.
      // We assume heading northwards along coordinates.
      // We can find the closest stop ahead.
      double minDist = double.infinity;
      int closestIdx = 0;
      for (int i = 0; i < route.stops.length; i++) {
        double dist = _distanceBetween(lat, lng, route.stops[i].latitude, route.stops[i].longitude);
        if (dist < minDist) {
          minDist = dist;
          closestIdx = i;
        }
      }

      // Check if we passed it or not (by checking indices)
      // Since it's a simple simulated line, stops are:
      // Index 0: Trichy, 1: Srirangam, 2: Samayapuram, 3: Mannachanallur, 4: College
      // Based on our simulation index (0-50), map stops to simulation indices:
      // Trichy: path index 0
      // Srirangam: path index 10
      // Samayapuram: path index 22
      // Mannachanallur: path index 35
      // College: path index 50
      int stopIdx = 0;
      if (_simulationPathIndex < 10) {
        stopIdx = 1; // Heading to Srirangam
      } else if (_simulationPathIndex < 22) {
        stopIdx = 2; // Heading to Samayapuram
      } else if (_simulationPathIndex < 35) {
        stopIdx = 3; // Heading to Mannachanallur
      } else {
        stopIdx = 4; // Heading to College
      }

      if (stopIdx < route.stops.length) {
        nextStop = route.stops[stopIdx].name;
        // ETA calculation: ~2 minutes per kilometer at 45km/h
        double distToStop = _distanceBetween(lat, lng, route.stops[stopIdx].latitude, route.stops[stopIdx].longitude);
        etaVal = max(1, (distToStop * 1.8).round());
      }
    }

    _buses[index] = bus.copyWith(
      status: statusStr,
      currentLocation: BusLocation(
        busId: busId,
        latitude: lat,
        longitude: lng,
        speed: speed,
        timestamp: DateTime.now(),
        heading: heading,
      ),
      nextStopName: nextStop,
      etaMinutes: etaVal,
      lastUpdated: DateTime.now(),
    );

    notifyListeners();
  }

  // --- STOPPING MANAGEMENT (ADMIN) ---
  void addStop(String routeId, String name, double lat, double lng, String scheduledTime) {
    int rIdx = _routes.indexWhere((r) => r.id == routeId);
    if (rIdx == -1) return;

    List<Stop> updatedStops = List.from(_routes[rIdx].stops);
    String newId = const Uuid().v4();
    int newOrder = updatedStops.isEmpty ? 0 : updatedStops.map((s) => s.order).reduce(max) + 1;

    updatedStops.add(Stop(
      id: newId,
      name: name,
      latitude: lat,
      longitude: lng,
      scheduledTime: scheduledTime,
      order: newOrder,
    ));

    // Sort and update
    updatedStops.sort((a, b) => a.order.compareTo(b.order));
    _routes[rIdx] = _routes[rIdx].copyWith(stops: updatedStops);

    _updateTimetablesFromRoutes();
    notifyListeners();
  }

  void editStop(String routeId, String stopId, String name, double lat, double lng, String scheduledTime) {
    int rIdx = _routes.indexWhere((r) => r.id == routeId);
    if (rIdx == -1) return;

    List<Stop> updatedStops = _routes[rIdx].stops.map((s) {
      if (s.id == stopId) {
        return s.copyWith(
          name: name,
          latitude: lat,
          longitude: lng,
          scheduledTime: scheduledTime,
        );
      }
      return s;
    }).toList();

    _routes[rIdx] = _routes[rIdx].copyWith(stops: updatedStops);
    _updateTimetablesFromRoutes();
    notifyListeners();
  }

  void deleteStop(String routeId, String stopId) {
    int rIdx = _routes.indexWhere((r) => r.id == routeId);
    if (rIdx == -1) return;

    List<Stop> updatedStops = _routes[rIdx].stops.where((s) => s.id != stopId).toList();
    
    // Normalize ordering indices
    for (int i = 0; i < updatedStops.length; i++) {
      updatedStops[i] = updatedStops[i].copyWith(order: i);
    }

    _routes[rIdx] = _routes[rIdx].copyWith(stops: updatedStops);
    _updateTimetablesFromRoutes();
    notifyListeners();
  }

  void reorderStops(String routeId, List<Stop> reorderedList) {
    int rIdx = _routes.indexWhere((r) => r.id == routeId);
    if (rIdx == -1) return;

    // Apply the new order value matching list indices
    List<Stop> updated = [];
    for (int i = 0; i < reorderedList.length; i++) {
      updated.add(reorderedList[i].copyWith(order: i));
    }

    _routes[rIdx] = _routes[rIdx].copyWith(stops: updated);
    _updateTimetablesFromRoutes();
    notifyListeners();
  }

  void _updateTimetablesFromRoutes() {
    // Regenerate timetables to reflect stop changes
    _timetables = _routes.map((route) {
      // Find bus associated with route (just pick the first one matching)
      String bId = _buses.firstWhere((b) => b.routeId == route.id, orElse: () => _buses.first).id;
      return Timetable(
        busId: bId,
        routeId: route.id,
        schedules: route.stops.map((s) => TimetableItem(stopName: s.name, time: s.scheduledTime)).toList(),
      );
    }).toList();
  }

  // --- MATH HELPERS ---
  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Generate dense polyline stops between Trichy Central and College
  static List<LatLngMock> _generateSimulatedPath() {
    List<LatLngMock> stops = [
      LatLngMock(10.7963, 78.6856), // Trichy Central
      LatLngMock(10.8622, 78.6908), // Srirangam
      LatLngMock(10.9416, 78.7289), // Samayapuram
      LatLngMock(10.9067, 78.7011), // Mannachanallur
      LatLngMock(11.2335, 78.8778), // College
    ];

    List<LatLngMock> path = [];
    for (int i = 0; i < stops.length - 1; i++) {
      LatLngMock start = stops[i];
      LatLngMock end = stops[i + 1];
      int segments = 12; // Insert 12 sub-points between each major stop
      for (int j = 0; j < segments; j++) {
        double t = j / segments;
        double lat = start.lat + (end.lat - start.lat) * t;
        double lng = start.lng + (end.lng - start.lng) * t;
        path.add(LatLngMock(lat, lng));
      }
    }
    path.add(stops.last);
    return path;
  }
}

class LatLngMock {
  final double lat;
  final double lng;
  LatLngMock(this.lat, this.lng);
}
