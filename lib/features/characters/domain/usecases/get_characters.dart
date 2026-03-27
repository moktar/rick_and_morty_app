import '../entities/character_entity.dart';
import '../repository/character_repository.dart';

class GetCharacters {
  final CharacterRepository repository;

  GetCharacters(this.repository);

  Future<List<CharacterEntity>> call(int page) {
    return repository.getCharacters(page);
  }
}