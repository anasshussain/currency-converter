import 'package:equatable/equatable.dart';

class ConversionRecord extends Equatable {
  const ConversionRecord({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.result,
    required this.createdAt,
  });

  final String id;
  final String from;
  final String to;
  final double amount;
  final double result;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'amount': amount,
        'result': result,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ConversionRecord.fromJson(Map<String, dynamic> json) {
    return ConversionRecord(
      id: json['id'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      amount: (json['amount'] as num).toDouble(),
      result: (json['result'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, from, to, amount, result, createdAt];
}
