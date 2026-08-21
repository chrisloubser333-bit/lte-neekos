# Listen with Eve

Cross-platform Flutter app that lets you talk to Grok (xAI) in **English** or **Afrikaans**, with full voice input + voice replies and the ability to select default voices or teach/clone a custom voice.

**App name: Listen with Eve**

## Features

- Real-time voice conversations powered by xAI Grok Voice API
- Text chat fallback
- Language switching (English / Afrikaans)
- Default Grok voices (Eve, Ara, Leo, Rex, Sal + others)
- Custom voice cloning (record a sample and create a new voice)
- Clean, modern UI with dark mode support
- Chat history persisted locally

## Requirements

- Flutter 3.22+ / Dart 3.2+
- xAI API key from https://console.x.ai
- Android Studio / VS Code + Flutter extension
- For iOS: Xcode + CocoaPods

## Setup

1. Create a new Flutter project (or clone this folder structure):
   ```bash
   flutter create listen_with_eve
   cd listen_with_eve
   ```

2. Replace the generated files with the ones in this repository (especially `lib/` and `pubspec.yaml`).

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Add your xAI API key:
   - Open `lib/services/xai_service.dart`
   - Or better: use a `.env` file / secure storage (recommended for production)
   - For quick testing you can temporarily hard-code it (never commit real keys)

5. Run:
   ```bash
   flutter run
   ```

## Important Notes

- **Custom Voices** are currently limited geographically (mainly United States). The app includes the UI and API calls; if your region is restricted the feature will show an appropriate message.
- **Afrikaans** support uses language hints + system instructions. Quality is good but not yet at the same level as English.
- For production you should:
  - Use **ephemeral tokens** (never put the long-lived API key in the mobile app)
  - Add a small backend that issues short-lived client secrets
  - Handle microphone permissions carefully

## Project Structure

```
lib/
  main.dart                 # Entry point
  models/                   # Data models
  providers/                # State management
  screens/                  # UI screens
  services/                 # xAI API, audio, storage
  widgets/                  # Reusable widgets
```

## Next Steps After First Run

1. Test text chat
2. Grant microphone permission and test voice
3. Try switching language
4. Explore voice selection in Settings
5. (Optional) Record a custom voice sample

Enjoy talking to Grok!


## Eve real-time avatar architecture

The app now has a reusable `TalkingAvatar` surface. It is intentionally separated from chat/TTS so a future phoneme/viseme provider can drive the mouth animation without replacing the UI.

Current flow:

`user text -> selected Grok model -> response -> selected xAI voice -> audio playback -> TalkingAvatar speaking state`

Personalization:

- AI model selection is persisted.
- Built-in/custom voice selection is supported.
- Avatar Studio can capture a camera photo or select one from the gallery.
- The selected avatar path is persisted locally.
- Custom voice recording is wired to the xAI custom-voice adapter rather than a fake upload.

The current avatar animation is a speaking/pulse layer, not phoneme-accurate lip sync yet. The next layer should consume xAI TTS streaming timing metadata (`with_timestamps=true`) or a dedicated viseme/lip-sync engine and drive mouth shapes from those timings.

### Production security

Do not ship a long-lived xAI API key inside a production mobile app. Use a small backend to issue ephemeral xAI client secrets for Realtime connections and keep privileged API operations server-side.


## Eve avatar architecture

The avatar pipeline now calibrates a user-selected photo on-device using Google ML Kit face contours. The detected eye and lip geometry is cached for the avatar session, and xAI TTS timing drives the viseme layer during playback. ML Kit face detection is Android/iOS only; the rest of the chat and TTS architecture remains provider-neutral.

## Eve Memory & Intelligence v1

The project now includes the first persistent, model-agnostic Eve memory layer.

- `lib/models/eve_memory.dart` — structured memory records
- `lib/services/memory_manager.dart` — extraction, scoring, retrieval, reinforcement, decay and commands
- `lib/providers/memory_provider.dart` — UI state bridge
- `lib/screens/memory_screen.dart` — real memory management UI
- `lib/services/storage_service.dart` — encrypted memory/API-key storage
- `docs/EVE_MEMORY_IMPLEMENTATION_BLUEPRINT.md` — implementation details
- `docs/EVE_MEMORY_INTELLIGENCE_ARCHITECTURE.png` — approved architecture blueprint

The memory system is independent of the AI provider and avatar renderer, so the future Rive avatar and future model providers can be added without changing Eve's long-term memory format.
