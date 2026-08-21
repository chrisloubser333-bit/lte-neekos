# Listen with Eve — Conversation Experience v1

## Implemented in this update

1. Introduced a central `EveConversationState`.
2. Added polished state/status UI for Ready, Listening, Thinking, Speaking and Error.
3. Added a static Eve avatar renderer with state-dependent glow/pulse.
4. Added a complete reference conversation screen.
5. Kept the avatar renderer isolated so `eve.riv` can replace it later.
6. Kept speech-to-text independent of the AI and TTS layers.
7. Preserved the existing ChatProvider/xAI/TTS architecture.

## Intended runtime

User microphone -> speech-to-text -> editable transcript -> existing ChatProvider.sendText()
-> existing xAI response -> existing TTS -> speaking state -> static Eve glow.

## Before release

- Run `flutter pub get`.
- Run `flutter analyze`.
- Run on a physical Android/iOS device.
- Verify microphone permission.
- Verify `en-ZA` speech recognition.
- Verify transcript editing.
- Verify AI response and TTS.
- Verify speaking state returns to idle.
- Confirm no API key is shipped in a public production build.

## Rive later

When `eve.riv` is available, implement the same `EveStaticAvatar` interface using Rive.
Do not change the conversation state model.
