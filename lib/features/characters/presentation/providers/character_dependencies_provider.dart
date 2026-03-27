import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/constants.dart';
import '../../data/datasource/local_datasource.dart';
import '../../data/datasource/remote_datasource.dart';
import '../../data/repository/character_repository_impl.dart';
import '../../domain/repository/character_repository.dart';
import '../../domain/usecases/get_characters.dart';
import '../../domain/usecases/get_favorite_characters.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/update_character.dart';

final dioClientProvider = Provider((ref) => DioClient());

final remoteDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return RemoteDataSource(dio);
});

final characterBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.characterBox);
});

final overrideBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.overrideBox);
});

final favoritesBoxProvider = Provider<Box>((ref) {
  return Hive.box(AppConstants.favoritesBox);
});

final localDataSourceProvider = Provider((ref) {
  return LocalDataSource(
    ref.watch(characterBoxProvider),
    ref.watch(overrideBoxProvider),
    ref.watch(favoritesBoxProvider),
  );
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final remote = ref.watch(remoteDataSourceProvider);
  final local = ref.watch(localDataSourceProvider);
  return CharacterRepositoryImpl(remote, local);
});

final getCharactersProvider = Provider((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return GetCharacters(repository);
});

final getFavoriteCharactersProvider = Provider((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return GetFavoriteCharacters(repository);
});

final toggleFavoriteProvider = Provider((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return ToggleFavorite(repository);
});

final updateCharacterProvider = Provider((ref) {
  final repository = ref.watch(characterRepositoryProvider);
  return UpdateCharacter(repository);
});
