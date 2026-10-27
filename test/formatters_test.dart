import 'package:currency_converter/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('amount', () {
    test('groups thousands with two decimals', () {
      expect(Formatters.amount(28123.5), '28,123.50');
      expect(Formatters.amount(1234567.891), '1,234,567.89');
    });

    test('keeps precision for small values', () {
      expect(Formatters.amount(0.5), '0.5000');
      expect(Formatters.amount(0.0000091), startsWith('0.000009'));
    });
  });

  test('rate uses four decimals', () {
    expect(Formatters.rate(281.235), '281.2350');
  });

  test('parseAmount handles commas and invalid input', () {
    expect(Formatters.parseAmount('1,250.5'), 1250.5);
    expect(Formatters.parseAmount(''), isNull);
    expect(Formatters.parseAmount('abc'), isNull);
  });

  test('plain trims trailing zeros', () {
    expect(Formatters.plain(100), '100');
    expect(Formatters.plain(12.5), '12.5');
  });

  test('historyStamp labels today and yesterday', () {
    final now = DateTime(2026, 10, 27, 15, 0);
    expect(
      Formatters.historyStamp(DateTime(2026, 10, 27, 12, 34), now: now),
      'Today, 12:34 PM',
    );
    expect(
      Formatters.historyStamp(DateTime(2026, 10, 26, 20, 45), now: now),
      'Yesterday, 08:45 PM',
    );
    expect(
      Formatters.historyStamp(DateTime(2026, 10, 24, 9, 0), now: now),
      'Oct 24, 2026',
    );
  });

  test('relativeTime', () {
    final now = DateTime(2026, 10, 27, 12, 0);
    expect(Formatters.relativeTime(now, now: now), 'just now');
    expect(
      Formatters.relativeTime(now.subtract(const Duration(minutes: 2)), now: now),
      '2 mins ago',
    );
  });
}
