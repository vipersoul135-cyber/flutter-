import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bus.dart';
import '../models/stop.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class MapWidget extends StatefulWidget {
  final Bus bus;
  final List<Stop> stops;
  final String? studentStopId;

  const MapWidget({
    Key? key,
    required this.bus,
    required this.stops,
    this.studentStopId,
  }) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  bool _showVectorMap = true; // Default to vector map for immediate playability

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_showVectorMap && _mapController != null && widget.bus.currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            widget.bus.currentLocation!.latitude,
            widget.bus.currentLocation!.longitude,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Map Renderer
        Positioned.fill(
          child: _showVectorMap
              ? _buildVectorMap(isDark)
              : _buildGoogleMap(isDark),
        ),

        // Map Mode Switcher (Floating Button)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppTheme.softShadow,
            ),
            child: IconButton(
              icon: Icon(
                _showVectorMap ? Icons.map_rounded : Icons.palette_rounded,
                color: const Color(0xFF6A11CB),
              ),
              tooltip: _showVectorMap ? 'Switch to Google Maps' : 'Switch to Stylized Map',
              onPressed: () {
                setState(() {
                  _showVectorMap = !_showVectorMap;
                });
              },
            ),
          ),
        ),

        // Map Legend Indicator
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1D2A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.liveColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _showVectorMap ? 'Stylized Tracker' : 'Google Maps Live',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleMap(bool isDark) {
    Set<Marker> markers = {};
    Set<Polyline> polylines = {};

    // 1. Add Bus Marker
    if (widget.bus.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('bus'),
          position: LatLng(
            widget.bus.currentLocation!.latitude,
            widget.bus.currentLocation!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: widget.bus.name, snippet: 'Speed: ${widget.bus.currentLocation!.speed.toStringAsFixed(1)} km/h'),
        ),
      );
    }

    // 2. Add Stop Markers
    for (var stop in widget.stops) {
      bool isStudentStop = stop.id == widget.studentStopId;
      markers.add(
        Marker(
          markerId: MarkerId(stop.id),
          position: LatLng(stop.latitude, stop.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isStudentStop ? BitmapDescriptor.hueRose : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(title: stop.name, snippet: 'Scheduled: ${stop.scheduledTime}'),
        ),
      );
    }

    // 3. Create Polyline connecting stops
    List<LatLng> points = widget.stops.map((s) => LatLng(s.latitude, s.longitude)).toList();
    if (points.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route_line'),
          points: points,
          color: const Color(0xFF6A11CB),
          width: 5,
        ),
      );
    }

    LatLng initialCenter = widget.bus.currentLocation != null
        ? LatLng(widget.bus.currentLocation!.latitude, widget.bus.currentLocation!.longitude)
        : AppConstants.collegeLocation;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialCenter,
        zoom: AppConstants.defaultZoom,
      ),
      markers: markers,
      polylines: polylines,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      onMapCreated: (controller) {
        _mapController = controller;
        if (isDark) {
          // Can apply a dark theme style string here if available
        }
      },
    );
  }

  Widget _buildVectorMap(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0F111E) : const Color(0xFFECEFF1),
      child: ClipRRect(
        child: InteractiveViewer(
          maxScale: 4.0,
          minScale: 0.5,
          child: CustomPaint(
            painter: VectorMapPainter(
              bus: widget.bus,
              stops: widget.stops,
              studentStopId: widget.studentStopId,
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }
}

class VectorMapPainter extends CustomPainter {
  final Bus bus;
  final List<Stop> stops;
  final String? studentStopId;
  final bool isDark;

  VectorMapPainter({
    required this.bus,
    required this.stops,
    required this.studentStopId,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stops.isEmpty) return;

    // 1. Calculate boundaries of our route to scale coordinates dynamically
    double minLat = stops.map((s) => s.latitude).reduce(min);
    double maxLat = stops.map((s) => s.latitude).reduce(max);
    double minLng = stops.map((s) => s.longitude).reduce(min);
    double maxLng = stops.map((s) => s.longitude).reduce(max);

    // Expand boundary slightly to add padding
    double paddingFactor = 0.15;
    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;
    minLat -= latDiff * paddingFactor;
    maxLat += latDiff * paddingFactor;
    minLng -= lngDiff * paddingFactor;
    maxLng += lngDiff * paddingFactor;

    // Helper to translate GPS to Canvas X/Y coordinates
    Offset translate(double lat, double lng) {
      double pctX = (lng - minLng) / (maxLng - minLng);
      double pctY = (lat - minLat) / (maxLat - minLat);

      // Invert Y because canvas coordinates start top-left, while latitude goes up northwards
      double x = pctX * size.width;
      double y = (1.0 - pctY) * size.height;

      // Restrict values inside canvas area
      return Offset(x, y);
    }

    // 2. Draw roads (route lines connecting stops)
    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF2C3E50) : Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final routeLinePaint = Paint()
      ..color = const Color(0xFF6A11CB).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < stops.length; i++) {
      Offset pos = translate(stops[i].latitude, stops[i].longitude);
      if (i == 0) {
        path.moveTo(pos.dx, pos.dy);
      } else {
        path.lineTo(pos.dx, pos.dy);
      }
    }

    // Draw background road path
    canvas.drawPath(path, roadPaint);
    // Draw highlighted active route path
    canvas.drawPath(path, routeLinePaint);

    // 3. Draw stops
    for (int i = 0; i < stops.length; i++) {
      Stop stop = stops[i];
      Offset pos = translate(stop.latitude, stop.longitude);
      bool isStudentStop = stop.id == studentStopId;
      bool isCollege = stop.name.toLowerCase().contains('college');

      // Outer glow circle
      final glowColor = isCollege
          ? const Color(0xFF00E5FF)
          : (isStudentStop ? AppTheme.favoriteColor : const Color(0xFF6A11CB));

      final glowPaint = Paint()
        ..color = glowColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 16.0, glowPaint);

      // Node point
      final nodePaint = Paint()
        ..color = isCollege
            ? const Color(0xFF00E5FF)
            : (isStudentStop ? AppTheme.favoriteColor : Colors.white)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 6.0, nodePaint);

      // Node border
      final borderPaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(pos, 6.0, borderPaint);

      // Draw stop labels (name + scheduled time)
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.text = TextSpan(
        text: stop.name,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, pos.dy + 8));

      textPainter.text = TextSpan(
        text: stop.scheduledTime,
        style: TextStyle(
          color: isDark ? Colors.grey[600] : Colors.grey[600],
          fontSize: 7.0,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, pos.dy + 20));
    }

    // 4. Draw moving Bus Marker
    if (bus.currentLocation != null) {
      Offset busPos = translate(
        bus.currentLocation!.latitude,
        bus.currentLocation!.longitude,
      );

      Color busAccent = Colors.green;
      if (bus.status == 'delayed') busAccent = Colors.orange;

      // Glow effect
      final busGlowPaint = Paint()
        ..color = busAccent.withOpacity(0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(busPos, 22.0, busGlowPaint);

      // Main Marker Circle
      final busPaint = Paint()
        ..color = busAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(busPos, 11.0, busPaint);

      final busBorderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(busPos, 11.0, busBorderPaint);

      // Text inside marker (e.g. 🚌 or bus label)
      final busTextPainter = TextPainter(
        text: const TextSpan(
          text: '🚌',
          style: TextStyle(fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      busTextPainter.paint(
        canvas,
        Offset(busPos.dx - busTextPainter.width / 2, busPos.dy - busTextPainter.height / 2),
      );

      // Display floating speed label
      if (bus.isOnline) {
        final speedTextPainter = TextPainter(
          text: TextSpan(
            text: '${bus.currentLocation!.speed.toStringAsFixed(0)} km/h',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              backgroundColor: Colors.black54,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        speedTextPainter.paint(
          canvas,
          Offset(busPos.dx - speedTextPainter.width / 2, busPos.dy - 22),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant VectorMapPainter oldDelegate) {
    return oldDelegate.bus.currentLocation?.latitude != bus.currentLocation?.latitude ||
        oldDelegate.bus.currentLocation?.longitude != bus.currentLocation?.longitude ||
        oldDelegate.bus.status != bus.status ||
        oldDelegate.stops.length != stops.length ||
        oldDelegate.studentStopId != studentStopId;
  }
}
