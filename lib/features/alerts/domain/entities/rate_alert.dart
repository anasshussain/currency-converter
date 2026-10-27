import 'package:equatable/equatable.dart';

class RateAlert extends Equatable {
  const RateAlert({
    required this.id,
    required this.from,
    required this.to,
    required this.target,
    required this.triggerWhenAbove,
    this.isActive = true,
    this.triggeredAt,
  });

  final String id;
  final String from;
  final String to;
  final double target;

  /// true: notify when the rate rises above [target]; false: falls below.
  final bool triggerWhenAbove;
  final bool isActive;
  final DateTime? triggeredAt;

  bool isMet(double currentRate) =>
      triggerWhenAbove ? currentRate >= target : currentRate <= target;

  RateAlert copyWith({bool? isActive, DateTime? triggeredAt}) {
    return RateAlert(
      id: id,
      from: from,
      to: to,
      target: target,
      triggerWhenAbove: triggerWhenAbove,
      isActive: isActive ?? this.isActive,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'target': target,
        'above': triggerWhenAbove,
        'active': isActive,
        'triggeredAt': triggeredAt?.toIso8601String(),
      };

  factory RateAlert.fromJson(Map<String, dynamic> json) {
    final triggered = json['triggeredAt'] as String?;
    return RateAlert(
      id: json['id'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      target: (json['target'] as num).toDouble(),
      triggerWhenAbove: json['above'] as bool,
      isActive: json['active'] as bool,
      triggeredAt: triggered == null ? null : DateTime.parse(triggered),
    );
  }

  @override
  List<Object?> get props =>
      [id, from, to, target, triggerWhenAbove, isActive, triggeredAt];
}
