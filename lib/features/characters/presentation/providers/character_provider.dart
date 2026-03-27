import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/character_entity.dart';
import '../../domain/usecases/get_characters.dart';
import '../../domain/usecases/get_favorite_characters.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/update_character.dart';
import 'character_dependencies_provider.dart';

final characterProvider =
    StateNotifierProvider<CharacterNotifier, CharacterState>((ref) {
  final getCharacters = ref.watch(getCharactersProvider);
  final getFavorites = ref.watch(getFavoriteCharactersProvider);
  final toggleFavorite = ref.watch(toggleFavoriteProvider);
  final updateCharacter = ref.watch(updateCharacterProvider);

  return CharacterNotifier(
    getCharacters,
    getFavorites,
    toggleFavorite,
    updateCharacter,
  );
});

class CharacterState {
  final List<CharacterEntity> list;
  final List<CharacterEntity> favoriteList;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final Set<int> favoriteIds;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedStatus;
  final String? selectedSpecies;

  CharacterState({
    this.list = const [],
    this.favoriteList = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.favoriteIds = const {},
    this.errorMessage,
    this.searchQuery = '',
    this.selectedStatus,
    this.selectedSpecies,
  });

  CharacterState copyWith({
    List<CharacterEntity>? list,
    List<CharacterEntity>? favoriteList,
    bool? isLoading,
    bool? hasMore,
    int? page,
    Set<int>? favoriteIds,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    String? selectedStatus,
    bool clearSelectedStatus = false,
    String? selectedSpecies,
    bool clearSelectedSpecies = false,
  }) {
    return CharacterState(
      list: list ?? this.list,
      favoriteList: favoriteList ?? this.favoriteList,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedSpecies: clearSelectedSpecies
          ? null
          : (selectedSpecies ?? this.selectedSpecies),
    );
  }
}

class CharacterNotifier extends StateNotifier<CharacterState> {
  final GetCharacters _getCharacters;
  final GetFavoriteCharacters _getFavoriteCharacters;
  final ToggleFavorite _toggleFavorite;
  final UpdateCharacter _updateCharacter;

  CharacterNotifier(
    this._getCharacters,
    this._getFavoriteCharacters,
    this._toggleFavorite,
    this._updateCharacter,
  ) : super(CharacterState()) {
    unawaited(_loadFavorites());
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _getFavoriteCharacters();
      final favoriteIds = favorites.map((e) => e.id).toSet();

      state = state.copyWith(
        favoriteIds: favoriteIds,
        favoriteList: favorites,
      );
      _mergeLoadedFavorites();
    } catch (_) {
      state = state.copyWith(
        favoriteIds: {},
        favoriteList: [],
      );
    }
  }

  void _mergeLoadedFavorites() {
    final favoriteMap = <int, CharacterEntity>{
      for (final character in state.favoriteList) character.id: character,
    };

    for (final character in state.list) {
      if (state.favoriteIds.contains(character.id)) {
        favoriteMap[character.id] = character;
      }
    }

    final merged = favoriteMap.values
        .where((character) => state.favoriteIds.contains(character.id))
        .toList();

    state = state.copyWith(favoriteList: merged);
  }

  Future<void> toggleFavorite(CharacterEntity character) async {
    await _toggleFavorite(character);
    await _loadFavorites();
  }

  bool isFavorite(int id) {
    return state.favoriteIds.contains(id);
  }

  List<CharacterEntity> getFavoritesList() {
    return state.favoriteList;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedStatus(String? status) {
    state = state.copyWith(
      selectedStatus: status,
      clearSelectedStatus: status == null,
    );
  }

  void setSelectedSpecies(String? species) {
    state = state.copyWith(
      selectedSpecies: species,
      clearSelectedSpecies: species == null,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      clearSelectedStatus: true,
      clearSelectedSpecies: true,
    );
  }

  Future<void> updateCharacter(CharacterEntity updatedCharacter) async {
    await _updateCharacter(updatedCharacter);

    final updatedList = state.list.map((character) {
      if (character.id == updatedCharacter.id) return updatedCharacter;
      return character;
    }).toList();

    final updatedFavorites = state.favoriteList.map((character) {
      if (character.id == updatedCharacter.id) return updatedCharacter;
      return character;
    }).toList();

    state = state.copyWith(
      list: updatedList,
      favoriteList: updatedFavorites,
    );
  }

  Future<void> loadCharacters() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final data = await _getCharacters(state.page);
      final mergedList = [...state.list];
      var addedCount = 0;

      for (final character in data) {
        final existingIndex = mergedList.indexWhere((e) => e.id == character.id);
        if (existingIndex == -1) {
          mergedList.add(character);
          addedCount++;
        } else {
          mergedList[existingIndex] = character;
        }
      }

      state = state.copyWith(
        list: mergedList,
        isLoading: false,
        page: state.page + 1,
        hasMore: addedCount > 0,
        clearError: true,
      );
      _mergeLoadedFavorites();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load characters. Please try again.',
      );
    }
  }
}
