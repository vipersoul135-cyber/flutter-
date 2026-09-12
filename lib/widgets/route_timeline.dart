import 'package:flutter/material.dart';
import '../models/stop.dart';
import '../core/theme/app_theme.dart';

class RouteTimeline extends StatelessWidget {
  final List<Stop> stops;
  final String? nextStopName;
  final String busStatus;

  const RouteTimeline({
    Key? key,
    required this.stops,
    required this.nextStopName,
    required this.busStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find the next stop index
    int nextStopIdx = -1;
    if (nextStopName != null && busStatus != 'not_started' && busStatus != 'offline') {
      nextStopIdx = stops.indexWhere((s) => s.name.toLowerCase() == nextStopName!.toLowerCase());
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        Stop stop = stops[index];

        // Determine status of this stop
        bool isCompleted = false;
        bool isCurrent = false;
        bool isUpcoming = true;

        if (busStatus == 'offline' || busStatus == 'not_started') {
          isUpcoming = true;
        } else if (nextStopIdx != -1) {
          if (index < nextStopIdx) {
            isCompleted = true;
            isUpcoming = false;
          } else if (index == nextStopIdx) {
            isCurrent = true;
            isUpcoming = false;
          } else {
            isUpcoming = true;
          }
        } else {
          // If no next stop is detected but active, first stop is current
          if (index == 0) {
            isCurrent = true;
            isUpcoming = false;
          }
        }

        // Color and icon configurations
        Color nodeColor;
        Widget nodeIcon;

        if (isCompleted) {
          nodeColor = AppTheme.liveColor;
          nodeIcon = Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppTheme.liveColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
          );
        } else if (isCurrent) {
          nodeColor = busStatus == 'delayed' ? AppTheme.delayedColor : AppTheme.atStopColor;
          nodeIcon = Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              boxShadow: AppTheme.glowShadow(nodeColor),
            ),
            child: const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 14),
          );
        } else {
          nodeColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
          nodeIcon = Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
              border: Border.all(color: nodeColor, width: 2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline Column (Dots and Connecting Lines)
              Column(
                children: [
                  const SizedBox(height: 4),
                  nodeIcon,
                  if (index < stops.length - 1)
                    Expanded(
                      child: Container(
                        width: 2.5,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isCompleted ? AppTheme.liveColor : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Stop details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stop.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                              color: isCurrent
                                  ? nodeColor
                                  : (isUpcoming
                                      ? (isDark ? Colors.grey[500] : Colors.grey[600])
                                      : (isDark ? Colors.white70 : Colors.black87)),
                            ),
                          ),
                          Text(
                            stop.scheduledTime,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isCurrent
                                  ? nodeColor
                                  : (isDark ? Colors.grey[500] : Colors.grey[500]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted
                            ? 'Completed'
                            : (isCurrent
                                ? (busStatus == 'at_stop' ? 'Bus arrived at stop' : 'Bus approaching stop')
                                : 'Upcoming stopping'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isCurrent
                              ? nodeColor.withOpacity(0.9)
                              : (isDark ? Colors.grey[600] : Colors.grey[500]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
