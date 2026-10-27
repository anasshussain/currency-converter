import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/currency_avatar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../rates/presentation/providers/rates_provider.dart';
import '../../domain/entities/currency.dart';

/// Opens the currency list and resolves with the chosen currency code.
Future<String?> pickCurrency(
  BuildContext context, {
  required String selected,
}) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => CurrencyPickerPage(selected: selected)),
  );
}

enum _Filter {
  all('All'),
  major('Major'),
  crypto('Crypto'),
  favorites('Favorites');

  const _Filter(this.label);
  final String label;
}

class CurrencyPickerPage extends ConsumerStatefulWidget {
  const CurrencyPickerPage({super.key, required this.selected});

  final String selected;

  @override
  ConsumerState<CurrencyPickerPage> createState() => _CurrencyPickerPageState();
}

class _CurrencyPickerPageState extends ConsumerState<CurrencyPickerPage> {
  String _query = '';
  _Filter _filter = _Filter.all;

  List<Currency> _visible(List<Currency> all, List<String> favorites) {
    final query = _query.trim().toLowerCase();

    final filtered = all.where((c) {
      final matchesFilter = switch (_filter) {
        _Filter.all => true,
        _Filter.major => c.isMajor,
        _Filter.crypto => c.isCrypto,
        _Filter.favorites => favorites.contains(c.code),
      };
      if (!matchesFilter) return false;
      if (query.isEmpty) return true;
      return c.code.toLowerCase().contains(query) ||
          c.name.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) {
        if (a.isMajor != b.isMajor) return a.isMajor ? -1 : 1;
        return a.code.compareTo(b.code);
      });

    // The current selection is pinned to the top, like in the design.
    final index = filtered.indexWhere((c) => c.code == widget.selected);
    if (index > 0 && query.isEmpty) {
      filtered.insert(0, filtered.removeAt(index));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final all = ref.watch(availableCurrenciesProvider);
    final favorites = ref.watch(favoritesProvider);
    final items = _visible(all, favorites);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Currency')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: AppSearchField(onChanged: (v) => setState(() => _query = v)),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _Filter.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final filter = _Filter.values[i];
                final selected = filter == _filter;
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _filter = filter),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : p.muted,
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.transparent,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No currencies found',
                    subtitle: 'Try a different name or code.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _CurrencyRow(
                      currency: items[i],
                      isSelected: items[i].code == widget.selected,
                      isFavorite: favorites.contains(items[i].code),
                      onTap: () => Navigator.of(context).pop(items[i].code),
                      onToggleFavorite: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(items[i].code),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.currency,
    required this.isSelected,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final Currency currency;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? p.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currency.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFavorite ? const Color(0xFFF5B400) : p.muted,
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.primary : p.border,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
