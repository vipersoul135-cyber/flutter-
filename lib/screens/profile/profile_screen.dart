import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final student = firebaseService.currentStudent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get My Bus Name
    String myBusName = 'Not Pinned';
    if (student?.selectedBusId != null) {
      var matchingBus = firebaseService.buses.firstWhere((b) => b.id == student!.selectedBusId, orElse: () => firebaseService.buses.first);
      myBusName = matchingBus.name;
    }

    // Get My Stop Name
    String myStopName = 'Not Pinned';
    if (student?.selectedBusId != null && student?.selectedStopId != null) {
      var route = firebaseService.routes.firstWhere((r) => r.id == firebaseService.buses.firstWhere((b) => b.id == student!.selectedBusId).routeId);
      var stopIdx = route.stops.indexWhere((s) => s.id == student?.selectedStopId);
      if (stopIdx != -1) {
        myStopName = route.stops[stopIdx].name;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Profile Avatar & Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppTheme.colorfulGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Text(
                        '🎓',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      student?.name ?? 'Vignesh Roever',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student?.regNo ?? '22BCA001',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        student?.department ?? 'Computer Applications (BCA)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Preferences Shortcut Indicators
              Row(
                children: [
                  _buildPrefBadge(Icons.directions_bus_rounded, 'MY BUS', myBusName, isDark),
                  const SizedBox(width: 12),
                  _buildPrefBadge(Icons.location_on_rounded, 'MY STOP', myStopName, isDark),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Settings List
              Text(
                '⚙️ APPLICATION SETTINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.softShadow,
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    // Dark Mode Toggle
                    ListTile(
                      leading: const Icon(Icons.dark_mode_rounded, color: Colors.purple),
                      title: const Text('Dark Mode Theme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      trailing: Switch(
                        value: firebaseService.isDarkMode,
                        activeColor: const Color(0xFF6A11CB),
                        onChanged: (val) {
                          firebaseService.toggleDarkMode();
                        },
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.1),

                    // Notification Toggle
                    ListTile(
                      leading: const Icon(Icons.notifications_active_rounded, color: Colors.orange),
                      title: const Text('Push Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      trailing: Switch(
                        value: firebaseService.notificationsEnabled,
                        activeColor: const Color(0xFF6A11CB),
                        onChanged: (val) {
                          firebaseService.toggleNotifications(val);
                        },
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.1),

                    // Language Selector
                    ListTile(
                      leading: const Icon(Icons.language_rounded, color: Colors.blue),
                      title: const Text('App Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      trailing: Text(
                        firebaseService.selectedLanguage,
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onTap: () {
                        // Toggle language between English & Tamil (simulated)
                        String current = firebaseService.selectedLanguage;
                        firebaseService.changeLanguage(current == 'English' ? 'Tamil (தமிழ்)' : 'English');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Logout Section
              ElevatedButton(
                onPressed: () {
                  firebaseService.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.offlineColor.withOpacity(0.1),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.offlineColor, width: 1.0),
                  ),
                ),
                child: const Text(
                  'LOG OUT FROM PROFILE',
                  style: TextStyle(
                    color: AppTheme.offlineColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrefBadge(IconData icon, String label, String value, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF6A11CB), size: 14),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
