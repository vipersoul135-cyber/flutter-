import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/bus.dart';
import '../../models/route.dart';
import '../../models/stop.dart';
import '../../screens/auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddStopDialog(BuildContext context, BusRoute route) {
    final nameCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '08:00 AM');
    final latCtrl = TextEditingController(text: '10.8500');
    final lngCtrl = TextEditingController(text: '78.7000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Stop to ${route.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Stop Name', hintText: 'e.g. Main Gate'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(labelText: 'Scheduled Time', hintText: 'e.g. 08:15 AM'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lngCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final lat = double.tryParse(latCtrl.text) ?? 10.85;
                final lng = double.tryParse(lngCtrl.text) ?? 78.70;
                Provider.of<FirebaseService>(context, listen: false).addStop(
                  route.id,
                  nameCtrl.text.trim(),
                  lat,
                  lng,
                  timeCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added stop "${nameCtrl.text.trim()}"')),
                );
              }
            },
            child: const Text('Add Stop'),
          ),
        ],
      ),
    );
  }

  void _showEditStopDialog(BuildContext context, BusRoute route, Stop stop) {
    final nameCtrl = TextEditingController(text: stop.name);
    final timeCtrl = TextEditingController(text: stop.scheduledTime);
    final latCtrl = TextEditingController(text: stop.latitude.toString());
    final lngCtrl = TextEditingController(text: stop.longitude.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Stop: ${stop.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Stop Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(labelText: 'Scheduled Time'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Latitude'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lngCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Longitude'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final lat = double.tryParse(latCtrl.text) ?? stop.latitude;
                final lng = double.tryParse(lngCtrl.text) ?? stop.longitude;
                Provider.of<FirebaseService>(context, listen: false).editStop(
                  route.id,
                  stop.id,
                  nameCtrl.text.trim(),
                  lat,
                  lng,
                  timeCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated stop "${nameCtrl.text.trim()}"')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buses = firebaseService.buses;
    final routes = firebaseService.routes;
    final onlineBuses = buses.where((b) => b.isOnline).length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: AppTheme.secondaryColor),
            SizedBox(width: 8),
            Text('Admin Command Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            firebaseService.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen(initialRoleIndex: 2)),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppTheme.offlineColor),
            onPressed: () {
              firebaseService.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen(initialRoleIndex: 2)),
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.directions_bus_rounded), text: 'Fleet Status'),
            Tab(icon: Icon(Icons.alt_route_rounded), text: 'Routes & Stops'),
            Tab(icon: Icon(Icons.campaign_rounded), text: 'Broadcasts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Fleet Status Tab
          _buildFleetTab(context, buses, onlineBuses, isDark),
          // 2. Routes & Stops Tab
          _buildRoutesTab(context, routes, isDark),
          // 3. Broadcasts Tab
          _buildBroadcastsTab(context, firebaseService, isDark),
        ],
      ),
    );
  }

  Widget _buildFleetTab(BuildContext context, List<Bus> buses, int onlineCount, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fleet Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Fleet',
                  '${buses.length}',
                  Icons.airport_shuttle_rounded,
                  const Color(0xFF1E3C72),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Live Online',
                  '$onlineCount',
                  Icons.sensors_rounded,
                  AppTheme.liveColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Offline',
                  '${buses.length - onlineCount}',
                  Icons.power_off_rounded,
                  AppTheme.offlineColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('All Fleet Vehicles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: buses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final bus = buses[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: bus.isOnline ? AppTheme.liveColor.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                    child: Icon(
                      Icons.directions_bus_rounded,
                      color: bus.isOnline ? AppTheme.liveColor : Colors.grey,
                    ),
                  ),
                  title: Text(bus.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${bus.number} • ${bus.routeName}\nNext: ${bus.nextStopName ?? "Campus Terminus"}'),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: bus.isOnline ? AppTheme.liveColor.withOpacity(0.1) : AppTheme.offlineColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bus.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: bus.isOnline ? AppTheme.liveColor : AppTheme.offlineColor,
                          ),
                        ),
                      ),
                      if (bus.etaMinutes != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${bus.etaMinutes} min ETA',
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRoutesTab(BuildContext context, List<BusRoute> routes, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: routes.length,
      itemBuilder: (context, rIdx) {
        final route = routes[rIdx];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          child: ExpansionTile(
            initiallyExpanded: rIdx == 0,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1E3C72),
              child: Icon(Icons.route_rounded, color: Colors.white, size: 20),
            ),
            title: Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${route.stops.length} Managed Stops'),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.secondaryColor),
              tooltip: 'Add Stop',
              onPressed: () => _showAddStopDialog(context, route),
            ),
            children: [
              const Divider(height: 1),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: route.stops.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 64),
                itemBuilder: (ctx, sIdx) {
                  final stop = route.stops[sIdx];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      child: Text('${stop.order + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(stop.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Schedule: ${stop.scheduledTime} • [${stop.latitude.toStringAsFixed(3)}, ${stop.longitude.toStringAsFixed(3)}]'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _showEditStopDialog(context, route, stop),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          onPressed: () {
                            Provider.of<FirebaseService>(context, listen: false).deleteStop(route.id, stop.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Deleted stop "${stop.name}"')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBroadcastsTab(BuildContext context, FirebaseService firebaseService, bool isDark) {
    final announcements = firebaseService.announcements;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Announcements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Chip(
                label: Text('${announcements.length} Active'),
                backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                labelStyle: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (announcements.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No active announcements.', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: announcements.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, idx) {
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
                    ),
                    title: Text(announcements[idx]),
                    subtitle: const Text('Broadcasted to all students & drivers'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
