import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/currency_avatar.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../converter/presentation/providers/converter_provider.dart';
import '../../../currencies/presentation/pages/currency_picker_page.dart';
import '../providers/rates_provider.dart';
import 'rate_detail_page.dart';

class RatesPage extends ConsumerStatefulWidget {
  const RatesPage({super.key});

  @override
  ConsumerState<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends ConsumerState<RatesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final base = ref.watch(converterProvider.select((s) => s.from));
    final ratesAsync = ref.watch(ratesProvider);
    final currencies = ref.watch(availableCurrenciesProvider);

    final query = _query.trim().toLowerCase();
    final items = currencies.where((c) {
      if (c.code == base) return false;
      if (query.isEmpty) return true;
      return c.code.toLowerCase().contains(query) ||
          c.name.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) {
        if (a.isMajor != b.isMajor) return a.isMajor ? -1 : 1;
        return a.code.compareTo(b.code);
      });

    return SafeArea(
      child: Column(
        children: [
          PageHeader(
            title: 'Live Rates',
            subtitle: '${items.length} currencies',
            trailing: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final code = await pickCurrency(context, selected: base);
                if (code != null) {
                  ref.read(converterProvider.notifier).setFrom(code);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Base: $base',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: AppSearchField(onChanged: (v) => setState(() => _query = v)),
          ),
          Expanded(
            child: ratesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.read(ratesProvider.notifier).refresh(),
              ),
              data: (rates) => RefreshIndicator(
                onRefresh: () => ref.read(ratesProvider.notifier).refresh(),
                child: items.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No currencies found',
                            subtitle: 'Try a different name or code.',
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: p.border),
                        itemBuilder: (_, i) {
                          final currency = items[i];
                          final rate = rates.rate(base, currency.code);

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RateDetailPage(
                                  from: base,
                                  to: currency.code,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  CurrencyAvatar(currency: currency, size: 42),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currency.code,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          currency.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: p.muted,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    rate == null ? '--' : Formatters.rate(rate),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: p.muted),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
