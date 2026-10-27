import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../utils/formatters.dart';

/// "▲ 0.24%" in green, "▼ 0.24%" in red.
class ChangeBadge extends StatelessWidget {
  const ChangeBadge({super.key, required this.change, this.fontSize = 14});

  final double? change;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final value = change;
    if (value == null) return const SizedBox.shrink();

    final up = value >= 0;
    final color = up ? AppColors.success : AppColors.danger;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
          color: color,
          size: fontSize * 1.8,
        ),
        Text(
          Formatters.percent(value),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
