# Pomodoro Timer

집중력 향상을 위한 포모도로 기법 기반 타이머 앱입니다.

## 주요 기능

- **맞춤형 타이머 설정**: 집중 시간, 휴식 시간을 시/분/초 단위로 자유롭게 설정
- **반복 세션**: 원하는 횟수만큼 집중-휴식 사이클 반복
- **배경음 지원**: 집중할 때 도움이 되는 다양한 배경음 제공
  - 빗소리, 파도소리, 새소리, 벽난로, 피아노, 화이트노이즈
- **배경음 독립 제어**: 타이머와 별개로 배경음만 켜고 끌 수 있음
- **통계 기능**: 일별/주별/월별 집중 시간 및 완료 세션 수 확인
- **알림**: 집중/휴식 전환 시 알림음으로 알려줌
- **화면 꺼짐 방지**: 타이머 실행 중 화면이 꺼지지 않음

## 사용 기술

| 분류 | 기술 |
|------|------|
| Framework | Flutter |
| 상태 관리 | Provider |
| 오디오 | just_audio |
| 로컬 저장소 | SharedPreferences, SQLite |
| 알림 | flutter_local_notifications |
| 기타 | wakelock_plus, percent_indicator |

## 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## 빌드

```bash
# Android APK 빌드
flutter build apk

# Android App Bundle 빌드
flutter build appbundle
```

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── focus_record.dart
│   └── timer_settings.dart
├── providers/                # 상태 관리
│   ├── settings_provider.dart
│   └── timer_provider.dart
├── screens/                  # 화면
│   ├── home_screen.dart
│   ├── settings_screen.dart
│   └── stats_screen.dart
├── services/                 # 서비스
│   ├── audio_service.dart
│   ├── database_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
├── utils/                    # 유틸리티
│   └── constants.dart
└── widgets/                  # 위젯
    ├── control_buttons.dart
    ├── sound_selector.dart
    └── timer_display.dart
```

## 라이선스

MIT License
