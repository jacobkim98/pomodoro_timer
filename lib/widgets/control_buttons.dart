import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ControlButtons extends StatelessWidget {
  final TimerState timerState;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onSkip;

  const ControlButtons({
    super.key,
    required this.timerState,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 리셋 버튼
        _buildIconButton(
          icon: Icons.refresh,
          onPressed: onReset,
          tooltip: '리셋',
        ),
        const SizedBox(width: 24),
        // 메인 버튼 (시작/일시정지/재개)
        _buildMainButton(),
        const SizedBox(width: 24),
        // 건너뛰기 버튼
        _buildIconButton(
          icon: Icons.skip_next,
          onPressed: onSkip,
          tooltip: '건너뛰기',
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    IconData icon;
    VoidCallback onPressed;
    String tooltip;

    switch (timerState) {
      case TimerState.idle:
        icon = Icons.play_arrow;
        onPressed = onStart;
        tooltip = '시작';
        break;
      case TimerState.running:
        icon = Icons.pause;
        onPressed = onPause;
        tooltip = '일시정지';
        break;
      case TimerState.paused:
        icon = Icons.play_arrow;
        onPressed = onResume;
        tooltip = '재개';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.large(
        onPressed: onPressed,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: tooltip,
        child: Icon(icon, size: 40),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
      ),
      child: IconButton(
        icon: Icon(icon, size: 28),
        onPressed: onPressed,
        tooltip: tooltip,
        color: AppColors.text,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
