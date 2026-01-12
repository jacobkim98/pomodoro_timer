class FocusRecord {
  final int? id;
  final DateTime date;
  final int focusMinutes; // 집중한 시간 (분)
  final int completedSessions; // 완료한 세션 수

  FocusRecord({
    this.id,
    required this.date,
    required this.focusMinutes,
    required this.completedSessions,
  });

  FocusRecord copyWith({
    int? id,
    DateTime? date,
    int? focusMinutes,
    int? completedSessions,
  }) {
    return FocusRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': _dateToString(date),
      'focusMinutes': focusMinutes,
      'completedSessions': completedSessions,
    };
  }

  factory FocusRecord.fromMap(Map<String, dynamic> map) {
    return FocusRecord(
      id: map['id'],
      date: _stringToDate(map['date']),
      focusMinutes: map['focusMinutes'],
      completedSessions: map['completedSessions'],
    );
  }

  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _stringToDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  // 시간을 보기 좋게 포맷
  String get formattedTime {
    final hours = focusMinutes ~/ 60;
    final minutes = focusMinutes % 60;
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    }
    return '${minutes}분';
  }
}
