import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';

class FavoritesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(favoritesRepositoryProvider).getAll();

  Future<void> toggle(String code) async {
    final next = state.contains(code)
        ? state.where((c) => c != code).toList()
        : [...state, code];
    state = next;
    await ref.read(favoritesRepositoryProvider).saveAll(next);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<String>>(
  FavoritesNotifier.new,
);
