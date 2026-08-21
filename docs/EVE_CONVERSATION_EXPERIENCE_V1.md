# Eve Conversation Experience v1

This milestone makes the static Eve avatar behave like a complete voice-first companion
while the production Rive avatar is being finished.

## State model

idle -> listening -> processing -> speaking -> idle

error can be entered from any state and returns to idle after retry/dismiss.

## UX

- Microphone clearly communicates listening.
- Live transcript remains editable.
- Send moves the app into processing.
- TTS playback moves the app into speaking.
- Static Eve gets a subtle state-dependent glow/pulse.
- Rive can later replace only the avatar renderer.

## Architecture

The avatar must not own AI/TTS/business logic.

ChatProvider remains responsible for:
- transcript
- message submission
- AI response
- TTS state

UI reads those states and maps them to EveConversationState.

## Rive migration

When eve.riv is ready, replace EveStaticAvatar with the Rive renderer.
Keep EveConversationState and the rest of the screen unchanged.
