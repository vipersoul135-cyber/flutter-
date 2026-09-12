import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/bus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../search/search_screen.dart';
import '../live/live_screen.dart';
import '../my_bus/my_bus_screen.dart';
import '../timetable/timetable_screen.dart';
import '../profile/profile_screen.dart';
import '../bus_details/bus_details_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Pages corresponding to Bottom navigation items
  final List<Widget> _pages = [
    const HomeDashboardView(),
    const LiveScreen(),
    const MyBusScreen(),
    const TimetableScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 15,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark ? const Color(0xFF1B1D2A) : Colors.white,
            selectedItemColor: const Color(0xFF6A11CB),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sensors_rounded),
                activeIcon: Icon(Icons.sensors_rounded),
                label: 'Live',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_rounded),
                activeIcon: Icon(Icons.star_rounded),
                label: 'My Bus',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded),
                activeIcon: Icon(Icons.map_rounded),
                label: 'Routes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({Key? key}) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = firebaseService.currentStudent;

    // Check if the student has selected a bus and retrieve its details
    Bus? myBus;
    if (student?.selectedBusId != null) {
      int idx = firebaseService.buses.indexWhere((b) => b.id == student!.selectedBusId);
      if (idx != -1) {
        myBus = firebaseService.buses[idx];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            final firebaseService = Provider.of<FirebaseService>(context, listen: false);
            firebaseService.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        student?.name ?? 'Student',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppConstants.collegeName,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF6A11CB),
                        ),
                      ),
                    ],
                  ),
                  // Bell Icon with announcement notification indicator
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () => _showAnnouncementsDialog(context, firebaseService),
                        ),
                      ),
                      if (firebaseService.announcements.isNotEmpty)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.offlineColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar Trigger Card
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    boxShadow: AppTheme.softShadow,
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFF6A11CB), size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'Where is your bus?',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Search stop...',
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // My Bus Section
              Text(
                '⭐ MY BUS DASHBOARD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              if (myBus != null)
                _buildMyBusDetailCard(context, myBus, isDark)
              else
                _buildEmptyMyBusCard(context, isDark),

              const SizedBox(height: 24),

              // Quick Notices Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📢 ANNOUNCEMENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAnnouncementsDialog(context, firebaseService),
                    child: const Text('View All', style: TextStyle(fontSize: 11, color: Color(0xFF2575FC))),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...firebaseService.announcements.take(2).map((note) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B1D2A).withOpacity(0.5) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      note,
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyBusDetailCard(BuildContext context, Bus bus, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppTheme.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_bus_rounded, color: Color(0xFF00E5FF), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            bus.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Animated breathing indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (bus.isOnline ? AppTheme.liveColor : AppTheme.offlineColor).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (bus.isOnline ? AppTheme.liveColor : AppTheme.offlineColor).withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          bus.status.toUpperCase(),
                          style: TextStyle(
                            color: bus.isOnline ? AppTheme.liveColor : AppTheme.offlineColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CURRENT STATION',
                              style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bus.isOnline
                                  ? (bus.status == 'at_stop' ? 'Stopped at ${bus.nextStopName}' : bus.nextStopName ?? 'En Route')
                                  : 'Offline / Yard',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      if (bus.isOnline && bus.etaMinutes != null) ...[
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'ETA',
                              style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${bus.etaMinutes.toString().padLeft(2, '0')} MIN',
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusDetailsScreen(bus: bus),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'TRACK BUS',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMyBusCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '⭐',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            "You haven't selected a bus yet.",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'Link a primary college bus to track it on your home dashboard instantly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_rounded, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'SELECT MY BUS',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAnnouncementsDialog(BuildContext context, FirebaseService service) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.notifications_active_rounded, color: Color(0xFF6A11CB)),
              SizedBox(width: 8),
              Text('Announcements', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: service.announcements.isEmpty
              ? const Text('No active notices today.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: service.announcements.length,
                    separatorBuilder: (c, i) => const Divider(height: 16, thickness: 0.1),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          service.announcements[index],
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('DISMISS'),
            ),
          ],
        );
      },
    );
  }
}
