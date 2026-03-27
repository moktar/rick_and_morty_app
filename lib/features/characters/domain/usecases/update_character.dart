import '../entities/character_entity.dart';
import '../repository/character_repository.dart';

class UpdateCharacter {
  final CharacterRepository repository;

  UpdateCharacter(this.repository);

  Future<void> call(CharacterEntity character) {
    return repository.saveCharacterOverride(character);
  }
}
