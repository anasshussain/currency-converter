import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../converter/presentation/providers/converter_provider.dart';
import '../../../shell/presentation/providers/shell_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/history_tile.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final p = context.palette;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  CupertinoIcons.delete,
                  color: AppColors.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Clear history?',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'All saved conversions will be removed. '
                    'This cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.muted, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) await ref.read(historyProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final records = ref.watch(historyProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          PageHeader(
            title: 'Conversion History',
            trailing: records.isEmpty
                ? null
                : IconButton(
              tooltip: 'Clear history',
              onPressed: () => _confirmClear(context, ref),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.10),
              ),
              icon: const Icon(
                CupertinoIcons.delete,
                color: AppColors.danger,
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: records.isEmpty
                  ? const EmptyState(
                key: ValueKey('empty'),
                icon: Icons.history_rounded,
                title: 'No conversions yet',
                subtitle: 'Tap Convert on the home screen to save a '
                    'conversion here.',
              )
                  : ListView.builder(
                key: const ValueKey('list'),
                physics: const BouncingScrollPhysics(),
                // Bottom padding keeps content clear of the glass navbar.
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                itemCount: records.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _SummaryRow(count: records.length);
                  }

                  final record = records[i - 1];
                  return _EntranceAnimation(
                    key: ValueKey('anim_${record.id}'),
                    index: i - 1,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: ValueKey(record.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          HapticFeedback.lightImpact();
                          ref
                              .read(historyProvider.notifier)
                              .remove(record.id);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(
                            color:
                            AppColors.danger.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            CupertinoIcons.delete,
                            color: AppColors.danger,
                          ),
                        ),
                        child: AppCard(
                          radius: 22,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          child: HistoryTile(
                            record: record,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(converterProvider.notifier)
                                  .apply(
                                from: record.from,
                                to: record.to,
                                amount: record.amount,
                              );
                              ref
                                  .read(shellIndexProvider.notifier)
                                  .state = 0;
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "12 conversions" chip + swipe hint above the list.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: p.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  count == 1 ? '1 conversion' : '$count conversions',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Icon(Icons.swipe_left_rounded, size: 15, color: p.muted),
          const SizedBox(width: 5),
          Text(
            'Swipe to delete',
            style: TextStyle(color: p.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Fade + slide-up, slightly staggered by item index (capped).
class _EntranceAnimation extends StatelessWidget {
  const _EntranceAnimation({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 8)) * 40;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 16),
          child: child,
        ),
      ),
      child: child,
    );
  }
}