import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/change_badge.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/live_relative_time.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../currencies/presentation/pages/currency_picker_page.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../rates/domain/entities/currency_pair.dart';
import '../../../rates/presentation/pages/rate_detail_page.dart';
import '../../../rates/presentation/providers/rates_provider.dart';
import '../providers/converter_provider.dart';
import 'currency_box.dart';

class ConverterCard extends ConsumerStatefulWidget {
  const ConverterCard({super.key});

  @override
  ConsumerState<ConverterCard> createState() => _ConverterCardState();
}

class _ConverterCardState extends ConsumerState<ConverterCard> {
  late final TextEditingController _controller;

  /// Digits with at most one decimal point.
  static final _amountFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) =>
        RegExp(r'^\d{0,12}\.?\d{0,6}$').hasMatch(newValue.text)
            ? newValue
            : oldValue,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(converterProvider).amountText,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool isFrom}) async {
    final input = ref.read(converterProvider);
    final code = await pickCurrency(
      context,
      selected: isFrom ? input.from : input.to,
    );
    if (code == null) return;
    final notifier = ref.read(converterProvider.notifier);
    isFrom ? notifier.setFrom(code) : notifier.setTo(code);
  }

  Future<void> _convert() async {
    FocusScope.of(context).unfocus();
    final input = ref.read(converterProvider);
    final result = ref.read(conversionResultProvider);
    if (result == null || input.amount <= 0) return;

    await ref.read(historyProvider.notifier).add(
          from: input.from,
          to: input.to,
          amount: input.amount,
          result: result,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${Formatters.amount(input.amount)} ${input.from} = '
            '${Formatters.amount(result)} ${input.to}  ·  saved to history',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final input = ref.watch(converterProvider);
    final ratesAsync = ref.watch(ratesProvider);
    final result = ref.watch(conversionResultProvider);
    final from = ref.watch(currencyProvider(input.from));
    final to = ref.watch(currencyProvider(input.to));
    final CurrencyPair pair = (from: input.from, to: input.to);
    final rate = ref.watch(pairRateProvider(pair));
    final change = ref.watch(dailyChangeProvider(pair)).valueOrNull;

    // Keep the text field in sync when the amount is changed from elsewhere
    // (e.g. restoring a conversion from history).
    ref.listen<ConverterState>(converterProvider, (_, next) {
      if (_controller.text != next.amountText) {
        _controller.value = TextEditingValue(
          text: next.amountText,
          selection: TextSelection.collapsed(offset: next.amountText.length),
        );
      }
    });

    if (ratesAsync.hasError && !ratesAsync.hasValue) {
      return AppCard(
        child: ErrorState(
          message: ratesAsync.error.toString(),
          onRetry: () => ref.read(ratesProvider.notifier).refresh(),
        ),
      );
    }

    final rates = ratesAsync.valueOrNull;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  CurrencyBox(
                    label: 'From',
                    currency: from,
                    onCurrencyTap: () => _pick(isFrom: true),
                    value: TextField(
                      controller: _controller,
                      onChanged: ref.read(converterProvider.notifier).setAmount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [_amountFormatter],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(color: p.muted),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CurrencyBox(
                    label: 'To',
                    currency: to,
                    onCurrencyTap: () => _pick(isFrom: false),
                    value: Align(
                      alignment: Alignment.centerRight,
                      child: result == null
                          ? const SkeletonBox(width: 110, height: 30)
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                Formatters.amount(result),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              _SwapButton(onTap: ref.read(converterProvider.notifier).swap),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RateDetailPage(from: input.from, to: input.to),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rate == null
                              ? '1 ${input.from} = --'
                              : '1 ${input.from} = ${Formatters.rate(rate)} ${input.to}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ChangeBadge(change: change),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (rates != null)
                    Row(
                      children: [
                        LiveRelativeTime(
                          time: rates.fetchedAt,
                          style: TextStyle(color: p.muted, fontSize: 13),
                        ),
                        if (rates.isStale)
                          Text(
                            '  ·  offline',
                            style: TextStyle(
                              color: p.muted.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        if (ratesAsync.isLoading) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GradientButton(
            label: 'Convert',
            icon: Icons.swap_horiz_rounded,
            onPressed: result == null ? null : _convert,
          ),
        ],
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface,
      shape: CircleBorder(side: BorderSide(color: p.border, width: 2)),
      elevation: 2,
      shadowColor: p.shadow,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 46,
          height: 46,
          child: Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
        ),
      ),
    );
  }
}
