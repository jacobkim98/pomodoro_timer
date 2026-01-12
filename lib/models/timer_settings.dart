import '../utils/constants.dart';

class TimerSettings {
  final int focusDurationSeconds; // 초
  final int shortBreakDurationSeconds; // 초
  final int sessionsBeforeLongBreak; // 회
  final SoundType selectedSound;
  final double volume;
  final bool playSoundOnlyDuringFocus;
  final bool autoStartNextSession; // 자동 시작

  TimerSettings({
    this.focusDurationSeconds = DefaultSettings.focusDurationSeconds,
    this.shortBreakDurationSeconds = DefaultSettings.shortBreakDurationSeconds,
    this.sessionsBeforeLongBreak = DefaultSettings.sessionsBeforeLongBreak,
    this.selectedSound = SoundType.none,
    this.volume = DefaultSettings.defaultVolume,
    this.playSoundOnlyDuringFocus = true,
    this.autoStartNextSession = true,
  });

  // 분 단위 getter (편의용)
  int get focusDurationMinutes => focusDurationSeconds ~/ 60;
  int get focusDurationSecondsRemainder => focusDurationSeconds % 60;
  int get shortBreakDurationMinutes => shortBreakDurationSeconds ~/ 60;
  int get shortBreakDurationSecondsRemainder => shortBreakDurationSeconds % 60;

  TimerSettings copyWith({
    int? focusDurationSeconds,
    int? shortBreakDurationSeconds,
    int? sessionsBeforeLongBreak,
    SoundType? selectedSound,
    double? volume,
    bool? playSoundOnlyDuringFocus,
    bool? autoStartNextSession,
  }) {
    return TimerSettings(
      focusDurationSeconds: focusDurationSeconds ?? this.focusDurationSeconds,
      shortBreakDurationSeconds: shortBreakDurationSeconds ?? this.shortBreakDurationSeconds,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      selectedSound: selectedSound ?? this.selectedSound,
      volume: volume ?? this.volume,
      playSoundOnlyDuringFocus:
          playSoundOnlyDuringFocus ?? this.playSoundOnlyDuringFocus,
      autoStartNextSession: autoStartNextSession ?? this.autoStartNextSession,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'focusDurationSeconds': focusDurationSeconds,
      'shortBreakDurationSeconds': shortBreakDurationSeconds,
      'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
      'selectedSound': selectedSound.index,
      'volume': volume,
      'playSoundOnlyDuringFocus': playSoundOnlyDuringFocus,
      'autoStartNextSession': autoStartNextSession,
    };
  }

  factory TimerSettings.fromJson(Map<String, dynamic> json) {
    // 기존 분 단위 설정 마이그레이션
    int focusSeconds = json['focusDurationSeconds'] ??
        (json['focusDuration'] != null ? json['focusDuration'] * 60 : DefaultSettings.focusDurationSeconds);
    int breakSeconds = json['shortBreakDurationSeconds'] ??
        (json['shortBreakDuration'] != null ? json['shortBreakDuration'] * 60 : DefaultSettings.shortBreakDurationSeconds);

    return TimerSettings(
      focusDurationSeconds: focusSeconds,
      shortBreakDurationSeconds: breakSeconds,
      sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] ??
          DefaultSettings.sessionsBeforeLongBreak,
      selectedSound: SoundType.values[json['selectedSound'] ?? 0],
      volume: (json['volume'] ?? DefaultSettings.defaultVolume).toDouble(),
      playSoundOnlyDuringFocus: json['playSoundOnlyDuringFocus'] ?? true,
      autoStartNextSession: json['autoStartNextSession'] ?? true,
    );
  }
}
