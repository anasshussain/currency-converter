import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/currency_avatar.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../currencies/domain/entities/currency.dart';
import '../../../currencies/presentation/pages/currency_picker_page.dart';
import '../../../rates/presentation/providers/rates_provider.dart';
import '../providers/alerts_provider.dart';

Future<void> showAddAlertSheet(
  BuildContext context, {
  required String from,
  required String to,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AddAlertSheet(from: from, to: to),
  );
}

class AddAlertSheet extends ConsumerStatefulWidget {
  const AddAlertSheet({super.key, required this.from, required this.to});

  final String from;
  final String to;

  @override
  ConsumerState<AddAlertSheet> createState() => _AddAlertSheetState();
}

class _AddAlertSheetState extends ConsumerState<AddAlertSheet> {
  late String _from = widget.from;
  late String _to = widget.to;
  bool _above = true;
  late final TextEditingController _target;

  @override
  void initState() {
    super.initState();
    final rate = ref.read(pairRateProvider((from: widget.from, to: widget.to)));
    _target = TextEditingController(text: rate == null ? '' : Formatters.plain(rate));
  }

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool isFrom}) async {
    final code = await pickCurrency(context, selected: isFrom ? _from : _to);
    if (code == null) return;
    setState(() {
      if (isFrom) {
        _from = code;
      } else {
        _to = code;
      }
    });
    final rate = ref.read(pairRateProvider((from: _from, to: _to)));
    if (rate != null) _target.text = Formatters.plain(rate);
  }

  Future<void> _save() async {
    final target = Formatters.parseAmount(_target.text);
    if (target == null || target <= 0 || _from == _to) return;

    await ref.read(alertsProvider.notifier).add(
          from: _from,
          to: _to,
          target: target,
          triggerWhenAbove: _above,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final from = ref.watch(currencyProvider(_from));
    final to = ref.watch(currencyProvider(_to));
    final current = ref.watch(pairRateProvider((from: _from, to: _to)));

    Widget currencyButton(String label, Currency currency, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CurrencyAvatar(currency: currency, size: 34),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(color: p.muted, fontSize: 11)),
                      Text(
                        currency.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: p.muted),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New rate alert',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                currencyButton('From', from, () => _pick(isFrom: true)),
                const SizedBox(width: 10),
                currencyButton('To', to, () => _pick(isFrom: false)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: true, label: Text('Rises above')),
                  ButtonSegment(value: false, label: Text('Falls below')),
                ],
                selected: {_above},
                onSelectionChanged: (s) => setState(() => _above = s.first),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Target rate (1 $_from in $_to)',
                helperText: current == null
                    ? null
                    : 'Current rate: ${Formatters.rate(current)}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Create alert',
              icon: Icons.notifications_active_outlined,
              onPressed: _from == _to ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
