import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bus.dart';
import '../core/theme/app_theme.dart';
import 'status_badge.dart';

class BusCard extends StatelessWidget {
  final Bus bus;
  final VoidCallback onTapTrack;

  const BusCard({
    Key? key,
    required this.bus,
    required this.onTapTrack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = bus.lastUpdated != null
        ? DateFormat('hh:mm:ss a').format(bus.lastUpdated!)
        : 'Never';

    // Status color selection
    Color borderAccent;
    switch (bus.status.toLowerCase()) {
      case 'live':
      case 'online':
        borderAccent = AppTheme.liveColor;
        break;
      case 'at_stop':
        borderAccent = AppTheme.atStopColor;
        break;
      case 'delayed':
        borderAccent = AppTheme.delayedColor;
        break;
      case 'offline':
        borderAccent = AppTheme.offlineColor;
        break;
      case 'not_started':
      default:
        borderAccent = AppTheme.notStartedColor;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: borderAccent.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_bus_rounded, color: Color(0xFF2575FC), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        bus.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: bus.status),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Route Detail
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ROUTE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bus.routeName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      if (bus.isOnline && bus.etaMinutes != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppTheme.colorfulGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'ETA',
                                style: TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${bus.etaMinutes.toString().padLeft(2, '0')} MIN',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Colors.grey, thickness: 0.1),
                  ),

                  // Location details
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📍 CURRENT LOCATION',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bus.isOnline
                                  ? (bus.status == 'at_stop' ? 'At ${bus.nextStopName}' : 'Moving near ${bus.nextStopName}')
                                  : 'Offline / Garage',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : const Color(0xFF5A6B7C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '➡️ NEXT STOP',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bus.nextStopName ?? 'Unavailable',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : const Color(0xFF5A6B7C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card Footer Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.withOpacity(0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Updated: $timeStr',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: onTapTrack,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: borderAccent.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bus.status == 'offline' ? 'VIEW INFO' : 'TRACK LIVE',
                          style: TextStyle(
                            color: borderAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: borderAccent, size: 14),
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
}
