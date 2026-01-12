import 'package:flutter/material.dart';

// 기본 타이머 설정
class DefaultSettings {
  static const int focusDurationSeconds = 25 * 60; // 25분 (초)
  static const int shortBreakDurationSeconds = 5 * 60; // 5분 (초)
  static const int sessionsBeforeLongBreak = 4; // 회
  static const double defaultVolume = 0.8; // 기본 볼륨 (높임)
}

// 타이머 상태
enum TimerState {
  idle,
  running,
  paused,
}

// 세션 타입
enum SessionType {
  focus,
  shortBreak,
}

// 배경 사운드 타입
enum SoundType {
  none,
  fireplace,
  rain,
  waves,
  birds,
  whiteNoise,
  piano,
}

// 사운드 정보
class SoundInfo {
  final SoundType type;
  final String name;
  final String fileName;
  final IconData icon;

  const SoundInfo({
    required this.type,
    required this.name,
    required this.fileName,
    required this.icon,
  });
}

// 사용 가능한 사운드 목록
const List<SoundInfo> availableSounds = [
  SoundInfo(
    type: SoundType.none,
    name: '없음',
    fileName: '',
    icon: Icons.volume_off,
  ),
  SoundInfo(
    type: SoundType.fireplace,
    name: '모닥불',
    fileName: 'fireplace.mp3',
    icon: Icons.local_fire_department,
  ),
  SoundInfo(
    type: SoundType.rain,
    name: '빗소리',
    fileName: 'rain.mp3',
    icon: Icons.water_drop,
  ),
  SoundInfo(
    type: SoundType.waves,
    name: '파도',
    fileName: 'waves.mp3',
    icon: Icons.waves,
  ),
  SoundInfo(
    type: SoundType.birds,
    name: '새소리',
    fileName: 'birds.mp3',
    icon: Icons.park,
  ),
  SoundInfo(
    type: SoundType.whiteNoise,
    name: '백색소음',
    fileName: 'white_noise.mp3',
    icon: Icons.graphic_eq,
  ),
  SoundInfo(
    type: SoundType.piano,
    name: '피아노',
    fileName: 'piano.mp3',
    icon: Icons.piano,
  ),
];

// 앱 색상
class AppColors {
  static const Color primary = Color(0xFFE57373); // 토마토 레드
  static const Color focus = Color(0xFFE57373); // 집중 모드
  static const Color shortBreak = Color(0xFF81C784); // 휴식
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color text = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFF9E9E9E);
}
