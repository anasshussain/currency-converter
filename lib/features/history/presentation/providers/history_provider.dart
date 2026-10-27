import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/conversion_record.dart';

class HistoryNotifier extends Notifier<List<ConversionRecord>> {
  @override
  List<ConversionRecord> build() => ref.read(historyRepositoryProvider).getAll();

  Future<void> add({
    required String from,
    required String to,
    required double amount,
    required double result,
  }) {
    final record = ConversionRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      from: from,
      to: to,
      amount: amount,
      result: result,
      createdAt: DateTime.now(),
    );

    // The same conversion is kept once, at the top.
    final others = state.where(
      (r) => !(r.from == from && r.to == to && r.amount == amount),
    );
    return _commit([record, ...others].take(AppConstants.historyLimit).toList());
  }

  Future<void> remove(String id) {
    return _commit(state.where((r) => r.id != id).toList());
  }

  Future<void> clear() => _commit(const []);

  Future<void> _commit(List<ConversionRecord> next) async {
    state = next;
    await ref.read(historyRepositoryProvider).saveAll(next);
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<ConversionRecord>>(
  HistoryNotifier.new,
);
