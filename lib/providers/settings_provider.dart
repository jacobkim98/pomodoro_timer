import 'package:flutter/foundation.dart';
import '../models/timer_settings.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  TimerSettings _settings = TimerSettings();

  TimerSettings get settings => _settings;

  // 설정 불러오기
  Future<void> loadSettings() async {
    _settings = await _storageService.loadSettings();
    notifyListeners();
  }

  // 집중 시간 설정 (초 단위)
  Future<void> setFocusDurationSeconds(int seconds) async {
    _settings = _settings.copyWith(focusDurationSeconds: seconds);
    await _saveSettings();
  }

  // 휴식 시간 설정 (초 단위)
  Future<void> setShortBreakDurationSeconds(int seconds) async {
    _settings = _settings.copyWith(shortBreakDurationSeconds: seconds);
    await _saveSettings();
  }

  // 반복 횟수 설정
  Future<void> setSessionsBeforeLongBreak(int sessions) async {
    _settings = _settings.copyWith(sessionsBeforeLongBreak: sessions);
    await _saveSettings();
  }

  // 사운드 선택
  Future<void> setSelectedSound(SoundType sound) async {
    _settings = _settings.copyWith(selectedSound: sound);
    await _saveSettings();
  }

  // 볼륨 설정
  Future<void> setVolume(double volume) async {
    _settings = _settings.copyWith(volume: volume);
    await _saveSettings();
  }

  // 집중 시간에만 재생 설정
  Future<void> setPlaySoundOnlyDuringFocus(bool value) async {
    _settings = _settings.copyWith(playSoundOnlyDuringFocus: value);
    await _saveSettings();
  }

  // 자동 시작 설정
  Future<void> setAutoStartNextSession(bool value) async {
    _settings = _settings.copyWith(autoStartNextSession: value);
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }
}
