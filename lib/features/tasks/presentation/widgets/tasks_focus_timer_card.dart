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
    AppThemeColors colors,
  ) {
    final isSelected = timerTotalSeconds == seconds;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isTimerRunning ? null : () => onResetTimer(seconds),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryPurple
                : (colors.isDark
                      ? const Color(0xFF26262B)
                      : const Color(0xFFF0F1F5)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryPurple : colors.borderColor,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (colors.isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomPill(BuildContext context, AppThemeColors colors) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isTimerRunning ? null : onCustomTimerTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.isDark
                ? const Color(0xFF26262B)
                : const Color(0xFFF0F1F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.borderColor, width: 1.2),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 14, color: AppColors.primaryPurple),
              SizedBox(width: 4),
              Text(
                'Custom',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTimerRunning ? AppColors.primaryPurple : borderColor,
          width: isTimerRunning ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          if (isTimerRunning)
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 1,
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(
                        isTimerRunning ? 0.25 : 0.15,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (isTimerRunning)
                          BoxShadow(
                            color: AppColors.primaryPurple.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: -1,
                          ),
                      ],
                    ),
                    child: Icon(
                      isTimerRunning
                          ? Icons.alarm_on_rounded
                          : Icons.timer_outlined,
                      color: AppColors.primaryPurple,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
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
                    _buildTimerPresetPill(context, '15m', 900, colors),
                    _buildTimerPresetPill(context, '25m', 1500, colors),
                    _buildTimerPresetPill(context, '30m', 1800, colors),
                    _buildTimerPresetPill(context, '45m', 2700, colors),
                    if (![900, 1500, 1800, 2700].contains(timerTotalSeconds))
                      _buildTimerPresetPill(
                        context,
                        '${timerTotalSeconds ~/ 60}m',
                        timerTotalSeconds,
                        colors,
                      ),
                    _buildCustomPill(context, colors),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatTime(timerRemainingSeconds),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: isTimerRunning
                              ? const Color(0xFFFF4081)
                              : AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 90,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: isDark
                                ? const Color(0xFF2C2C38)
                                : const Color(0xFFE2E4EB),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isTimerRunning
                                  ? const Color(0xFFFF4081)
                                  : AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onResetTimer(),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF26262B)
                              : const Color(0xFFF0F1F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colors.borderColor,
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: subtextColor,
                        ),
                      ),
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
