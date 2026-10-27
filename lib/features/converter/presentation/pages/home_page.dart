import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/currency_avatar.dart';
import '../../../alerts/presentation/pages/alerts_page.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../rates/presentation/pages/rate_detail_page.dart';
import '../../../rates/presentation/providers/rates_provider.dart';
import '../../../settings/presentation/providers/theme_provider.dart';
import '../../../shell/presentation/providers/shell_provider.dart';
import '../providers/converter_provider.dart';
import '../widgets/converter_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _popularCodes = [
    'USD', 'EUR', 'GBP', 'AED', 'SAR', 'INR', 'CAD', 'AUD', 'JPY', 'CNY',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => ref.read(ratesProvider.notifier).refresh(),
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
          children: [
            const _FadeIn(delay: 0, child: _Header()),
            const SizedBox(height: 28),
            _FadeIn(
              delay: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Global Currencies.',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                      letterSpacing: -0.8,
                    ),
                  ),
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) =>
                        AppColors.brandGradient.createShader(bounds),
                    child: const Text(
                      'Real-Time Rates.',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                        letterSpacing: -0.8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Convert between 160+ currencies with\nlive exchange rates.',
                    style: TextStyle(color: p.muted, fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _FadeIn(delay: 100, child: ConverterCard()),
            const SizedBox(height: 16),
            const _FadeIn(delay: 150, child: _QuickActions()),
            const SizedBox(height: 28),
            _FadeIn(
              delay: 200,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Popular Currencies',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref.read(shellIndexProvider.notifier).state = 1;
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See All',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const _FadeIn(
              delay: 250,
              child: _PopularCurrencies(codes: _popularCodes),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child, required this.delay});

  final Widget child;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 16),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _Pressable extends StatefulWidget {
  const _Pressable({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.currency_exchange_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Currency',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Converter',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.3,
                color: p.muted,
              ),
            ),
          ],
        ),
        const Spacer(),
        _Pressable(
          onTap: () =>
              ref.read(themeModeProvider.notifier).toggle(brightness),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.surface,
              border: Border.all(color: p.border),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, anim) => RotationTransition(
                turns: Tween<double>(begin: 0.75, end: 1.0).animate(anim),
                child: FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                key: ValueKey(isDark),
                color: p.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(converterProvider);

    void open(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return Row(
      children: [
        Expanded(
          child: _Action(
            icon: Icons.candlestick_chart_rounded,
            color: const Color(0xFF3B82F6),
            label: 'Charts',
            onTap: () => open(RateDetailPage(from: input.from, to: input.to)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Action(
            icon: Icons.notifications_rounded,
            color: const Color(0xFFEF4444),
            label: 'Rate Alerts',
            onTap: () => open(const AlertsPage()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Action(
            icon: Icons.star_rounded,
            color: const Color(0xFFF59E0B),
            label: 'Favorites',
            onTap: () => open(const FavoritesPage()),
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return _Pressable(
      onTap: onTap,
      child: AppCard(
        radius: 22,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.22),
                    color.withValues(alpha: 0.10),
                  ],
                ),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.text,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularCurrencies extends ConsumerWidget {
  const _PopularCurrencies({required this.codes});

  final List<String> codes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final available = ref.watch(availableCurrenciesProvider);
    final target = ref.watch(converterProvider.select((s) => s.to));

    final items = [
      for (final code in codes) ...available.where((c) => c.code == code),
    ];

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final currency = items[i];
          final selected = currency.code == target;

          return SizedBox(
            width: 120,
            child: _Pressable(
              onTap: () =>
                  ref.read(converterProvider.notifier).setTo(currency.code),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppCard(
                      radius: 22,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CurrencyAvatar(currency: currency, size: 38),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.code,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                  color: selected ? AppColors.primary : null,
                                ),
                              ),
                              Text(
                                currency.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: p.muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AnimatedScale(
                      scale: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}