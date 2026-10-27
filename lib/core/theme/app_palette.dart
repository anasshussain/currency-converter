import 'package:flutter/material.dart';

/// Brand colors shared by both themes.
abstract final class AppColors {
  static const Color primary = Color(0xFF5B5EF4);
  static const Color primaryEnd = Color(0xFF7366F8);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5766F5), Color(0xFF6F63F7)],
  );
}

/// Theme specific colors, available through `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.muted,
    required this.border,
    required this.primarySoft,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color text;
  final Color muted;
  final Color border;
  final Color primarySoft;
  final Color shadow;

  static const AppPalette light = AppPalette(
    background: Color(0xFFF5F6FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF3F4FA),
    text: Color(0xFF0F1226),
    muted: Color(0xFF7B8199),
    border: Color(0xFFE8EAF3),
    primarySoft: Color(0xFFECECFE),
    shadow: Color(0x145B5EF4),
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF0B0D1A),
    surface: Color(0xFF151830),
    surfaceAlt: Color(0xFF1D2140),
    text: Color(0xFFF5F6FF),
    muted: Color(0xFF8D93B3),
    border: Color(0xFF262A4A),
    primarySoft: Color(0xFF26295A),
    shadow: Color(0x33000000),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? text,
    Color? muted,
    Color? border,
    Color? primarySoft,
    Color? shadow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      primarySoft: primarySoft ?? this.primarySoft,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
