import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/currency_avatar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../converter/presentation/providers/converter_provider.dart';
import '../../../rates/presentation/providers/rates_provider.dart';
import '../../../shell/presentation/providers/shell_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final favorites = ref.watch(favoritesProvider);
    final base = ref.watch(converterProvider.select((s) => s.from));
    final rates = ref.watch(ratesProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const EmptyState(
              icon: Icons.star_border_rounded,
              title: 'No favorites yet',
              subtitle: 'Tap the star next to a currency in the currency list '
                  'to pin it here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final code = favorites[i];
                // Static metadata; `read` because this runs outside build().
                final currency = ref.read(currencyProvider(code));
                final rate = rates?.rate(base, code);

                return AppCard(
                  radius: 20,
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                  onTap: () {
                    ref.read(converterProvider.notifier).setTo(code);
                    ref.read(shellIndexProvider.notifier).state = 0;
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  },
                  child: Row(
                    children: [
                      CurrencyAvatar(currency: currency, size: 44),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currency.code,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              currency.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: p.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            rate == null ? '--' : Formatters.rate(rate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'per 1 $base',
                            style: TextStyle(color: p.muted, fontSize: 12),
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'Remove favorite',
                        onPressed: () =>
                            ref.read(favoritesProvider.notifier).toggle(code),
                        icon: const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF5B400),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
