import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class GlassNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar>
    with SingleTickerProviderStateMixin {
  static const double _height = 72;
  static const double _maxWidth = 380;
  static const double _pad = 6;

  // Tighter spring => subtle jelly, quick settle.
  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: 240,
    damping: 18,
  );

  late final AnimationController _c;
  int? _pressed;

  @override
  void initState() {
    super.initState();
    _c = AnimationController.unbounded(
      vsync: this,
      value: widget.currentIndex.toDouble(),
    );
  }

  @override
  void didUpdateWidget(covariant GlassNavBar old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _c.animateWith(
        SpringSimulation(
          _spring,
          _c.value,
          widget.currentIndex.toDouble(),
          _c.velocity,
        ),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final count = widget.items.length;

    return Padding(
      padding:
      EdgeInsets.fromLTRB(20, 0, 20, bottomInset > 0 ? bottomInset : 14),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: _GlassSurface(
            height: _height,
            radius: _height / 2,
            isDark: isDark,
            child: Padding(
              padding: const EdgeInsets.all(_pad),
              child: LayoutBuilder(
                builder: (context, box) {
                  final tabW = box.maxWidth / count;

                  return Stack(
                    children: [
                      // Glass indicator.
                      AnimatedBuilder(
                        animation: _c,
                        builder: (context, _) {
                          final pos = _c.value.clamp(-0.12, count - 0.88);
                          final speed = _c.velocity.abs();
                          final sx = 1.0 + (speed * 0.022).clamp(0.0, 0.22);
                          final sy = 1.0 - (speed * 0.010).clamp(0.0, 0.06);
                          return Positioned(
                            left: pos * tabW,
                            top: 0,
                            bottom: 0,
                            width: tabW,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.diagonal3Values(sx, sy, 1),
                              child: _IndicatorGlass(isDark: isDark),
                            ),
                          );
                        },
                      ),
                      Row(
                        children: List.generate(count, (i) {
                          return Expanded(
                            child: _NavButton(
                              item: widget.items[i],
                              selected: i == widget.currentIndex,
                              pressed: _pressed == i,
                              onDown: () => setState(() => _pressed = i),
                              onCancel: () {
                                if (_pressed == i) {
                                  setState(() => _pressed = null);
                                }
                              },
                              onTap: () {
                                setState(() => _pressed = null);
                                if (i != widget.currentIndex) {
                                  HapticFeedback.selectionClick();
                                  widget.onTap(i);
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted glass pill used for the selected tab.
class _IndicatorGlass extends StatelessWidget {
  final bool isDark;
  const _IndicatorGlass({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(34);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          BoxShadow(
            color:
            const Color(0xFFB9A2FF).withValues(alpha: isDark ? 0.26 : 0.22),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: CustomPaint(
            foregroundPainter: _GlassBorderPainter(
              radius: 34,
              isDark: isDark,
              strong: true,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: br,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                    Colors.white.withValues(alpha: 0.16),
                    const Color(0xFFB9A2FF).withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.05),
                  ]
                      : [
                    Colors.white.withValues(alpha: 0.60),
                    const Color(0xFFE6DCFF).withValues(alpha: 0.30),
                    Colors.white.withValues(alpha: 0.38),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.45,
                  widthFactor: 0.72,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40),
                        top: Radius.circular(30),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.20 : 0.50),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final GlassNavItem item;
  final bool selected;
  final bool pressed;
  final VoidCallback onTap;
  final VoidCallback onDown;
  final VoidCallback onCancel;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.pressed,
    required this.onTap,
    required this.onDown,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onDown(),
        onTapCancel: onCancel,
        onTap: onTap,
        child: Center(
          child: AnimatedScale(
            scale: pressed ? 0.90 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: selected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutBack,
              builder: (context, t, _) {
                final tc = t.clamp(0.0, 1.0);
                final color = Color.lerp(
                  cs.onSurface.withValues(alpha: 0.55),
                  cs.onSurface,
                  tc,
                )!;
                return Transform.scale(
                  scale: 1.0 + 0.10 * t,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 1 - tc,
                        child: Icon(item.icon, size: 28, color: color),
                      ),
                      Opacity(
                        opacity: tc,
                        child: Icon(item.activeIcon, size: 28, color: color),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSurface extends StatelessWidget {
  final double height;
  final double radius;
  final bool isDark;
  final Widget child;

  const _GlassSurface({
    required this.height,
    required this.radius,
    required this.isDark,
    required this.child,
  });

  static ColorFilter _saturate(double s) {
    const r = 0.2126, g = 0.7152, b = 0.0722;
    return ColorFilter.matrix(<double>[
      (1 - s) * r + s, (1 - s) * g, (1 - s) * b, 0, 0,
      (1 - s) * r, (1 - s) * g + s, (1 - s) * b, 0, 0,
      (1 - s) * r, (1 - s) * g, (1 - s) * b + s, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.12),
            blurRadius: 32,
            spreadRadius: -6,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.compose(
            outer: _saturate(1.8),
            inner: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          ),
          child: CustomPaint(
            foregroundPainter:
            _GlassBorderPainter(radius: radius, isDark: isDark),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: br,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                    Colors.white.withValues(alpha: 0.09),
                    Colors.white.withValues(alpha: 0.02),
                  ]
                      : [
                    Colors.white.withValues(alpha: 0.38),
                    Colors.white.withValues(alpha: 0.14),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Soft specular shine along the top edge.
                  Positioned(
                    top: 0,
                    left: radius * 0.6,
                    right: radius * 0.6,
                    height: height * 0.42,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(height),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white
                                  .withValues(alpha: isDark ? 0.08 : 0.32),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient hairline border: bright top-left, faint middle, soft bottom-right.
class _GlassBorderPainter extends CustomPainter {
  final double radius;
  final bool isDark;
  final bool strong;

  _GlassBorderPainter({
    required this.radius,
    required this.isDark,
    this.strong = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect =
    RRect.fromRectAndRadius(rect.deflate(0.6), Radius.circular(radius));
    final k = strong ? 1.0 : 0.9;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strong ? 1.3 : 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: (isDark ? 0.45 : 1.0) * k),
          Colors.white.withValues(alpha: isDark ? 0.06 : 0.22),
          Colors.white.withValues(alpha: (isDark ? 0.22 : 0.65) * k),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter old) =>
      old.radius != radius || old.isDark != isDark || old.strong != strong;
}