import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/control_buttons.dart';
import '../widgets/sound_selector.dart';
import '../utils/constants.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '포모도로',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart, color: AppColors.text),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
            tooltip: '통계',
          ),
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.text),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              if (mounted) {
                final settingsProvider = context.read<SettingsProvider>();
                final timerProvider = context.read<TimerProvider>();
                timerProvider.applySettings(settingsProvider.settings);
              }
            },
            tooltip: '설정',
          ),
        ],
      ),
      body: Consumer2<TimerProvider, SettingsProvider>(
        builder: (context, timerProvider, settingsProvider, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  // 타이머 디스플레이
                  TimerDisplay(
                    timeString: timerProvider.timeString,
                    progress: timerProvider.progress,
                    sessionType: timerProvider.sessionType,
                    currentSession: timerProvider.currentSession,
                    totalSessions: timerProvider.totalSessions,
                  ),
                  const Spacer(flex: 1),
                  // 컨트롤 버튼
                  ControlButtons(
                    timerState: timerProvider.state,
                    onStart: () => timerProvider.start(settingsProvider.settings),
                    onPause: timerProvider.pause,
                    onResume: () => timerProvider.resume(settingsProvider.settings),
                    onReset: () => timerProvider.reset(settingsProvider.settings),
                    onSkip: () => timerProvider.skip(settingsProvider.settings),
                  ),
                  const Spacer(flex: 1),
                  // 사운드 선택기
                  SoundSelector(
                    selectedSound: settingsProvider.settings.selectedSound,
                    volume: settingsProvider.settings.volume,
                    isSoundPlaying: timerProvider.isSoundPlaying,
                    onSoundChanged: (sound) {
                      settingsProvider.setSelectedSound(sound);
                      timerProvider.changeSound(sound, settingsProvider.settings.volume);
                    },
                    onVolumeChanged: (volume) {
                      settingsProvider.setVolume(volume);
                      timerProvider.changeVolume(volume);
                    },
                    onToggleSound: () {
                      timerProvider.toggleBackgroundSound(settingsProvider.settings);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
