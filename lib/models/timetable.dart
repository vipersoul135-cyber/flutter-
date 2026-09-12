class Timetable {
  final String busId;
  final String routeId;
  final List<TimetableItem> schedules;

  Timetable({
    required this.busId,
    required this.routeId,
    required this.schedules,
  });

  Map<String, dynamic> toMap() {
    return {
      'busId': busId,
      'routeId': routeId,
      'schedules': schedules.map((item) => item.toMap()).toList(),
    };
  }

  factory Timetable.fromMap(Map<String, dynamic> map) {
    var rawList = map['schedules'] as List? ?? [];
    List<TimetableItem> list = rawList
        .map((e) => TimetableItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return Timetable(
      busId: map['busId'] ?? '',
      routeId: map['routeId'] ?? '',
      schedules: list,
    );
  }
}

class TimetableItem {
  final String stopName;
  final String time;

  TimetableItem({
    required this.stopName,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'stopName': stopName,
      'time': time,
    };
  }

  factory TimetableItem.fromMap(Map<String, dynamic> map) {
    return TimetableItem(
      stopName: map['stopName'] ?? '',
      time: map['time'] ?? '',
    );
  }
}
