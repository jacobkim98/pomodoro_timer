import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '설정',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final settings = settingsProvider.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 시간 설정 섹션
              _buildSectionTitle('시간 설정'),
              const SizedBox(height: 12),
              _TimeInputCard(
                title: '집중 시간',
                totalSeconds: settings.focusDurationSeconds,
                color: AppColors.focus,
                onChanged: (seconds) {
                  settingsProvider.setFocusDurationSeconds(seconds);
                },
              ),
              const SizedBox(height: 12),
              _TimeInputCard(
                title: '휴식 시간',
                totalSeconds: settings.shortBreakDurationSeconds,
                color: AppColors.shortBreak,
                onChanged: (seconds) {
                  settingsProvider.setShortBreakDurationSeconds(seconds);
                },
              ),
              const SizedBox(height: 24),

              // 세션 설정
              _buildSectionTitle('세션 설정'),
              const SizedBox(height: 12),
              _buildCountSettingCard(
                title: '반복 횟수',
                value: settings.sessionsBeforeLongBreak,
                unit: '회',
                color: AppColors.primary,
                min: 1,
                max: 10,
                onChanged: (value) {
                  settingsProvider.setSessionsBeforeLongBreak(value);
                },
              ),
              const SizedBox(height: 24),

              // 사운드 설정
              _buildSectionTitle('사운드 설정'),
              const SizedBox(height: 12),
              _buildSwitchCard(
                title: '집중 시간에만 배경음 재생',
                subtitle: '휴식 시간에는 배경음을 끕니다',
                value: settings.playSoundOnlyDuringFocus,
                onChanged: (value) {
                  settingsProvider.setPlaySoundOnlyDuringFocus(value);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildCountSettingCard({
    required String title,
    required int value,
    required String unit,
    required Color color,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value$unit',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              onChanged: (newValue) {
                onChanged(newValue.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// 시간 입력 카드 (시/분/초 + 직접 입력)
class _TimeInputCard extends StatefulWidget {
  final String title;
  final int totalSeconds;
  final Color color;
  final Function(int) onChanged;

  const _TimeInputCard({
    required this.title,
    required this.totalSeconds,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_TimeInputCard> createState() => _TimeInputCardState();
}

class _TimeInputCardState extends State<_TimeInputCard> {
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    final hours = widget.totalSeconds ~/ 3600;
    final minutes = (widget.totalSeconds % 3600) ~/ 60;
    final seconds = widget.totalSeconds % 60;

    _hoursController = TextEditingController(text: hours.toString().padLeft(2, '0'));
    _minutesController = TextEditingController(text: minutes.toString().padLeft(2, '0'));
    _secondsController = TextEditingController(text: seconds.toString().padLeft(2, '0'));
  }

  @override
  void didUpdateWidget(_TimeInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalSeconds != widget.totalSeconds) {
      final hours = widget.totalSeconds ~/ 3600;
      final minutes = (widget.totalSeconds % 3600) ~/ 60;
      final seconds = widget.totalSeconds % 60;

      _hoursController.text = hours.toString().padLeft(2, '0');
      _minutesController.text = minutes.toString().padLeft(2, '0');
      _secondsController.text = seconds.toString().padLeft(2, '0');
    }
  }

  void _onTimeChanged() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;

    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    if (totalSeconds > 0) {
      widget.onChanged(totalSeconds);
    }
  }

  String _formatTime() {
    final hours = widget.totalSeconds ~/ 3600;
    final minutes = (widget.totalSeconds % 3600) ~/ 60;
    final seconds = widget.totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = widget.totalSeconds ~/ 3600;
    final minutes = (widget.totalSeconds % 3600) ~/ 60;
    final seconds = widget.totalSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatTime(),
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 시간 입력
              Expanded(
                child: _buildTimeUnit(
                  label: '시간',
                  value: hours,
                  max: 23,
                  controller: _hoursController,
                ),
              ),
              const SizedBox(width: 8),
              // 분 입력
              Expanded(
                child: _buildTimeUnit(
                  label: '분',
                  value: minutes,
                  max: 59,
                  controller: _minutesController,
                ),
              ),
              const SizedBox(width: 8),
              // 초 입력
              Expanded(
                child: _buildTimeUnit(
                  label: '초',
                  value: seconds,
                  max: 59,
                  controller: _secondsController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit({
    required String label,
    required int value,
    required int max,
    required TextEditingController controller,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 감소 버튼
            _buildAdjustButton(
              icon: Icons.remove,
              onPressed: value > 0
                  ? () {
                      controller.text = (value - 1).toString().padLeft(2, '0');
                      _onTimeChanged();
                    }
                  : null,
            ),
            const SizedBox(width: 4),
            // 직접 입력 필드
            SizedBox(
              width: 45,
              height: 40,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (text) {
                  final val = int.tryParse(text) ?? 0;
                  if (val > max) {
                    controller.text = max.toString().padLeft(2, '0');
                  }
                  _onTimeChanged();
                },
                onTap: () {
                  controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: controller.text.length,
                  );
                },
              ),
            ),
            const SizedBox(width: 4),
            // 증가 버튼
            _buildAdjustButton(
              icon: Icons.add,
              onPressed: value < max
                  ? () {
                      controller.text = (value + 1).toString().padLeft(2, '0');
                      _onTimeChanged();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdjustButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null
          ? widget.color.withValues(alpha: 0.2)
          : Colors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onPressed != null ? widget.color : Colors.grey,
            size: 16,
          ),
        ),
      ),
    );
  }
}
