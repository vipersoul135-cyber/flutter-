import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/bus.dart';
import '../../models/route.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/route_timeline.dart';
import '../map/map_screen.dart';

class BusDetailsScreen extends StatelessWidget {
  final Bus bus;

  const BusDetailsScreen({
    Key? key,
    required this.bus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch the updated live version of this bus from state provider
    Bus liveBus = firebaseService.buses.firstWhere((b) => b.id == bus.id, orElse: () => bus);
    BusRoute route = firebaseService.routes.firstWhere((r) => r.id == liveBus.routeId);

    bool isMyBus = firebaseService.currentStudent?.selectedBusId == liveBus.id;
    final timeStr = liveBus.lastUpdated != null
        ? DateFormat('hh:mm:ss a').format(liveBus.lastUpdated!)
        : 'Never';

    return Scaffold(
      appBar: AppBar(
        title: Text(liveBus.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isMyBus ? Icons.star_rounded : Icons.star_border_rounded,
              color: isMyBus ? Colors.amber : (isDark ? Colors.white : Colors.black87),
              size: 26,
            ),
            onPressed: () {
              if (isMyBus) {
                firebaseService.setSelectedBus(null);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removed ${liveBus.name} from My Bus')),
                );
              } else {
                firebaseService.setSelectedBus(liveBus.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Set ${liveBus.name} as My Bus')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Overview Board
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              liveBus.routeName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              liveBus.number,
                              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        StatusBadge(status: liveBus.status),
                      ],
                    ),
                    const Divider(height: 24, thickness: 0.1, color: Colors.grey),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetric('CURRENT LOCATION', liveBus.isOnline ? '📍 ${liveBus.nextStopName}' : 'Offline'),
                        _buildMetric('ETA', liveBus.isOnline && liveBus.etaMinutes != null ? '${liveBus.etaMinutes} mins' : 'Unavailable'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetric('SPEED', liveBus.isOnline && liveBus.currentLocation != null ? '${liveBus.currentLocation!.speed.toStringAsFixed(0)} km/h' : '0 km/h'),
                        _buildMetric('LAST UPDATE', timeStr),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Route Progress Heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'ROUTE TIMELINE PROGRESS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable Timeline
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RouteTimeline(
                  stops: route.stops,
                  nextStopName: liveBus.nextStopName,
                  busStatus: liveBus.status,
                ),
              ),
            ),

            // Action Buttons Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.styleFrom(
                elevation: 4,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: const Color(0xFF6A11CB),
              ) == null
                  ? const SizedBox()
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapScreen(bus: liveBus),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF6A11CB),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.map_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'TRACK LIVE MAP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
