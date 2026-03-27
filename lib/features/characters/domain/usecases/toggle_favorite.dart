import '../entities/character_entity.dart';
import '../repository/character_repository.dart';

class ToggleFavorite {
  final CharacterRepository repository;

  ToggleFavorite(this.repository);

  Future<void> call(CharacterEntity character) {
    return repository.toggleFavorite(character);
  }
}
