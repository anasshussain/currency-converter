import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/change_badge.dart';
import '../../../../core/widgets/live_relative_time.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../alerts/presentation/widgets/add_alert_sheet.dart';
import '../../../converter/presentation/providers/converter_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../history/domain/entities/conversion_record.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../history/presentation/widgets/history_tile.dart';
import '../../../shell/presentation/providers/shell_provider.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/entities/rate_point.dart';
import '../providers/rates_provider.dart';
import '../widgets/rate_chart.dart';

class RateDetailPage extends ConsumerStatefulWidget {
  const RateDetailPage({super.key, required this.from, required this.to});

  final String from;
  final String to;

  @override
  ConsumerState<RateDetailPage> createState() => _RateDetailPageState();
}

class _RateDetailPageState extends ConsumerState<RateDetailPage> {
  ChartRange _range = ChartRange.week;

  ChartQuery get _query =>
      (from: widget.from, to: widget.to, range: _range);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final CurrencyPair pair = (from: widget.from, to: widget.to);
    final rate = ref.watch(pairRateProvider(pair));
    final rates = ref.watch(ratesProvider).valueOrNull;
    final history = ref.watch(rateHistoryProvider(_query));
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(widget.to);

    final allRecords = ref.watch(historyProvider);
    final pairRecords = allRecords
        .where((r) => r.from == widget.from && r.to == widget.to)
        .toList();
    final List<ConversionRecord> recent =
        (pairRecords.isNotEmpty ? pairRecords : allRecords).take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.from} to ${widget.to}'),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () =>
                ref.read(favoritesProvider.notifier).toggle(widget.to),
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFavorite ? const Color(0xFFF5B400) : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rate == null
                      ? '1 ${widget.from} = --'
                      : '1 ${widget.from} = ${Formatters.rate(rate)} ${widget.to}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              ChangeBadge(change: _rangeChange(history.valueOrNull)),
            ],
          ),
          const SizedBox(height: 4),
          if (rates != null)
            LiveRelativeTime(
              time: rates.fetchedAt,
              style: TextStyle(color: p.muted, fontSize: 13),
            ),
          const SizedBox(height: 20),
          _RangeSelector(
            selected: _range,
            onChanged: (range) => setState(() => _range = range),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: history.when(
              data: (points) => RateChart(points: points),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(rateHistoryProvider(_query)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _HighLowCard(points: history.valueOrNull, range: _range),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => showAddAlertSheet(
              context,
              from: widget.from,
              to: widget.to,
            ),
            icon: const Icon(Icons.notifications_none_rounded),
            label: const Text('Set rate alert'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (recent.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text(
              'Recent Conversions',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            AppCard(
              radius: 22,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < recent.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: p.border),
                    HistoryTile(
                      record: recent[i],
                      onTap: () {
                        ref.read(converterProvider.notifier).apply(
                              from: recent[i].from,
                              to: recent[i].to,
                              amount: recent[i].amount,
                            );
                        ref.read(shellIndexProvider.notifier).state = 0;
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Change between the first and last point of the visible range.
  double? _rangeChange(List<RatePoint>? points) {
    if (points == null || points.length < 2 || points.first.value == 0) {
      return null;
    }
    return (points.last.value / points.first.value - 1) * 100;
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onChanged});

  final ChartRange selected;
  final ValueChanged<ChartRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final range in ChartRange.values)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: range == selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                range.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: range == selected ? Colors.white : p.muted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HighLowCard extends StatelessWidget {
  const _HighLowCard({required this.points, required this.range});

  final List<RatePoint>? points;
  final ChartRange range;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final data = points;

    String highest = '--';
    String lowest = '--';
    if (data != null && data.isNotEmpty) {
      final values = data.map((e) => e.value);
      highest = Formatters.rate(values.reduce((a, b) => a > b ? a : b));
      lowest = Formatters.rate(values.reduce((a, b) => a < b ? a : b));
    }

    Widget cell(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: p.muted, fontSize: 12)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          cell('Highest (${range.label})', highest),
          Container(width: 1, height: 40, color: p.border),
          const SizedBox(width: 18),
          cell('Lowest (${range.label})', lowest),
        ],
      ),
    );
  }
}
