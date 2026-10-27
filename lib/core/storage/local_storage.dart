import 'package:shared_preferences/shared_preferences.dart';

/// Key-value persistence (no database). Used for cached rates, history,
/// favorites, alerts and settings.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  String? read(String key) => _prefs.getString(key);

  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
