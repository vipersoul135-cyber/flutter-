import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/bus.dart';
import '../../models/route.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/eta_card.dart';

class MapScreen extends StatelessWidget {
  final Bus bus;

  const MapScreen({
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
    String? myStopId = firebaseService.currentStudent?.selectedStopId;

    return Scaffold(
      appBar: AppBar(
        title: Text('${liveBus.name} Live Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Map Widget takes full area
            Positioned.fill(
              child: MapWidget(
                bus: liveBus,
                stops: route.stops,
                studentStopId: myStopId,
              ),
            ),

            // Top Status Warning Overlay (if offline)
            if (!liveBus.isOnline)
              Positioned(
                top: 80,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🔴 BUS OFFLINE - SHOWING LAST KNOWN LOCATION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom Floating Live tracking overlay panel
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: liveBus.isOnline
                  ? EtaCard(
                      etaMinutes: liveBus.etaMinutes,
                      busName: liveBus.name,
                      nextStop: liveBus.nextStopName ?? 'Next Stop',
                    )
                  : _buildOfflineMapCard(liveBus, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineMapCard(Bus liveBus, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                '🔴 BUS OFFLINE',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'LAST KNOWN LOCATION',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 2),
          Text(
            'Stationed near ${liveBus.nextStopName ?? 'Unknown'}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'GPS coordinates freeze. Driver has stopped the trip broadcast.',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
