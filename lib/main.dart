import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/timer_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 세로 모드 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Provider 초기화
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  final timerProvider = TimerProvider();
  await timerProvider.init();
  timerProvider.applySettings(settingsProvider.settings);

  runApp(PomodoroApp(
    settingsProvider: settingsProvider,
    timerProvider: timerProvider,
  ));
}

class PomodoroApp extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final TimerProvider timerProvider;

  const PomodoroApp({
    super.key,
    required this.settingsProvider,
    required this.timerProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: timerProvider),
      ],
      child: MaterialApp(
        title: '포모도로',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
            onPrimary: Colors.white,
            onSurface: AppColors.text,
          ),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
