import 'package:just_audio/just_audio.dart';
import '../utils/constants.dart';

class AudioService {
  AudioPlayer? _backgroundPlayer;
  AudioPlayer? _notificationPlayer;

  bool _isPlaying = false;
  SoundType _currentSound = SoundType.none;
  double _volume = DefaultSettings.defaultVolume;

  bool get isPlaying => _isPlaying;
  SoundType get currentSound => _currentSound;

  Future<void> init() async {
    // 초기화 시에는 아무것도 하지 않음
  }

  // 배경 사운드 재생
  Future<void> playBackgroundSound(SoundType sound) async {
    if (sound == SoundType.none) {
      await stopBackgroundSound();
      return;
    }

    // 먼저 상태를 설정 (UI가 즉시 반영되도록)
    _isPlaying = true;
    _currentSound = sound;

    final soundInfo = availableSounds.firstWhere((s) => s.type == sound);
    final soundFile = 'assets/sounds/${soundInfo.fileName}';

    // 기존 플레이어 정리
    if (_backgroundPlayer != null) {
      try {
        await _backgroundPlayer!.stop();
        await _backgroundPlayer!.dispose();
      } catch (e) {
        // 무시
      }
      _backgroundPlayer = null;
    }

    // 새 플레이어 생성 및 재생
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        _backgroundPlayer = AudioPlayer();
        await _backgroundPlayer!.setAsset(soundFile);
        await _backgroundPlayer!.setLoopMode(LoopMode.all);
        await _backgroundPlayer!.setVolume(_volume);
        await _backgroundPlayer!.play();
        return; // 성공하면 종료
      } catch (e) {
        // 실패 시 정리 후 재시도
        try {
          _backgroundPlayer?.dispose();
        } catch (_) {}
        _backgroundPlayer = null;

        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }

    // 모든 시도 실패
    _isPlaying = false;
    _currentSound = SoundType.none;
  }

  // 배경 사운드 정지
  Future<void> stopBackgroundSound() async {
    if (_backgroundPlayer != null) {
      try {
        await _backgroundPlayer!.stop();
        await _backgroundPlayer!.dispose();
      } catch (e) {
        // 무시
      }
      _backgroundPlayer = null;
    }
    _isPlaying = false;
    _currentSound = SoundType.none;
  }

  // 볼륨 설정
  Future<void> setVolume(double volume) async {
    _volume = volume;
    if (_backgroundPlayer != null) {
      try {
        await _backgroundPlayer!.setVolume(volume);
      } catch (e) {
        // 무시
      }
    }
  }

  // 일시정지
  Future<void> pauseBackgroundSound() async {
    if (_isPlaying && _backgroundPlayer != null) {
      try {
        await _backgroundPlayer!.pause();
      } catch (e) {
        // 무시
      }
    }
  }

  // 재개
  Future<void> resumeBackgroundSound() async {
    if (_currentSound != SoundType.none && _backgroundPlayer != null) {
      try {
        await _backgroundPlayer!.play();
      } catch (e) {
        // play 실패 시 다시 재생 시도
        await playBackgroundSound(_currentSound);
      }
    }
  }

  // 알림음 재생 (휴식 시작 - 조용한 알림)
  Future<void> playQuietNotification() async {
    try {
      _notificationPlayer?.dispose();
      _notificationPlayer = AudioPlayer();

      await _notificationPlayer!.setAsset('assets/sounds/notification_quiet.mp3');
      await _notificationPlayer!.setVolume(0.7);
      await _notificationPlayer!.play();
    } catch (e) {
      // 오류 발생 시 무시
    }
  }

  // 알림음 재생 (집중 시작 - 명확한 알림)
  Future<void> playLoudNotification() async {
    try {
      _notificationPlayer?.dispose();
      _notificationPlayer = AudioPlayer();

      await _notificationPlayer!.setAsset('assets/sounds/notification_loud.mp3');
      await _notificationPlayer!.setVolume(1.0);
      await _notificationPlayer!.play();
    } catch (e) {
      // 오류 발생 시 무시
    }
  }

  void dispose() {
    _backgroundPlayer?.dispose();
    _notificationPlayer?.dispose();
  }
}
