# Listen with Eve — Polished Conversation UI v1

This update implements the supplied Conversation Experience visual direction.

## Visual system
- Deep indigo-black background
- Violet/pink glass surfaces
- LIVE indicator
- Large Eve hero/avatar area
- Animated halo + waveform
- Ready / Listening / Thinking / Speaking state pill
- Rounded glass composer
- Large central microphone action
- Keyboard / Voice controls
- Four-item bottom navigation
- Existing ChatProvider, speech-to-text, xAI and TTS are preserved

## Rive
The hero area is isolated in `EveHeroAvatar`. Once `eve.riv` is ready, replace the
static/default renderer inside this widget while preserving the same state inputs.

## Default Eve
The temporary neutral Eve image is bundled as `assets/eve_neutral.png`.
Custom user avatars still use the existing `TalkingAvatar` path.
