import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(settingsRepositoryProvider).getThemeMode();

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(settingsRepositoryProvider).setThemeMode(mode);
  }

  /// Flips between light and dark (used by the sun/moon button).
  Future<void> toggle(Brightness current) {
    return setMode(
      current == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
