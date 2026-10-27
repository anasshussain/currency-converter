import 'package:flutter/material.dart' show ThemeMode;

abstract interface class SettingsRepository {
  ThemeMode getThemeMode();

  Future<void> setThemeMode(ThemeMode mode);

  /// Last converted pair, restored on next launch. Null on first run.
  ({String from, String to})? getLastPair();

  Future<void> setLastPair({required String from, required String to});
}
