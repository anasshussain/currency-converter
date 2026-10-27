import 'package:equatable/equatable.dart';

class RatePoint extends Equatable {
  const RatePoint({required this.date, required this.value});

  final DateTime date;
  final double value;

  @override
  List<Object?> get props => [date, value];
}

enum ChartRange {
  week('1W', 7, 8),
  month('1M', 30, 15),
  quarter('3M', 90, 15),
  halfYear('6M', 180, 15),
  year('1Y', 365, 15);

  const ChartRange(this.label, this.days, this.points);

  final String label;

  /// How far back the chart reaches.
  final int days;

  /// Number of samples drawn (the provider has one snapshot per day).
  final int points;
}
