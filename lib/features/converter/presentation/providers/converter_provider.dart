import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../rates/presentation/providers/rates_provider.dart';

class ConverterState extends Equatable {
  const ConverterState({
    required this.from,
    required this.to,
    required this.amountText,
  });

  final String from;
  final String to;

  /// Raw text of the input field, so typing "12." does not get rewritten.
  final String amountText;

  double get amount => Formatters.parseAmount(amountText) ?? 0;

  ConverterState copyWith({String? from, String? to, String? amountText}) {
    return ConverterState(
      from: from ?? this.from,
      to: to ?? this.to,
      amountText: amountText ?? this.amountText,
    );
  }

  @override
  List<Object?> get props => [from, to, amountText];
}

class ConverterNotifier extends Notifier<ConverterState> {
  @override
  ConverterState build() {
    final last = ref.read(settingsRepositoryProvider).getLastPair();
    return ConverterState(
      from: last?.from ?? AppConstants.defaultFrom,
      to: last?.to ?? AppConstants.defaultTo,
      amountText: AppConstants.defaultAmount,
    );
  }

  void setAmount(String text) => state = state.copyWith(amountText: text);

  void setFrom(String code) {
    if (code == state.to) return swap();
    _setPair(state.copyWith(from: code));
  }

  void setTo(String code) {
    if (code == state.from) return swap();
    _setPair(state.copyWith(to: code));
  }

  void swap() {
    _setPair(state.copyWith(from: state.to, to: state.from));
  }

  /// Restores a pair (and optionally an amount), e.g. from the history list.
  void apply({required String from, required String to, double? amount}) {
    _setPair(
      state.copyWith(
        from: from,
        to: to,
        amountText: amount == null ? null : Formatters.plain(amount),
      ),
    );
  }

  void _setPair(ConverterState next) {
    state = next;
    unawaited(
      ref
          .read(settingsRepositoryProvider)
          .setLastPair(from: next.from, to: next.to),
    );
  }
}

final converterProvider = NotifierProvider<ConverterNotifier, ConverterState>(
  ConverterNotifier.new,
);

/// Converted amount for the current input. Null while rates are loading.
final conversionResultProvider = Provider<double?>((ref) {
  final rates = ref.watch(ratesProvider).valueOrNull;
  if (rates == null) return null;
  final input = ref.watch(converterProvider);
  return ref.read(convertCurrencyProvider)(
    rates: rates,
    amount: input.amount,
    from: input.from,
    to: input.to,
  );
});
