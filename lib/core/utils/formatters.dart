import 'dart:math' as math;

abstract final class Formatters {
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// 28123.5 -> "28,123.50". Values below 1 keep more precision
  /// (useful for crypto), e.g. 0.0000091 -> "0.000009100".
  static String amount(double value) => _smart(value, bigDecimals: 2);

  /// Exchange rate, 281.235 -> "281.2350".
  static String rate(double value) => _smart(value, bigDecimals: 4);

  /// 0.2431 -> "0.24%".
  static String percent(double value) => '${value.abs().toStringAsFixed(2)}%';

  /// "1,250.5" / "1250,5"-free input -> 1250.5. Returns null if invalid.
  static double? parseAmount(String input) {
    final cleaned = input.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  /// Plain number for the input field (no grouping), trims trailing zeros.
  static String plain(double value) {
    var text = value.toStringAsFixed(6);
    if (text.contains('.')) {
      text = text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return text;
  }

  static String relativeTime(DateTime time, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(time);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'min' : 'mins'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${h == 1 ? 'hour' : 'hours'} ago';
    }
    final d = diff.inDays;
    return '$d ${d == 1 ? 'day' : 'days'} ago';
  }

  /// "Today, 12:34 PM" / "Yesterday, 08:45 PM" / "Oct 24, 2026".
  static String historyStamp(DateTime time, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final day = DateTime(time.year, time.month, time.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return 'Today, ${_clock(time)}';
    if (diff == 1) return 'Yesterday, ${_clock(time)}';
    return '${_months[time.month - 1]} ${time.day}, ${time.year}';
  }

  /// "Oct 24".
  static String shortDate(DateTime time) =>
      '${_months[time.month - 1]} ${time.day}';

  /// "2026-10-27" (UTC date used by the rates API).
  static String apiDate(DateTime time) {
    final utc = time.toUtc();
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$m-$d';
  }

  static String _clock(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $suffix';
  }

  static String _smart(double value, {required int bigDecimals}) {
    if (value.isNaN || value.isInfinite) return '--';
    if (value == 0) return '0.00';
    final abs = value.abs();
    if (abs >= 1) return _grouped(value, bigDecimals);
    if (abs >= 0.01) return _grouped(value, 4);

    final decimals = math.min(12, (-math.log(abs) / math.ln10).ceil() + 3);
    return _grouped(value, decimals);
  }

  static String _grouped(double value, int decimals) {
    final parts = value.abs().toStringAsFixed(decimals).split('.');
    final integer = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final sign = value < 0 ? '-' : '';
    return parts.length > 1 ? '$sign$integer.${parts[1]}' : '$sign$integer';
  }
}
