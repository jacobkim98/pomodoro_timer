import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_settings.dart';

class StorageService {
  static const String _settingsKey = 'timer_settings';

  // 설정 저장
  Future<void> saveSettings(TimerSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // 설정 불러오기
  Future<TimerSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);
    if (jsonString != null) {
      return TimerSettings.fromJson(jsonDecode(jsonString));
    }
    return TimerSettings();
  }
}
