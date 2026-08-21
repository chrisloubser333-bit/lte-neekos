# User Voice-to-Text — Integrated into v6

This update connects the existing microphone button on `ChatScreen` to a real
speech-to-text service.

Flow:

Microphone → speech recognition → live transcript → text field → Send → existing ChatProvider → xAI model → existing Eve TTS.

## What changed

- Added `speech_to_text: ^7.4.0`.
- Added `EveSpeechToTextService`.
- `ChatProvider` now owns the speech-to-text state.
- Existing `VoiceButton` is now functional.
- While listening, the input hint changes to `Listening…`.
- When the user stops speaking, the recognized transcript is placed into the existing message field.
- The user can edit the transcript before sending.
- The existing `sendText()` path remains the single AI submission path.
- English uses `en-ZA`; Afrikaans uses `af-ZA`.
- Android microphone permission and speech-recognition service query were added.
- iOS microphone and speech-recognition usage descriptions were added.

## Build

Run:

```bash
flutter pub get
flutter analyze
flutter run
```

On first microphone use, Android/iOS should request permission.

## Important

This is intentionally user-side speech-to-text, not the xAI realtime audio path.
That makes it immediately usable with the existing text chat + TTS architecture,
while leaving the future realtime voice WebSocket as a separate upgrade.

The temporary static Eve avatar continues to work unchanged.
