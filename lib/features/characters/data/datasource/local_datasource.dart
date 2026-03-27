import 'package:hive/hive.dart';
import '../models/character_model.dart';
import '../models/character_override_model.dart';

class LocalDataSource {
  final Box characterBox;
  final Box overrideBox;
  final Box favoritesBox;

  LocalDataSource(
      this.characterBox,
      this.overrideBox,
      this.favoritesBox,
      );

  // Cache API
  Future<void> cacheCharacters(List<CharacterModel> list) async {
    for (var character in list) {
      await characterBox.put(character.id, character.toJson());
    }
  }

  Future<List<CharacterModel>> getCachedCharacters() async {
    final result = <CharacterModel>[];

    for (final item in characterBox.values) {
      if (item is! Map) continue;
      try {
        result.add(CharacterModel.fromJson(Map<String, dynamic>.from(item)));
      } catch (_) {
        // Ignore malformed cached entries instead of crashing offline mode.
      }
    }

    return result;
  }

  // Overrides
  Future<void> saveOverride(CharacterOverride override) async {
    await overrideBox.put(override.id, override.toJson());
  }

  Future<CharacterOverride?> getOverride(int id) async {
    final data = overrideBox.get(id);
    if (data == null) return null;
    return CharacterOverride.fromJson(Map<String, dynamic>.from(data));
  }

  // Favorites
  Future<void> toggleFavorite(CharacterModel character) async {
    if (favoritesBox.containsKey(character.id)) {
      await favoritesBox.delete(character.id);
      return;
    }
    await favoritesBox.put(character.id, character.toJson());
  }

  bool isFavorite(int id) {
    return favoritesBox.containsKey(id);
  }

  List<int> getFavorites() {
    return favoritesBox.keys.whereType<int>().toList();
  }

  List<CharacterModel> getFavoriteCharacters() {
    final result = <CharacterModel>[];

    for (final key in favoritesBox.keys) {
      final value = favoritesBox.get(key);

      if (value is Map) {
        try {
          result.add(CharacterModel.fromJson(Map<String, dynamic>.from(value)));
        } catch (_) {
          // Ignore malformed favorite entries.
        }
        continue;
      }

      // Backward compatibility: old data format was `id -> true`.
      if (value == true && key is int) {
        final cachedCharacter = characterBox.get(key);
        if (cachedCharacter is Map) {
          try {
            final model = CharacterModel.fromJson(
              Map<String, dynamic>.from(cachedCharacter),
            );
            result.add(model);
            favoritesBox.put(key, model.toJson());
          } catch (_) {
            // Ignore malformed legacy entries.
          }
        }
      }
    }

    return result;
  }
}
