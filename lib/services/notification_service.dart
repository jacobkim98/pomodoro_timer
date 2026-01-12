import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // 알림 채널 생성 - 팝업용 (최고 우선순위)
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      // 팝업 알림 채널
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          'pomodoro_popup_channel',
          '포모도로 팝업 알림',
          description: '포모도로 타이머 팝업 알림',
          importance: Importance.max,
          playSound: false,
          enableVibration: true,
        ),
      );

      // 진행 상태 알림 채널
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          'pomodoro_status_channel',
          '포모도로 상태',
          description: '포모도로 타이머 진행 상태',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
      );
    }
  }

  // 권한 요청
  Future<bool> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  // 화면 켜진 상태 유지 (타이머 실행 중)
  Future<void> enableWakelock() async {
    await WakelockPlus.enable();
  }

  // 화면 꺼짐 허용
  Future<void> disableWakelock() async {
    await WakelockPlus.disable();
  }

  // 집중 시작 알림 (조용한 상태 알림)
  Future<void> showFocusStartNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'pomodoro_status_channel',
        '포모도로 상태',
        channelDescription: '포모도로 타이머 진행 상태',
        importance: Importance.low,
        priority: Priority.low,
        playSound: false,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        0,
        '집중 중',
        '집중 시간이 진행 중입니다',
        details,
      );
    } catch (e) {
      // 알림 실패 시 무시
    }
  }

  // 집중 종료 알림 (휴식 시작) - 팝업
  Future<void> showFocusEndNotification() async {
    // 진행 중 알림 취소
    try {
      await _notifications.cancel(0);
    } catch (e) {
      // 무시
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'pomodoro_popup_channel',
        '포모도로 팝업 알림',
        channelDescription: '포모도로 타이머 팝업 알림',
        importance: Importance.max,
        priority: Priority.max,
        playSound: false,
        enableVibration: true,
        fullScreenIntent: true,  // 화면이 꺼져있어도 팝업
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        1,
        '집중 완료!',
        '수고하셨습니다. 휴식 시간입니다.',
        details,
      );
    } catch (e) {
      // 알림 실패 시 무시
    }
  }

  // 휴식 종료 알림 (집중 시작) - 팝업
  Future<void> showBreakEndNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'pomodoro_popup_channel',
        '포모도로 팝업 알림',
        channelDescription: '포모도로 타이머 팝업 알림',
        importance: Importance.max,
        priority: Priority.max,
        playSound: false,
        enableVibration: true,
        fullScreenIntent: true,  // 화면이 꺼져있어도 팝업
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        2,
        '휴식 끝!',
        '다시 집중할 시간입니다!',
        details,
      );
    } catch (e) {
      // 알림 실패 시 무시
    }
  }

  // 전체 사이클 완료 알림 - 팝업
  Future<void> showCycleCompleteNotification() async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'pomodoro_popup_channel',
        '포모도로 팝업 알림',
        channelDescription: '포모도로 타이머 팝업 알림',
        importance: Importance.max,
        priority: Priority.max,
        playSound: false,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        3,
        '사이클 완료!',
        '모든 세션을 완료했습니다. 수고하셨습니다!',
        details,
      );
    } catch (e) {
      // 알림 실패 시 무시
    }
  }

  // 모든 알림 취소
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      // 무시
    }
  }
}
