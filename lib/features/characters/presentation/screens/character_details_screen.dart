import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/character_entity.dart';
import '../providers/character_provider.dart';

class CharacterDetailsScreen extends ConsumerStatefulWidget {
  final CharacterEntity character;

  const CharacterDetailsScreen({
    super.key,
    required this.character,
  });

  @override
  ConsumerState<CharacterDetailsScreen> createState() =>
      _CharacterDetailsScreenState();
}

class _CharacterDetailsScreenState extends ConsumerState<CharacterDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _statusController;
  late final TextEditingController _speciesController;
  late final TextEditingController _typeController;
  late final TextEditingController _genderController;
  late final TextEditingController _originController;
  late final TextEditingController _locationController;

  bool _isEditing = false;

  String _displayValue(String value) {
    return value.trim().isEmpty ? 'Unknown' : value;
  }

  CharacterEntity _resolveCharacter(CharacterState state) {
    for (final item in state.list) {
      if (item.id == widget.character.id) return item;
    }
    for (final item in state.favoriteList) {
      if (item.id == widget.character.id) return item;
    }
    return widget.character;
  }

  void _setControllers(CharacterEntity character) {
    _nameController.text = character.name;
    _statusController.text = character.status;
    _speciesController.text = character.species;
    _typeController.text = character.type;
    _genderController.text = character.gender;
    _originController.text = character.origin;
    _locationController.text = character.location;
  }

  String _requiredValue(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _statusController = TextEditingController();
    _speciesController = TextEditingController();
    _typeController = TextEditingController();
    _genderController = TextEditingController();
    _originController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    _speciesController.dispose();
    _typeController.dispose();
    _genderController.dispose();
    _originController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(characterProvider);
    final notifier = ref.read(characterProvider.notifier);
    final character = _resolveCharacter(state);
    final isFavorite = state.favoriteIds.contains(widget.character.id);

    if (!_isEditing) {
      _setControllers(character);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _setControllers(character);
                });
              },
              icon: const Icon(Icons.close),
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
          if (_isEditing)
            IconButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                final updatedCharacter = CharacterEntity(
                  id: character.id,
                  name: _requiredValue(_nameController.text, character.name),
                  status: _requiredValue(_statusController.text, character.status),
                  species: _requiredValue(
                    _speciesController.text,
                    character.species,
                  ),
                  type: _typeController.text.trim(),
                  gender: _requiredValue(_genderController.text, character.gender),
                  origin: _requiredValue(_originController.text, character.origin),
                  location: _requiredValue(
                    _locationController.text,
                    character.location,
                  ),
                  image: character.image,
                );

                await notifier.updateCharacter(updatedCharacter);
                if (!mounted) return;
                setState(() {
                  _isEditing = false;
                });
              },
              icon: const Icon(Icons.save),
            ),
          IconButton(
            onPressed: () async {
              await notifier.toggleFavorite(character);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  character.image,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.person, size: 80),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (_isEditing) ...[
                _EditField(
                  controller: _nameController,
                  label: 'Name',
                  requiredField: true,
                ),
                _EditField(
                  controller: _statusController,
                  label: 'Status',
                  requiredField: true,
                ),
                _EditField(
                  controller: _speciesController,
                  label: 'Species',
                  requiredField: true,
                ),
                _EditField(controller: _typeController, label: 'Type'),
                _EditField(
                  controller: _genderController,
                  label: 'Gender',
                  requiredField: true,
                ),
                _EditField(
                  controller: _originController,
                  label: 'Origin',
                  requiredField: true,
                ),
                _EditField(
                  controller: _locationController,
                  label: 'Location',
                  requiredField: true,
                ),
              ] else ...[
                _DetailRow(title: 'Name', value: character.name),
                _DetailRow(title: 'Status', value: character.status),
                _DetailRow(title: 'Species', value: character.species),
                _DetailRow(title: 'Type', value: _displayValue(character.type)),
                _DetailRow(title: 'Gender', value: character.gender),
                _DetailRow(title: 'Origin', value: _displayValue(character.origin)),
                _DetailRow(
                  title: 'Location',
                  value: _displayValue(character.location),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool requiredField;

  const _EditField({
    required this.controller,
    required this.label,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        validator: requiredField
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge,
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
