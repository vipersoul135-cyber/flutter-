import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/bus.dart';
import '../../widgets/bus_card.dart';
import '../search/search_screen.dart';
import '../bus_details/bus_details_screen.dart';
import '../../models/route.dart';
import '../../widgets/route_timeline.dart';

class MyBusScreen extends StatelessWidget {
  const MyBusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final student = firebaseService.currentStudent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Bus? myBus;
    BusRoute? route;
    if (student?.selectedBusId != null) {
      int idx = firebaseService.buses.indexWhere((b) => b.id == student!.selectedBusId);
      if (idx != -1) {
        myBus = firebaseService.buses[idx];
        route = firebaseService.routes.firstWhere((r) => r.id == myBus!.routeId);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pinned Bus'),
        centerTitle: false,
        actions: [
          if (myBus != null)
            TextButton.icon(
              icon: const Icon(Icons.star_border_rounded, color: Colors.red, size: 18),
              label: const Text('REMOVE', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () {
                firebaseService.setSelectedBus(null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Removed bus shortcut')),
                );
              },
            )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: myBus != null
              ? ListView(
                  children: [
                    const SizedBox(height: 10),
                    // Bus Detail Card
                    BusCard(
                      bus: myBus,
                      onTapTrack: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusDetailsScreen(bus: myBus!),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Quick Summary of Stop details
                    Text(
                      'ROUTE PROGRESS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (route != null)
                      RouteTimeline(
                        stops: route.stops,
                        nextStopName: myBus.nextStopName,
                        busStatus: myBus.status,
                      ),
                  ],
                )
              : _buildEmptyState(context, isDark),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No My Bus Selected',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Pin a college bus from search/live view to track it on your shortcuts dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.search_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'FIND MY COLLEGE BUS',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
