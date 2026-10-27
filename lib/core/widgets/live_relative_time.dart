import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/formatters.dart';

/// "Updated 2 mins ago" that keeps itself fresh while visible.
class LiveRelativeTime extends StatefulWidget {
  const LiveRelativeTime({
    super.key,
    required this.time,
    this.prefix = 'Updated ',
    this.style,
  });

  final DateTime time;
  final String prefix;
  final TextStyle? style;

  @override
  State<LiveRelativeTime> createState() => _LiveRelativeTimeState();
}

class _LiveRelativeTimeState extends State<LiveRelativeTime> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.prefix}${Formatters.relativeTime(widget.time)}',
      style: widget.style,
    );
  }
}
