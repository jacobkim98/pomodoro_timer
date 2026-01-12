import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/timer_settings.dart';
import '../services/audio_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class TimerProvider with ChangeNotifier {
  final AudioService _audioService = AudioService();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  Timer? _timer;
  TimerState _state = TimerState.idle;
  SessionType _sessionType = SessionType.focus;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  int _currentSession = 1;
  int _totalSessions = DefaultSettings.sessionsBeforeLongBreak;

  // 현재 세션에서 집중한 시간 (초)
  int _focusedSecondsInSession = 0;

  // 타이머 완료 처리 중 플래그 (중복 호출 방지)
  bool _isProcessingComplete = false;

  TimerState get state => _state;
  SessionType get sessionType => _sessionType;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get currentSession => _currentSession;
  int get totalSessions => _totalSessions;
  bool get isSoundPlaying => _audioService.isPlaying;

  double get progress {
    if (_totalSeconds == 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  String get timeString {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sessionTypeString {
    switch (_sessionType) {
      case SessionType.focus:
        return '집중';
      case SessionType.shortBreak:
        return '휴식';
    }
  }

  Future<void> init() async {
    await _audioService.init();
    await _notificationService.init();
    await _notificationService.requestPermission();
  }

  // 설정 적용
  void applySettings(TimerSettings settings) {
    _totalSessions = settings.sessionsBeforeLongBreak;
    // idle 상태이거나 아직 시간이 설정되지 않은 경우
    if (_state == TimerState.idle || _totalSeconds == 0) {
      _setDurationFromSettings(settings);
    }
  }

  void _setDurationFromSettings(TimerSettings settings) {
    switch (_sessionType) {
      case SessionType.focus:
        _totalSeconds = settings.focusDurationSeconds;
        break;
      case SessionType.shortBreak:
        _totalSeconds = settings.shortBreakDurationSeconds;
        break;
    }
    _remainingSeconds = _totalSeconds;
    notifyListeners();
  }

  // 타이머 시작
  Future<void> start(TimerSettings settings) async {
    // 기존 타이머가 있으면 취소
    _timer?.cancel();
    _timer = null;

    // remainingSeconds가 0이면 설정에서 시간 가져오기
    if (_remainingSeconds <= 0) {
      _setDurationFromSettings(settings);
    }

    // 여전히 0이면 시작하지 않음
    if (_remainingSeconds <= 0) {
      return;
    }

    _state = TimerState.running;

    // 화면 꺼짐 방지
    _notificationService.enableWakelock();

    // 집중 시작 시 배경 사운드 재생
    if (_sessionType == SessionType.focus) {
      _notificationService.showFocusStartNotification();

      // 배경 사운드 재생 (none이 아닐 때만)
      if (settings.selectedSound != SoundType.none) {
        _audioService.setVolume(settings.volume);
        _audioService.playBackgroundSound(settings.selectedSound).then((_) {
          notifyListeners(); // 배경음 상태 변경 후 UI 업데이트
        });
      }
    }

    // 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick(settings);
    });

    notifyListeners();
  }

  void _tick(TimerSettings settings) {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;

      // 집중 시간 카운트
      if (_sessionType == SessionType.focus) {
        _focusedSecondsInSession++;
      }

      notifyListeners();
    } else {
      _onTimerComplete(settings);
    }
  }

  Future<void> _onTimerComplete(TimerSettings settings) async {
    // 중복 호출 방지
    if (_isProcessingComplete) return;
    _isProcessingComplete = true;

    _timer?.cancel();
    _timer = null;

    if (_sessionType == SessionType.focus) {
      // 집중 시간 기록 저장
      final focusedMinutes = _focusedSecondsInSession ~/ 60;
      if (focusedMinutes > 0) {
        await _databaseService.addFocusTime(focusedMinutes);
      }
      await _databaseService.addCompletedSession();
      _focusedSecondsInSession = 0;

      // 집중 종료 알림 (휴식 시작 - 조용한 알림음)
      await _notificationService.showFocusEndNotification();
      await _audioService.stopBackgroundSound();
      await _audioService.playQuietNotification();

      // 다음은 휴식
      _sessionType = SessionType.shortBreak;
    } else {
      // 휴식 종료
      _currentSession++;

      // 전체 사이클 완료 체크 (모든 반복 횟수 끝남)
      if (_currentSession > _totalSessions) {
        // 전체 사이클 완료 알림
        await _notificationService.showCycleCompleteNotification();
        await _audioService.playLoudNotification();

        _currentSession = 1;
        _sessionType = SessionType.focus;
        _setDurationFromSettings(settings);

        // 전체 사이클 완료 시 멈춤
        _state = TimerState.idle;
        _isProcessingComplete = false;  // 플래그 리셋
        await _notificationService.disableWakelock();
        notifyListeners();
        return;
      }

      // 아직 사이클 진행 중 - 다음 집중 시작 알림
      await _notificationService.showBreakEndNotification();
      await _audioService.playLoudNotification();
      _sessionType = SessionType.focus;
    }

    _setDurationFromSettings(settings);

    // 자동으로 다음 세션 시작
    _isProcessingComplete = false;  // 플래그 리셋

    // 상태를 idle로 먼저 변경 (start 함수가 제대로 동작하도록)
    _state = TimerState.idle;

    if (settings.autoStartNextSession) {
      start(settings);
    } else {
      notifyListeners();
    }
  }

  // 일시정지
  Future<void> pause() async {
    if (_state == TimerState.running) {
      _timer?.cancel();
      _state = TimerState.paused;
      await _audioService.pauseBackgroundSound();
      notifyListeners();
    }
  }

  // 재개
  Future<void> resume(TimerSettings settings) async {
    if (_state == TimerState.paused) {
      _state = TimerState.running;

      if (_sessionType == SessionType.focus &&
          settings.selectedSound != SoundType.none) {
        await _audioService.resumeBackgroundSound();
      }

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _tick(settings);
      });

      notifyListeners();
    }
  }

  // 리셋
  Future<void> reset(TimerSettings settings) async {
    _timer?.cancel();

    // 진행 중이던 집중 시간 저장
    if (_sessionType == SessionType.focus && _focusedSecondsInSession > 60) {
      final focusedMinutes = _focusedSecondsInSession ~/ 60;
      await _databaseService.addFocusTime(focusedMinutes);
    }
    _focusedSecondsInSession = 0;

    _state = TimerState.idle;
    await _audioService.stopBackgroundSound();
    await _notificationService.disableWakelock();  // 화면 꺼짐 허용
    await _notificationService.cancelAll();  // 알림 취소
    _setDurationFromSettings(settings);
    notifyListeners();
  }

  // 세션 건너뛰기
  Future<void> skip(TimerSettings settings) async {
    await _onTimerComplete(settings);
  }

  // 완전 초기화
  Future<void> fullReset(TimerSettings settings) async {
    _timer?.cancel();
    _state = TimerState.idle;
    _sessionType = SessionType.focus;
    _currentSession = 1;
    _focusedSecondsInSession = 0;
    await _audioService.stopBackgroundSound();
    await _notificationService.disableWakelock();  // 화면 꺼짐 허용
    await _notificationService.cancelAll();  // 알림 취소
    _setDurationFromSettings(settings);
    notifyListeners();
  }

  // 실시간 사운드 변경
  Future<void> changeSound(SoundType sound, double volume) async {
    if (_state == TimerState.running && _sessionType == SessionType.focus) {
      await _audioService.setVolume(volume);
      await _audioService.playBackgroundSound(sound);
    }
  }

  // 실시간 볼륨 변경
  Future<void> changeVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  // 배경음 토글 (멈추기/재생)
  Future<void> toggleBackgroundSound(TimerSettings settings) async {
    if (_audioService.isPlaying) {
      await _audioService.stopBackgroundSound();
    } else {
      if (settings.selectedSound != SoundType.none) {
        await _audioService.setVolume(settings.volume);
        await _audioService.playBackgroundSound(settings.selectedSound);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
