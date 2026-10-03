import 'package:flutter/material.dart';

class SettingCardContainer extends StatelessWidget {
  final Color cardBg;
  final Color borderColor;
  final List<Widget> children;

  const SettingCardContainer({
    super.key,
    required this.cardBg,
    required this.borderColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
