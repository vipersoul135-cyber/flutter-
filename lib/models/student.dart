class Student {
  final String regNo;
  final String name;
  final String email;
  final String department;
  final String year;
  final String college;
  final String? selectedBusId;
  final String? selectedStopId;
  final String role; // 'student', 'driver', 'admin'

  Student({
    required this.regNo,
    required this.name,
    required this.email,
    required this.department,
    required this.year,
    required this.college,
    this.selectedBusId,
    this.selectedStopId,
    this.role = 'student',
  });

  Student copyWith({
    String? regNo,
    String? name,
    String? email,
    String? department,
    String? year,
    String? college,
    String? selectedBusId,
    String? selectedStopId,
    String? role,
  }) {
    return Student(
      regNo: regNo ?? this.regNo,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      year: year ?? this.year,
      college: college ?? this.college,
      selectedBusId: selectedBusId ?? this.selectedBusId,
      selectedStopId: selectedStopId ?? this.selectedStopId,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'regNo': regNo,
      'name': name,
      'email': email,
      'department': department,
      'year': year,
      'college': college,
      'selectedBusId': selectedBusId,
      'selectedStopId': selectedStopId,
      'role': role,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      regNo: map['regNo'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      year: map['year'] ?? '',
      college: map['college'] ?? '',
      selectedBusId: map['selectedBusId'],
      selectedStopId: map['selectedStopId'],
      role: map['role'] ?? 'student',
    );
  }
}
