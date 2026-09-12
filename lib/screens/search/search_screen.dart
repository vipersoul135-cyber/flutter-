import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/bus.dart';
import '../../models/stop.dart';
import '../../widgets/search_widget.dart';
import '../../widgets/bus_card.dart';
import '../bus_details/bus_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter results based on search query
    List<Map<String, dynamic>> searchResults = [];

    if (_searchQuery.trim().isNotEmpty) {
      String query = _searchQuery.toLowerCase().trim();

      // Find matching buses directly
      for (var bus in firebaseService.buses) {
        bool matchesBus = bus.name.toLowerCase().contains(query) ||
            bus.routeName.toLowerCase().contains(query) ||
            bus.number.toLowerCase().contains(query);

        if (matchesBus) {
          searchResults.add({
            'type': 'bus',
            'bus': bus,
            'matchText': 'Bus matches route/number',
          });
          continue; // Avoid duplicates
        }

        // Find if any stop on this bus's route matches the query
        var route = firebaseService.routes.firstWhere((r) => r.id == bus.routeId);
        var matchingStops = route.stops.where((s) => s.name.toLowerCase().contains(query));

        if (matchingStops.isNotEmpty) {
          searchResults.add({
            'type': 'stop_match',
            'bus': bus,
            'stop': matchingStops.first,
            'matchText': 'Passes through ${matchingStops.first.name}',
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Campus Transport'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchWidget(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                hintText: 'Search bus name, route or stop (e.g. Samayapuram)...',
              ),
              const SizedBox(height: 20),

              // Search results display
              Expanded(
                child: _searchQuery.trim().isEmpty
                    ? _buildSearchSuggestions(isDark)
                    : (searchResults.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              var result = searchResults[index];
                              Bus bus = result['bus'];
                              String matchText = result['matchText'];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 6),
                                    child: Row(
                                      children: [
                                        Icon(
                                          result['type'] == 'bus' ? Icons.directions_bus_rounded : Icons.location_on_rounded,
                                          size: 13,
                                          color: const Color(0xFF6A11CB),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          matchText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  BusCard(
                                    bus: bus,
                                    onTapTrack: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BusDetailsScreen(bus: bus),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(bool isDark) {
    final suggestions = ['Srirangam', 'Samayapuram', 'Mannachanallur', 'College', 'BUS 12', 'BUS 15'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'POPULAR SEARCHES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: suggestions.map((tag) {
            return InkWell(
              onTap: () {
                _searchController.text = tag;
                setState(() {
                  _searchQuery = tag;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1D2A) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF2575FC)),
                    const SizedBox(width: 6),
                    Text(
                      tag,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(Icons.search_rounded, size: 64, color: isDark ? Colors.grey[800] : Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'Type stops or bus names above to track',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🚌',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'No buses found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching another bus or route.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }
}
