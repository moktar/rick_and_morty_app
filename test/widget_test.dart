import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_app/features/characters/presentation/providers/character_provider.dart';

void main() {
  test('CharacterState defaults are valid', () {
    final state = CharacterState();

    expect(state.list, isEmpty);
    expect(state.isLoading, isFalse);
    expect(state.page, 1);
  });
}
