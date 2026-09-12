import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/bus.dart';
import '../../widgets/bus_card.dart';
import '../bus_details/bus_details_screen.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Separate active and offline buses for better dashboard organization
    List<Bus> activeBuses = firebaseService.buses.where((b) => b.isOnline).toList();
    List<Bus> offlineBuses = firebaseService.buses.where((b) => !b.isOnline).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Campus Buses'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              // Trigger a state reload to simulate a refresh
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Updated real-time feeds'),
                  duration: Duration(milliseconds: 600),
                ),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Overview Stats Row
              Row(
                children: [
                  _buildStatTile(
                    label: 'ONLINE',
                    count: activeBuses.length,
                    color: Colors.green,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildStatTile(
                    label: 'OFFLINE',
                    count: offlineBuses.length,
                    color: Colors.red,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildStatTile(
                    label: 'TOTAL',
                    count: firebaseService.buses.length,
                    color: Colors.blue,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: firebaseService.buses.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView(
                        children: [
                          if (activeBuses.isNotEmpty) ...[
                            Text(
                              'ACTIVE SERVICES (${activeBuses.length})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...activeBuses.map((bus) => BusCard(
                                  bus: bus,
                                  onTapTrack: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BusDetailsScreen(bus: bus),
                                      ),
                                    );
                                  },
                                )),
                            const SizedBox(height: 16),
                          ],
                          if (offlineBuses.isNotEmpty) ...[
                            Text(
                              'OFFLINE / GARAGE (${offlineBuses.length})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...offlineBuses.map((bus) => BusCard(
                                  bus: bus,
                                  onTapTrack: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BusDetailsScreen(bus: bus),
                                      ),
                                    );
                                  },
                                )),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2), width: 1.0),
        ),
        child: Column(
          children: [
            Text(
              count.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📡', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No buses are currently online.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Active routes will show up here once driver starts trip.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
