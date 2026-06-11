import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStateService {
  static const String _xpKey = 'user_local_xp';
  static const String _favoritesKey = 'user_local_favorites';
  static const String _recipesKey = 'user_local_recipes';

  // 1. XP Management
  static Future<int> getLocalXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  static Future<void> addLocalXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentXp = prefs.getInt(_xpKey) ?? 0;
    await prefs.setInt(_xpKey, currentXp + amount);
  }

  // 2. Favorites Management (Plants)
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson != null) {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  static Future<void> toggleFavorite(Map<String, dynamic> plantMap) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> favorites = await getFavorites();
    
    final int index = favorites.indexWhere((p) => p['id'] == plantMap['id'] || p['name'] == plantMap['name']);
    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(plantMap);
    }
    
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  static Future<bool> isFavorite(String plantName) async {
    List<Map<String, dynamic>> favorites = await getFavorites();
    return favorites.any((p) => p['name'] == plantName);
  }

  // 3. Recipes/Remedies Management
  static Future<List<Map<String, dynamic>>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recipesJson = prefs.getString(_recipesKey);
    if (recipesJson != null) {
      final List<dynamic> decoded = jsonDecode(recipesJson);
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  static Future<void> saveRecipe(Map<String, dynamic> recipeMap) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> recipes = await getRecipes();
    
    // Check if it already exists (by name or timestamp) to avoid duplicates
    final bool exists = recipes.any((r) => r['name'] == recipeMap['name'] && r['createdAt'] == recipeMap['createdAt']);
    
    if (!exists) {
      recipes.insert(0, recipeMap); // Add at the beginning
      await prefs.setString(_recipesKey, jsonEncode(recipes));
    }
  }
}
