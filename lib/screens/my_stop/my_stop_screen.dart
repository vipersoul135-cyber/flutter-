import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/bus.dart';
import '../../models/stop.dart';
import '../../models/route.dart';
import '../bus_details/bus_details_screen.dart';

class MyStopScreen extends StatelessWidget {
  const MyStopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final student = firebaseService.currentStudent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Bus? myBus;
    BusRoute? route;
    Stop? myStop;

    if (student?.selectedBusId != null) {
      int idx = firebaseService.buses.indexWhere((b) => b.id == student!.selectedBusId);
      if (idx != -1) {
        myBus = firebaseService.buses[idx];
        route = firebaseService.routes.firstWhere((r) => r.id == myBus!.routeId);

        if (student?.selectedStopId != null) {
          int sIdx = route.stops.indexWhere((s) => s.id == student!.selectedStopId);
          if (sIdx != -1) {
            myStop = route.stops[sIdx];
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pinned Stop'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: student?.selectedBusId == null
              ? _buildNoBusState(context, isDark)
              : (myStop == null
                  ? _buildSelectStopState(context, route!, isDark)
                  : _buildStopDashboard(context, myBus!, route!, myStop, isDark)),
        ),
      ),
    );
  }

  Widget _buildNoBusState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Select Bus First',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You must select a college bus before pinning your boarding stop.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Go back to dashboard/tabs
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('GO HOME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectStopState(BuildContext context, BusRoute route, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select Boarding Stop',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the stop where you board the bus from the list below.',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: route.stops.length,
            itemBuilder: (context, index) {
              Stop stop = route.stops[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(stop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Scheduled time: ${stop.scheduledTime}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Provider.of<FirebaseService>(context, listen: false).setSelectedStop(stop.id);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStopDashboard(
    BuildContext context,
    Bus bus,
    BusRoute route,
    Stop stop,
    bool isDark,
  ) {
    // Dynamic simulated distance and ETA based on active states
    double distanceVal = 2.8;
    String etaVal = bus.isOnline && bus.etaMinutes != null ? '${bus.etaMinutes} MIN' : 'Unavailable';
    String statusText = bus.isOnline ? '🟢 ON THE WAY' : '🔴 OFFLINE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stop detail card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📍 BOARDING STOP',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  Text(
                    statusText,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                stop.name,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MY BUS', style: TextStyle(color: Colors.white70, fontSize: 9)),
                      Text(bus.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('BUS DISTANCE', style: TextStyle(color: Colors.white70, fontSize: 9)),
                      Text('2.8 km', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('ETA', style: TextStyle(color: Colors.white70, fontSize: 9)),
                      Text(etaVal, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Actions Row
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
            backgroundColor: const Color(0xFF6A11CB),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('TRACK MY BUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // Un-pin stop to display selection list again
            Provider.of<FirebaseService>(context, listen: false).setSelectedStop(null);
          },
          style: OutlinedButton.styleFrom(
            side: Border.all(color: Colors.grey[400]!),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'CHANGE STOP',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
