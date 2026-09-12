import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../tracking/driver_tracking_screen.dart';
import '../../screens/auth/login_screen.dart';

class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Identify current driver's bus details
    final busId = firebaseService.currentDriverBusId ?? 'b12';
    var matchingBusList = firebaseService.buses.where((b) => b.id == busId);
    var bus = matchingBusList.isNotEmpty ? matchingBusList.first : firebaseService.buses.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dispatch'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.offlineColor),
            onPressed: () {
              firebaseService.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen(initialRoleIndex: 1)),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Vehicle Badge Card
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppTheme.colorfulGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      bus.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bus.routeName,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bus.number,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Dispatch warning details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1D2A) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildStatusRow(Icons.gps_fixed_rounded, 'GPS Receiver Status', 'CONNECTED', Colors.green),
                    const SizedBox(height: 12),
                    _buildStatusRow(Icons.wifi_tethering_rounded, 'Broadcast Link', 'AVAILABLE', Colors.green),
                    const SizedBox(height: 12),
                    _buildStatusRow(Icons.security_rounded, 'Broadcaster Node ID', bus.id.toUpperCase(), Colors.grey),
                  ],
                ),
              ),
              const Spacer(),

              // Start Trip CTA
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverTrackingScreen(busId: bus.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.liveColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: AppTheme.liveColor.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'START TRIP BROADCAST',
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6A11CB)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
