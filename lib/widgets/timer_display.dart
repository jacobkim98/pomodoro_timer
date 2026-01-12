import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../utils/constants.dart';

class TimerDisplay extends StatelessWidget {
  final String timeString;
  final double progress;
  final SessionType sessionType;
  final int currentSession;
  final int totalSessions;

  const TimerDisplay({
    super.key,
    required this.timeString,
    required this.progress,
    required this.sessionType,
    required this.currentSession,
    required this.totalSessions,
  });

  Color get _progressColor {
    switch (sessionType) {
      case SessionType.focus:
        return AppColors.focus;
      case SessionType.shortBreak:
        return AppColors.shortBreak;
    }
  }

  String get _sessionTypeText {
    switch (sessionType) {
      case SessionType.focus:
        return '집중';
      case SessionType.shortBreak:
        return '휴식';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 세션 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _progressColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🍅 ',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '$currentSession / $totalSessions',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // 원형 타이머
        CircularPercentIndicator(
          radius: 140,
          lineWidth: 12,
          percent: progress.clamp(0.0, 1.0),
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeString,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _progressColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _sessionTypeText,
                  style: TextStyle(
                    fontSize: 16,
                    color: _progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          progressColor: _progressColor,
          backgroundColor: _progressColor.withValues(alpha: 0.2),
          circularStrokeCap: CircularStrokeCap.round,
          animation: false,
        ),
      ],
    );
  }
}
