import '../entities/character_entity.dart';
import '../repository/character_repository.dart';

class GetFavoriteCharacters {
  final CharacterRepository repository;

  GetFavoriteCharacters(this.repository);

  Future<List<CharacterEntity>> call() {
    return repository.getFavoriteCharacters();
  }
}
