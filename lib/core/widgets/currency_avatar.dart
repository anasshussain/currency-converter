import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/currencies/domain/entities/currency.dart';
import '../constants/api_constants.dart';
import '../theme/app_palette.dart';

/// Round country flag (or a coin badge for crypto).
class CurrencyAvatar extends StatelessWidget {
  const CurrencyAvatar({super.key, required this.currency, this.size = 44});

  final Currency currency;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final country = currency.countryCode;

    final Widget content = country == null
        ? _CoinBadge(code: currency.code, size: size)
        : Image.network(
            '${ApiConstants.flagCdn}/${country.toLowerCase()}.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _EmojiFlag(country: country, size: size),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _EmojiFlag(country: country, size: size);
            },
          );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: p.border, width: 1),
      ),
      child: ClipOval(child: content),
    );
  }
}

class _EmojiFlag extends StatelessWidget {
  const _EmojiFlag({required this.country, required this.size});

  final String country;
  final double size;

  String get _emoji => String.fromCharCodes(
        country.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: context.palette.surfaceAlt,
      child: Text(_emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({required this.code, required this.size});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hue = (code.codeUnits.fold<int>(0, (a, b) => a * 31 + b) % 360).toDouble();
    final color = HSLColor.fromAHSL(1, hue, 0.65, 0.5).toColor();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.7)],
        ),
      ),
      child: Text(
        code.substring(0, math.min(3, code.length)),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.27,
        ),
      ),
    );
  }
}
