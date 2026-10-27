import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the selected bottom-navigation tab.
/// 0 = Home, 1 = Rates, 2 = History, 3 = More.
final shellIndexProvider = StateProvider<int>((ref) => 0);
