import 'package:shared_preferences/shared_preferences.dart';
import 'storage_keys.dart';

// Atelier 8 pattern: SharedPreferences for local persistence
class SearchHistoryService {
  static const int _maxItems = 8;

  Future<List<String>> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(StorageKeys.recentSearches) ?? [];
  }

  Future<void> addRecentSearch(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(StorageKeys.recentSearches) ?? [];
    // Remove any existing identical entry (case-insensitive dedup)
    current.removeWhere((s) => s.toLowerCase() == trimmed.toLowerCase());
    current.insert(0, trimmed);
    if (current.length > _maxItems) current.length = _maxItems;
    await prefs.setStringList(StorageKeys.recentSearches, current);
  }

  Future<void> removeRecentSearch(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(StorageKeys.recentSearches) ?? [];
    current.removeWhere((s) => s == term);
    await prefs.setStringList(StorageKeys.recentSearches, current);
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.recentSearches);
  }
}
