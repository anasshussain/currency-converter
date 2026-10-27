import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../alerts/presentation/pages/alerts_page.dart';
import '../../../alerts/presentation/providers/alerts_provider.dart';
import '../../../favorites/presentation/pages/favorites_page.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../rates/presentation/providers/rates_provider.dart';
import '../providers/theme_provider.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final themeMode = ref.watch(themeModeProvider);
    final ratesAsync = ref.watch(ratesProvider);
    final rates = ratesAsync.valueOrNull;
    final isRefreshing = ratesAsync.isLoading;
    final currencyCount = ref.watch(availableCurrenciesProvider).length;
    final favoriteCount = ref.watch(favoritesProvider).length;
    final activeAlerts =
        ref.watch(alertsProvider).where((a) => a.isActive).length;

    void open(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    final isLive = rates != null && !rates.isStale;
    final statusText =
    rates == null ? 'Loading' : (isLive ? 'Live' : 'Offline');

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        // Bottom padding keeps content clear of the floating glass navbar.
        padding: const EdgeInsets.only(bottom: 130),
        children: [
          const PageHeader(title: 'More'),

          // ── Status hero ────────────────────────────────────────────────
          _FadeIn(
            delay: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _StatusHero(
                statusText: statusText,
                isLive: isLive,
                isLoading: rates == null,
                published: rates == null
                    ? '--'
                    : Formatters.apiDate(rates.dataDate),
                synced: rates == null
                    ? '--'
                    : Formatters.relativeTime(rates.fetchedAt),
                refreshing: isRefreshing,
                onRefresh: () => ref.read(ratesProvider.notifier).refresh(),
              ),
            ),
          ),

          // ── Quick stats ────────────────────────────────────────────────
          _FadeIn(
            delay: 60,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.public_rounded,
                      color: const Color(0xFF3B82F6),
                      value: '$currencyCount',
                      label: 'Currencies',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.star_rounded,
                      color: const Color(0xFFF59E0B),
                      value: '$favoriteCount',
                      label: 'Favorites',
                      onTap: () => open(const FavoritesPage()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.notifications_active_rounded,
                      color: const Color(0xFFEF4444),
                      value: '$activeAlerts',
                      label: 'Alerts',
                      onTap: () => open(const AlertsPage()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Appearance ─────────────────────────────────────────────────
          _FadeIn(
            delay: 120,
            child: _Section(
              title: 'Appearance',
              child: Row(
                children: [
                  _ThemeOption(
                    icon: Icons.brightness_auto_rounded,
                    label: 'System',
                    selected: themeMode == ThemeMode.system,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setMode(ThemeMode.system),
                  ),
                  const SizedBox(width: 10),
                  _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    label: 'Light',
                    selected: themeMode == ThemeMode.light,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setMode(ThemeMode.light),
                  ),
                  const SizedBox(width: 10),
                  _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    label: 'Dark',
                    selected: themeMode == ThemeMode.dark,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
          ),

          // ── Shortcuts ──────────────────────────────────────────────────
          _FadeIn(
            delay: 180,
            child: _Section(
              title: 'Shortcuts',
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  _Tile(
                    icon: Icons.star_rounded,
                    color: const Color(0xFFF59E0B),
                    title: 'Favorites',
                    subtitle: 'Your pinned currency pairs',
                    trailing: '$favoriteCount',
                    onTap: () => open(const FavoritesPage()),
                  ),
                  Divider(height: 1, indent: 54, color: p.border),
                  _Tile(
                    icon: Icons.notifications_rounded,
                    color: const Color(0xFFEF4444),
                    title: 'Rate Alerts',
                    subtitle: 'Get notified at your target rate',
                    trailing: '$activeAlerts active',
                    onTap: () => open(const AlertsPage()),
                  ),
                ],
              ),
            ),
          ),

          // ── Data ───────────────────────────────────────────────────────
          _FadeIn(
            delay: 240,
            child: _Section(
              title: 'Data',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  _Info(
                    icon: Icons.language_rounded,
                    label: 'Currencies available',
                    value: '$currencyCount',
                  ),
                  Divider(height: 1, color: p.border),
                  _Info(
                    icon: Icons.event_rounded,
                    label: 'Rates published',
                    value: rates == null
                        ? '--'
                        : Formatters.apiDate(rates.dataDate),
                  ),
                  Divider(height: 1, color: p.border),
                  _Info(
                    icon: Icons.sync_rounded,
                    label: 'Last synced',
                    value: rates == null
                        ? '--'
                        : Formatters.relativeTime(rates.fetchedAt),
                  ),
                  Divider(height: 1, color: p.border),
                  _Info(
                    icon: Icons.wifi_rounded,
                    label: 'Status',
                    value: rates == null
                        ? 'Loading'
                        : (rates.isStale ? 'Offline (saved rates)' : 'Live'),
                    valueColor: rates == null
                        ? p.muted
                        : (rates.isStale
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF22C55E)),
                  ),
                ],
              ),
            ),
          ),

          // ── Footer ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: p.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.currency_exchange_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  'Currency Converter',
                  style: TextStyle(
                    color: p.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: p.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// Widgets
// ═════════════════════════════════════════════════════════════════════════

/// Gentle fade + slide-up on first build.
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
          offset: Offset(0, (1 - t) * 14),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({
    required this.statusText,
    required this.isLive,
    required this.isLoading,
    required this.published,
    required this.synced,
    required this.refreshing,
    required this.onRefresh,
  });

  final String statusText;
  final bool isLive;
  final bool isLoading;
  final String published;
  final String synced;
  final bool refreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final dot = isLoading
        ? Colors.white70
        : (isLive ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFDB2777)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.32),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative soft circle.
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: dot,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: dot.withValues(alpha: 0.7),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Exchange rates',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Published $published  •  Synced $synced',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: refreshing ? null : onRefresh,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: refreshing ? 0.55 : 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      refreshing
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF4F46E5),
                        ),
                      )
                          : const Icon(Icons.refresh_rounded,
                          size: 18, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 8),
                      Text(
                        refreshing ? 'Refreshing...' : 'Refresh rates',
                        style: const TextStyle(
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AppCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: p.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: context.palette.muted,
              ),
            ),
          ),
          AppCard(radius: 22, padding: padding, child: child),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? p.primarySoft : Colors.transparent,
            border: Border.all(
              color: selected ? AppColors.primary : p.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.primary : p.muted,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? AppColors.primary : p.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: p.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              trailing,
              style: TextStyle(
                color: p.muted,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded, color: p.muted),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: p.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(color: p.muted, fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}