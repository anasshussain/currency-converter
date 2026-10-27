import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/currency_avatar.dart';
import '../../../rates/presentation/providers/rates_provider.dart';
import '../../domain/entities/conversion_record.dart';

/// "100 USD → 28,123.50 PKR" row used by the history tab and chart page.
class HistoryTile extends ConsumerWidget {
  const HistoryTile({super.key, required this.record, required this.onTap});

  final ConversionRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final from = ref.watch(currencyProvider(record.from));

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            CurrencyAvatar(currency: from, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Formatters.amount(record.amount)} ${record.from}  →  '
                    '${Formatters.amount(record.result)} ${record.to}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    Formatters.historyStamp(record.createdAt),
                    style: TextStyle(color: p.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.muted),
          ],
        ),
      ),
    );
  }
}
