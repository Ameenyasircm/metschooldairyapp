class TimetableModel {
  final String academicId;
  final String standard;
  final String division;
  final Map<String, List<String>> timetable;

  TimetableModel({
    required this.academicId,
    required this.standard,
    required this.division,
    required this.timetable,
  });

  factory TimetableModel.fromMap(Map<String, dynamic> map) {
    return TimetableModel(
      academicId: map['academic_id'] ?? '',
      standard: map['standard'] ?? '',
      division: map['division'] ?? '',
      timetable: (map['timetable'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'academic_id': academicId,
      'standard': standard,
      'division': division,
      'timetable': timetable,
    };
  }

  /// Creates an empty timetable with 5 days and 7 periods each.
  factory TimetableModel.empty(String standard, String division,String academicId) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    return TimetableModel(
      academicId: academicId,
      standard: standard,
      division: division,
      timetable: {
        for (var day in days) day: List.generate(7, (_) => ''),
      },
    );
  }
}
