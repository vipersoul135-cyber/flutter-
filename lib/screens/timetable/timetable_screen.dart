import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/timetable.dart';
import '../../models/bus.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _filterQuery = '';

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter timetables based on search query (matching bus name or stop name)
    List<Timetable> filteredTimetables = firebaseService.timetables.where((timetable) {
      Bus bus = firebaseService.buses.firstWhere((b) => b.id == timetable.busId, orElse: () => firebaseService.buses.first);
      bool busMatch = bus.name.toLowerCase().contains(_filterQuery.toLowerCase());
      bool stopMatch = timetable.schedules.any((item) => item.stopName.toLowerCase().contains(_filterQuery.toLowerCase()));
      return busMatch || stopMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Schedules'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Filter text input
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1D2A) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _filterQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Filter by bus name or stop...',
                    prefixIcon: Icon(Icons.filter_list_rounded, color: Color(0xFF6A11CB)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: filteredTimetables.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        itemCount: filteredTimetables.length,
                        itemBuilder: (context, index) {
                          Timetable timetable = filteredTimetables[index];
                          Bus bus = firebaseService.buses.firstWhere((b) => b.id == timetable.busId, orElse: () => firebaseService.buses.first);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                )
                              ],
                              border: Border.all(
                                color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey[200]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Timetable Card Header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey[50],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        bus.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        bus.routeName,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),

                                // Stops/Schedules Table
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(2.5),
                                      1: FlexColumnWidth(1.0),
                                    },
                                    children: timetable.schedules.map((item) {
                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.circle, size: 6, color: Color(0xFF2575FC)),
                                                const SizedBox(width: 8),
                                                Text(
                                                  item.stopName,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(
                                              item.time,
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF6A11CB),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 48, color: isDark ? Colors.grey[700] : Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'No matching timetables found',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Check spelling or try a different filter query.',
            style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
