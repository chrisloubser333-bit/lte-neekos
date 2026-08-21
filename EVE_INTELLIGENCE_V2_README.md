# Eve Intelligence v2

This package upgrades Eve's memory from heuristic-only extraction to AI-assisted memory intelligence.

## What changed

- Added `MemoryIntelligenceService`.
- Added structured `MemoryDecision` model.
- AI analyzes each normal user turn for durable memory operations.
- AI analysis runs in parallel with the normal response request.
- Existing memories are provided to the analyst as candidate context.
- AI can create, update, reinforce, forget or ignore memories.
- MemoryManager remains the persistence/lifecycle authority.
- Duplicate memories are consolidated through the existing similarity layer.
- Contradictory facts/preferences can be updated rather than duplicated.
- Explicit remember/forget commands continue to work deterministically.
- Added automated tests for structured AI decision parsing and application.
- App version bumped to 1.1.0+2.

## Run locally

```bash
flutter pub get
flutter analyze
flutter test
```

The supplied environment does not include Flutter/Dart, so those commands must be run on the Flutter development machine.

## Production note

The mobile app currently calls xAI directly for development. Before public release, route AI calls through a backend/ephemeral-token service so provider credentials are not exposed in the APK/IPA.
