import '../entities/character_entity.dart';

abstract class CharacterRepository {
  Future<List<CharacterEntity>> getCharacters(int page);
  Future<List<CharacterEntity>> getFavoriteCharacters();
  Future<void> toggleFavorite(CharacterEntity character);
  Future<void> saveCharacterOverride(CharacterEntity character);
}
