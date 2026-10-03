import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/theme/app_theme_colors.dart';

class TasksFocusTimerCard extends StatelessWidget {
  final int timerTotalSeconds;
  final int timerRemainingSeconds;
  final bool isTimerRunning;
  final VoidCallback onStartTimer;
  final VoidCallback onPauseTimer;
  final Function([int? seconds]) onResetTimer;
  final VoidCallback onCloseCard;
  final VoidCallback onCustomTimerTap;
  final String Function(int seconds) formatTime;

  const TasksFocusTimerCard({
    super.key,
    required this.timerTotalSeconds,
    required this.timerRemainingSeconds,
    required this.isTimerRunning,
    required this.onStartTimer,
    required this.onPauseTimer,
    required this.onResetTimer,
    required this.onCloseCard,
    required this.onCustomTimerTap,
    required this.formatTime,
  });

  Widget _buildTimerPresetPill(
    BuildContext context,
    String label,
    int seconds,
    bool isDark,
  ) {
    final isSelected = timerTotalSeconds == seconds;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: isTimerRunning
          ? null
          : (selected) {
              if (selected) {
                onResetTimer(seconds);
              }
            },
      selectedColor: AppColors.primaryPurple,
      backgroundColor: isDark
          ? const Color(0xFF262632)
          : const Color(0xFFEAEAEE),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white70 : Colors.black87),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = colors.isDark;
    final textColor = colors.textColor;
    final subtextColor = colors.secondaryTextColor;
    final borderColor = colors.borderColor;

    final progress = timerTotalSeconds > 0
        ? (timerTotalSeconds - timerRemainingSeconds) / timerTotalSeconds
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E28) : const Color(0xFFF3F4F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTimerRunning ? AppColors.primaryPurple : borderColor,
          width: isTimerRunning ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.timer_outlined,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Focus Timer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isTimerRunning
                            ? 'Focus session in progress...'
                            : 'Set a focus goal and work uninterrupted.',
                        style: TextStyle(fontSize: 12, color: subtextColor),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: subtextColor,
                onPressed: onCloseCard,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTimerPresetPill(context, '15m', 900, isDark),
                    _buildTimerPresetPill(context, '25m', 1500, isDark),
                    _buildTimerPresetPill(context, '30m', 1800, isDark),
                    _buildTimerPresetPill(context, '45m', 2700, isDark),
                    if (![900, 1500, 1800, 2700].contains(timerTotalSeconds))
                      _buildTimerPresetPill(
                        context,
                        '${timerTotalSeconds ~/ 60}m',
                        timerTotalSeconds,
                        isDark,
                      ),
                    ActionChip(
                      avatar: const Icon(
                        Icons.add_rounded,
                        size: 14,
                        color: AppColors.primaryPurple,
                      ),
                      label: const Text('Custom'),
                      onPressed: isTimerRunning ? null : onCustomTimerTap,
                      backgroundColor: isDark
                          ? const Color(0xFF262632)
                          : const Color(0xFFEAEAEE),
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatTime(timerRemainingSeconds),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: isDark
                                ? const Color(0xFF2C2C38)
                                : const Color(0xFFE2E4EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    onPressed: isTimerRunning ? onPauseTimer : onStartTimer,
                    icon: Icon(
                      isTimerRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      isTimerRunning ? 'Pause' : 'Start Focus',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTimerRunning
                          ? const Color(0xFFFF4081)
                          : AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => onResetTimer(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
