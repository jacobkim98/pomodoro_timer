import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SoundSelector extends StatelessWidget {
  final SoundType selectedSound;
  final double volume;
  final bool isSoundPlaying;
  final Function(SoundType) onSoundChanged;
  final Function(double) onVolumeChanged;
  final VoidCallback onToggleSound;

  const SoundSelector({
    super.key,
    required this.selectedSound,
    required this.volume,
    required this.isSoundPlaying,
    required this.onSoundChanged,
    required this.onVolumeChanged,
    required this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 사운드 선택 드롭다운
          DropdownButton<SoundType>(
            value: selectedSound,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
            ),
            underline: Container(),
            items: availableSounds.map((sound) {
              return DropdownMenuItem<SoundType>(
                value: sound.type,
                child: Row(
                  children: [
                    Icon(
                      sound.icon,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(sound.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onSoundChanged(value);
              }
            },
          ),
          // 볼륨 슬라이더 및 재생/정지 버튼
          if (selectedSound != SoundType.none) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  volume == 0 ? Icons.volume_off : Icons.volume_up,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                Expanded(
                  child: Slider(
                    value: volume,
                    min: 0,
                    max: 1,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withValues(alpha: 0.3),
                    onChanged: onVolumeChanged,
                  ),
                ),
                // 배경음 재생/정지 버튼
                IconButton(
                  onPressed: onToggleSound,
                  icon: Icon(
                    isSoundPlaying ? Icons.stop_circle : Icons.play_circle,
                    color: isSoundPlaying ? AppColors.focus : AppColors.primary,
                    size: 32,
                  ),
                  tooltip: isSoundPlaying ? '배경음 끄기' : '배경음 켜기',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
