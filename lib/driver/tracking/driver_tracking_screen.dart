import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/bus.dart';

class DriverTrackingScreen extends StatefulWidget {
  final String busId;

  const DriverTrackingScreen({
    Key? key,
    required this.busId,
  }) : super(key: key);

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  bool _permissionGranted = false;
  String _permissionStatus = 'Checking...';
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _permissionStatus = 'Location services are disabled. Please enable GPS.';
        _permissionGranted = false;
      });
      _showPermissionDialog(
        'Location Services Disabled',
        'Please enable location services (GPS) to start tracking.',
        () => Geolocator.openLocationSettings(),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _permissionStatus = 'Location permission denied';
          _permissionGranted = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _permissionStatus = 'Location permission denied forever. Please enable in Settings.';
        _permissionGranted = false;
      });
      _showPermissionDialog(
        'Permission Required',
        'Location permission is permanently denied. Please enable it in app settings.',
        () => Geolocator.openAppSettings(),
      );
      return;
    }

    // Permission granted - get current position
    setState(() {
      _permissionGranted = true;
      _permissionStatus = 'Location permission granted';
    });

    // Get current position
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
    }

    // Start tracking simulation
    if (mounted) {
      Provider.of<FirebaseService>(context, listen: false).startDriverTracking(widget.busId);
    }
  }

  void _showPermissionDialog(String title, String message, VoidCallback onOpenSettings) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on_rounded, color: AppTheme.liveColor),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.liveColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppTheme.liveColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Students will be able to see your bus location in real-time.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onOpenSettings();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: const Text('Open Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.liveColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch the updated live version of this bus
    var matchingBusList = firebaseService.buses.where((b) => b.id == widget.busId);
    Bus bus = matchingBusList.isNotEmpty ? matchingBusList.first : firebaseService.buses.first;

    final latVal = bus.currentLocation?.latitude ?? 10.7963;
    final lngVal = bus.currentLocation?.longitude ?? 78.6856;
    final speedVal = bus.currentLocation?.speed ?? 0.0;
    final timeStr = bus.lastUpdated != null
        ? DateFormat('hh:mm:ss a').format(bus.lastUpdated!)
        : 'Never';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking Broadcast'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            // Stop tracking before going back
            Provider.of<FirebaseService>(context, listen: false).stopDriverTracking(widget.busId);
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Permission Status Banner
              if (!_permissionGranted)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _permissionStatus,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: _checkLocationPermission,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              // Broadcaster Pulsing Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.liveColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.liveColor.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _permissionGranted ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: _permissionGranted ? AppTheme.liveColor : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${bus.name} - ${_permissionGranted ? 'ONLINE' : 'OFFLINE'}',
                          style: TextStyle(
                            color: _permissionGranted ? AppTheme.liveColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _permissionGranted ? '📡 BROADCAST ACTIVE' : '⚠️ WAITING FOR GPS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _permissionGranted ? AppTheme.liveColor : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Live Speed circular dial indicator
              Expanded(
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.softShadow,
                      border: Border.all(
                        color: AppTheme.liveColor.withOpacity(0.2),
                        width: 4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          speedVal.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF2C3E50),
                          ),
                        ),
                        const Text(
                          'KM/H',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Next: ${bus.nextStopName}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A11CB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Live GPS Coordinates logs box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1D2A) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildTelemetryRow('GPS COORDINATES', '${latVal.toStringAsFixed(5)}, ${lngVal.toStringAsFixed(5)}'),
                    const SizedBox(height: 12),
                    _buildTelemetryRow('HEADING ANGLE', '${bus.currentLocation?.heading.toStringAsFixed(1)}°'),
                    const SizedBox(height: 12),
                    _buildTelemetryRow('LAST UPLOAD TIME', timeStr),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Stop Trip button
              ElevatedButton(
                onPressed: () {
                  // Stop the GPS simulation loop
                  firebaseService.stopDriverTracking(widget.busId);
                  Navigator.pop(context); // Return safely to driver dashboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trip broadcast ended. Bus went OFFLINE.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.offlineColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppTheme.offlineColor.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.stop_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'STOP TRIP BROADCAST',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
