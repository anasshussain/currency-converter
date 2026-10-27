import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Search currency...',
    this.controller,
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.muted, fontSize: 15),
        prefixIcon: Icon(Icons.search_rounded, color: p.muted),
        filled: true,
        fillColor: p.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
