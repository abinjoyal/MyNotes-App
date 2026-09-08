import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';

class NotesTagListWidget extends StatelessWidget {
  final List<String> availableTags;
  final String? selectedTag;
  final ValueChanged<String?> onTagSelect;
  final bool isDark;

  const NotesTagListWidget({
    super.key,
    required this.availableTags,
    required this.selectedTag,
    required this.onTagSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (availableTags.isEmpty) return const SizedBox.shrink();

    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.darkText;
    final inputBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8FA);
    final borderColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAEAEE);

    return Column(
      children: [
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onTagSelect(null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    gradient: selectedTag == null
                        ? const LinearGradient(
                            colors: [AppColors.primaryPurple, AppColors.primaryPink],
                          )
                        : null,
                    color: selectedTag == null
                        ? null
                        : inputBg.withOpacity(isDark ? 0.6 : 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedTag == null
                          ? Colors.transparent
                          : borderColor.withOpacity(0.3),
                    ),
                    boxShadow: selectedTag == null
                        ? [
                            BoxShadow(
                              color: AppColors.primaryPink.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    'All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selectedTag == null ? Colors.white : textColor,
                    ),
                  ),
                ),
              ),
              ...availableTags.map((tag) {
                final isSelected = selectedTag == tag;
                return GestureDetector(
                  onTap: () => onTagSelect(isSelected ? null : tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppColors.primaryPurple, AppColors.primaryPink],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : inputBg.withOpacity(isDark ? 0.6 : 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : borderColor.withOpacity(0.3),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryPink.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : textColor,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
