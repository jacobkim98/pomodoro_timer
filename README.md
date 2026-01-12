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

## 요구 사항

- Flutter SDK 3.0 이상
- Dart 3.0 이상
- Android Studio 또는 VS Code (Flutter 플러그인 설치)

### Android
- Android SDK 21 (Android 5.0) 이상
- Android 에뮬레이터 또는 실제 기기

### iOS
- macOS 환경 필수
- Xcode 14 이상
- iOS 12.0 이상
- iOS 시뮬레이터 또는 실제 기기

## 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/jacobkim98/pomodoro_timer.git
cd pomodoro_timer

# 의존성 설치
flutter pub get
```

### Android 실행

```bash
# 연결된 기기/에뮬레이터 확인
flutter devices

# Android 에뮬레이터 실행 (Android Studio에서 AVD Manager로 생성)
flutter emulators --launch <emulator_id>

# 앱 실행
flutter run

# 특정 Android 기기에서 실행
flutter run -d <device_id>
```

### iOS 실행 (macOS 전용)

```bash
# iOS 시뮬레이터 실행
open -a Simulator

# 앱 실행
flutter run

# 특정 iOS 시뮬레이터에서 실행
flutter run -d "iPhone 15 Pro"

# 실제 iOS 기기에서 실행 (개발자 계정 필요)
flutter run -d <device_id>
```

> **Note**: iOS 실제 기기에서 실행하려면 Apple Developer 계정이 필요하며, Xcode에서 Signing & Capabilities 설정이 필요합니다.

## 빌드

### Android

```bash
# Debug APK 빌드
flutter build apk --debug

# Release APK 빌드
flutter build apk --release

# Android App Bundle 빌드 (Play Store 배포용)
flutter build appbundle --release
```

빌드된 파일 위치:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS 전용)

```bash
# iOS 앱 빌드
flutter build ios --release

# IPA 파일 생성 (배포용)
flutter build ipa --release
```

> **Note**: iOS 배포를 위해서는 Apple Developer Program 가입이 필요합니다.

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
