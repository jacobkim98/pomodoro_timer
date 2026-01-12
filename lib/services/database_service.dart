import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/focus_record.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pomodoro.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE focus_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL UNIQUE,
            focusMinutes INTEGER NOT NULL,
            completedSessions INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // 오늘 기록 가져오기 또는 생성
  Future<FocusRecord> getTodayRecord() async {
    final db = await database;
    final today = _dateToString(DateTime.now());

    final results = await db.query(
      'focus_records',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (results.isNotEmpty) {
      return FocusRecord.fromMap(results.first);
    }

    // 오늘 기록이 없으면 새로 생성
    final newRecord = FocusRecord(
      date: DateTime.now(),
      focusMinutes: 0,
      completedSessions: 0,
    );

    final id = await db.insert('focus_records', newRecord.toMap());
    return newRecord.copyWith(id: id);
  }

  // 집중 시간 추가
  Future<void> addFocusTime(int minutes) async {
    final db = await database;
    final today = _dateToString(DateTime.now());

    // 오늘 기록이 있는지 확인
    final results = await db.query(
      'focus_records',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (results.isNotEmpty) {
      // 기존 기록 업데이트
      final current = FocusRecord.fromMap(results.first);
      await db.update(
        'focus_records',
        {'focusMinutes': current.focusMinutes + minutes},
        where: 'id = ?',
        whereArgs: [current.id],
      );
    } else {
      // 새 기록 생성
      await db.insert('focus_records', {
        'date': today,
        'focusMinutes': minutes,
        'completedSessions': 0,
      });
    }
  }

  // 세션 완료 추가
  Future<void> addCompletedSession() async {
    final db = await database;
    final today = _dateToString(DateTime.now());

    final results = await db.query(
      'focus_records',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (results.isNotEmpty) {
      final current = FocusRecord.fromMap(results.first);
      await db.update(
        'focus_records',
        {'completedSessions': current.completedSessions + 1},
        where: 'id = ?',
        whereArgs: [current.id],
      );
    } else {
      await db.insert('focus_records', {
        'date': today,
        'focusMinutes': 0,
        'completedSessions': 1,
      });
    }
  }

  // 최근 N일 기록 가져오기
  Future<List<FocusRecord>> getRecentRecords(int days) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days - 1));

    final results = await db.query(
      'focus_records',
      where: 'date >= ?',
      whereArgs: [_dateToString(startDate)],
      orderBy: 'date DESC',
    );

    return results.map((map) => FocusRecord.fromMap(map)).toList();
  }

  // 이번 주 총 집중 시간
  Future<int> getWeeklyFocusMinutes() async {
    final records = await getRecentRecords(7);
    return records.fold<int>(0, (sum, record) => sum + record.focusMinutes);
  }

  // 이번 달 총 집중 시간
  Future<int> getMonthlyFocusMinutes() async {
    final records = await getRecentRecords(30);
    return records.fold<int>(0, (sum, record) => sum + record.focusMinutes);
  }

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
