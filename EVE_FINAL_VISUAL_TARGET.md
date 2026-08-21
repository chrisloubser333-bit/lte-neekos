# Listen with Eve — Final Conversation Experience Visual Target

The supplied polished mobile mockup is now the canonical visual target for the Conversation Experience.

Reference asset:
`docs/FINAL_CONVERSATION_EXPERIENCE_VISUAL_TARGET.png`

## Non-negotiable visual direction

- Portrait mobile-first layout.
- Deep near-black indigo background with subtle radial violet ambience.
- Premium violet / magenta accent lighting.
- "Listen with Eve" centered header with Eve highlighted in magenta.
- Green LIVE indicator.
- Large front-facing Eve hero occupying the upper-middle screen.
- Circular violet halo behind Eve.
- Audio waveform running horizontally behind/around the avatar.
- Rounded glass status card: Ready to talk / Listening / Eve is thinking / Eve is speaking.
- Conversation bubbles below the avatar with Eve's avatar thumbnail.
- Eve response includes a playable voice waveform.
- Speaking strip appears immediately above the composer.
- Large glowing microphone is the primary voice action.
- Keyboard and Voice controls flank the microphone.
- Rounded message composer with a prominent circular send button.
- Bottom navigation: Chat / Models / Voices / Profile.
- Generous spacing, soft borders, subtle glow, high contrast typography.

## Behavior mapped to the visual

IDLE:
- LIVE indicator visible.
- Eve neutral.
- Status: Ready to talk.
- Microphone says Tap to speak.

LISTENING:
- Eve halo/waveform becomes active.
- Microphone changes to stop.
- Status: Listening…
- Live transcript appears in the composer.

PROCESSING:
- Microphone disabled.
- Status: Eve is thinking…
- Subtle avatar halo remains active.

SPEAKING:
- Status: Eve is speaking.
- Voice waveform animates.
- Eve hero gets stronger ambient glow.
- TTS playback controls show active state.

## Rive migration

The visual target does not depend on Rive.

When `eve.riv` is ready, the Rive renderer replaces the temporary static hero inside `EveHeroAvatar`. The screen layout, state machine integration and conversation UX remain unchanged.

Rive inputs should map to the existing conversation states and the existing viseme stream.
