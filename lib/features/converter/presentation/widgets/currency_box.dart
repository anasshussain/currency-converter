import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/currency_avatar.dart';
import '../../../currencies/domain/entities/currency.dart';

/// One half of the converter card: flag, label, code selector and a value.
class CurrencyBox extends StatelessWidget {
  const CurrencyBox({
    super.key,
    required this.label,
    required this.currency,
    required this.onCurrencyTap,
    required this.value,
  });

  final String label;
  final Currency currency;
  final VoidCallback onCurrencyTap;

  /// Amount editor (From) or result text (To).
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onCurrencyTap,
              child: Row(
                children: [
                  CurrencyAvatar(currency: currency, size: 52),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: TextStyle(color: p.muted, fontSize: 13)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currency.code,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded, color: p.text),
                          ],
                        ),
                        Text(
                          currency.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 5, child: value),
        ],
      ),
    );
  }
}
