# Rick and Morty Character Explorer

## Setup Instructions

### Prerequisites
- Flutter SDK (stable channel)
- Dart SDK (bundled with Flutter)
- Android Studio or VS Code with Flutter plugins
- Android emulator or physical device

### Run Locally
1. Open the project folder:
   ```bash
   cd /Users/moktar/AndroidStudioProjects/rick_and_morty_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Optional Validation
- Static analysis:
  ```bash
  flutter analyze
  ```
- Tests:
  ```bash
  flutter test
  ```

---

## State Management Choice

This project uses **Riverpod (`StateNotifierProvider`)**.

### Why this choice
- Keeps state immutable and predictable (`CharacterState` + `copyWith`).
- Separates UI from business logic through a notifier.
- Works well with dependency injection (providers for use cases and repository).
- Easy to scale for search, filters, favorites, pagination, and local edits in one consistent flow.

---

## Storage Approach

Local persistence uses **Hive** with three boxes:

- `character_box`:
  - Stores base API character data (cache).
- `override_box`:
  - Stores user-local edits (name/status/species/type/gender/origin/location).
- `favorites_box`:
  - Stores favorite characters for offline availability.

### Runtime merge strategy
1. Load API data (or cached data if offline/failure).
2. Load local override by character id.
3. Merge at runtime so override values take precedence over base API values.
4. UI always renders merged result.

This ensures edited data and favorites remain available after restart and during offline usage.

---

## Known Limitations

- Pagination stop is inferred by “no newly added unique items” instead of API metadata (`next`), which is practical but not perfect for all APIs.
- Error messaging is user-friendly but minimal (single generic load failure message).
- Test coverage is currently basic and should be expanded for:
  - offline/cache behavior
  - merge logic
  - favorites/edit persistence
  - pagination/filter edge cases
- Local edits are intentionally device-local only (no server sync/write-back).
