import '../../domain/entities/character_entity.dart';
import '../../domain/repository/character_repository.dart';
import '../datasource/local_datasource.dart';
import '../datasource/remote_datasource.dart';
import '../models/character_model.dart';
import '../models/character_override_model.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final RemoteDataSource remote;
  final LocalDataSource local;

  CharacterRepositoryImpl(this.remote, this.local);

  @override
  Future<List<CharacterEntity>> getCharacters(int page) async {
    try {
      final apiData = await remote.fetchCharacters(page);

      await local.cacheCharacters(apiData);

      return await _merge(apiData);
    } catch (e) {
      final cached = await local.getCachedCharacters();
      return await _merge(cached);
    }
  }

  @override
  Future<List<CharacterEntity>> getFavoriteCharacters() async {
    final favorites = local.getFavoriteCharacters();
    return _merge(favorites);
  }

  @override
  Future<void> toggleFavorite(CharacterEntity character) {
    return local.toggleFavorite(_entityToModel(character));
  }

  @override
  Future<void> saveCharacterOverride(CharacterEntity character) {
    return local.saveOverride(
      CharacterOverride(
        id: character.id,
        name: character.name,
        status: character.status,
        species: character.species,
        type: character.type,
        gender: character.gender,
        origin: character.origin,
        location: character.location,
      ),
    );
  }

  Future<List<CharacterEntity>> _merge(List<CharacterModel> list) async {
    List<CharacterEntity> result = [];

    for (var api in list) {
      final override = await local.getOverride(api.id);

      result.add(
        CharacterEntity(
          id: api.id,
          name: override?.name ?? api.name,
          status: override?.status ?? api.status,
          species: override?.species ?? api.species,
          type: override?.type ?? api.type,
          gender: override?.gender ?? api.gender,
          origin: override?.origin ?? api.origin,
          location: override?.location ?? api.location,
          image: api.image,
        ),
      );
    }

    return result;
  }

  CharacterModel _entityToModel(CharacterEntity entity) {
    return CharacterModel(
      id: entity.id,
      name: entity.name,
      status: entity.status,
      species: entity.species,
      type: entity.type,
      gender: entity.gender,
      origin: entity.origin,
      location: entity.location,
      image: entity.image,
    );
  }
}
