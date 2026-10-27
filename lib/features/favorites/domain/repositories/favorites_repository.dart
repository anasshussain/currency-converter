abstract interface class FavoritesRepository {
  /// Favorite currency codes in the order they were added.
  List<String> getAll();

  Future<void> saveAll(List<String> codes);
}
