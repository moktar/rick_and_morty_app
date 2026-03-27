import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/character_provider.dart';
import 'character_details_screen.dart';
import '../widgets/character_card.dart';

class CharacterListScreen extends ConsumerStatefulWidget {
  const CharacterListScreen({super.key});

  @override
  ConsumerState<CharacterListScreen> createState() =>
      _CharacterListScreenState();
}

class _CharacterListScreenState
    extends ConsumerState<CharacterListScreen> {
  static const _paginationThreshold = 200.0;
  static const _searchDebounceDuration = Duration(milliseconds: 250);

  final scrollController = ScrollController();
  final searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  Future<void> _showFilterSheet(
    BuildContext context,
    CharacterState state,
  ) async {
    final statusOptions = state.list
        .map((character) => character.status.trim())
        .where((status) => status.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final speciesOptions = state.list
        .map((character) => character.species.trim())
        .where((species) => species.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    String? tempStatus = state.selectedStatus;
    String? tempSpecies = state.selectedSpecies;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: tempStatus == null,
                          onSelected: (_) => setModalState(() => tempStatus = null),
                        ),
                        ...statusOptions.map(
                          (status) => FilterChip(
                            label: Text(status),
                            selected: tempStatus == status,
                            onSelected: (_) =>
                                setModalState(() => tempStatus = status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Species',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: tempSpecies == null,
                          onSelected: (_) => setModalState(() => tempSpecies = null),
                        ),
                        ...speciesOptions.map(
                          (species) => FilterChip(
                            label: Text(species),
                            selected: tempSpecies == species,
                            onSelected: (_) =>
                                setModalState(() => tempSpecies = species),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempStatus = null;
                              tempSpecies = null;
                            });
                          },
                          child: const Text('Clear'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            final notifier = ref.read(characterProvider.notifier);
                            notifier.setSelectedStatus(tempStatus);
                            notifier.setSelectedSpecies(tempSpecies);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(characterProvider.notifier).loadCharacters();
    });

    scrollController.addListener(() {
      final currentState = ref.read(characterProvider);
      final isNearBottom = scrollController.position.pixels >=
          (scrollController.position.maxScrollExtent - _paginationThreshold);

      if (isNearBottom && !currentState.isLoading && currentState.hasMore) {
        ref.read(characterProvider.notifier).loadCharacters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterProvider);

    final filteredList = state.list.where((character) {
      final matchQuery = state.searchQuery.trim().isEmpty ||
          character.name
              .toLowerCase()
              .contains(state.searchQuery.toLowerCase().trim());
      final matchStatus = state.selectedStatus == null ||
          character.status == state.selectedStatus;
      final matchSpecies = state.selectedSpecies == null ||
          character.species == state.selectedSpecies;
      return matchQuery && matchStatus && matchSpecies;
    }).toList();

    if (state.isLoading && state.list.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Characters"),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.errorMessage != null && state.list.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Characters"),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.read(characterProvider.notifier).loadCharacters();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Characters"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    _searchDebounceTimer?.cancel();
                    _searchDebounceTimer = Timer(
                      _searchDebounceDuration,
                      () {
                        if (!mounted) return;
                        ref.read(characterProvider.notifier).setSearchQuery(value);
                      },
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Search characters',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state.searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              searchController.clear();
                              ref.read(characterProvider.notifier).setSearchQuery('');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (state.selectedStatus != null)
                              Chip(
                                label: Text('Status: ${state.selectedStatus}'),
                                backgroundColor: Colors.grey.shade200,
                              ),
                            if (state.selectedStatus != null) const SizedBox(width: 8),
                            if (state.selectedSpecies != null)
                              Chip(
                                label: Text('Species: ${state.selectedSpecies}'),
                                backgroundColor: Colors.grey.shade200,
                              ),
                            if (state.selectedSpecies != null) const SizedBox(width: 8),
                            if (state.selectedStatus != null ||
                                state.selectedSpecies != null)
                              ActionChip(
                                label: const Text('Clear'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primaryContainer,
                                labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                                onPressed: () {
                                  ref.read(characterProvider.notifier).clearFilters();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Filter',
                      onPressed: () => _showFilterSheet(context, state),
                      icon: const Icon(Icons.filter_alt_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: state.list.isEmpty
                ? const Center(
                    child: Text('No characters available yet'),
                  )
                : filteredList.isEmpty
                    ? const Center(
                        child: Text('No characters found'),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filteredList.length +
                            ((state.isLoading || state.errorMessage != null)
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index >= filteredList.length) {
                            if (state.errorMessage != null) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        state.errorMessage!,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(characterProvider.notifier)
                                            .loadCharacters();
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final character = filteredList[index];

                          return CharacterCard(
                            character: character,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CharacterDetailsScreen(
                                    character: character,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
