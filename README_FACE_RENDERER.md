# Eve face renderer

The current avatar pipeline has three layers:

1. ML Kit detects facial contours once when the user's avatar photo changes.
2. `DeformableAvatar` renders the photo through a textured mesh and applies small
   local deformations around the detected mouth and eyes in real time.
3. TTS character timing drives the viseme state used by the mesh.

## Rive hand-off contract

The project keeps a stable renderer contract in `lib/widgets/rive_face_contract.dart`.
A future `.riv` asset should expose a state machine with these numeric inputs:

- `mouthOpen` 0..1
- `mouthWidth` -1..1
- `mouthRound` 0..1
- `blink` 0..1
- `speaking` 0..1
- `emotion` 0..1 (reserved)

Rive Flutter 0.14.x uses `RiveWidget`/`RiveWidgetBuilder` and
`RiveWidgetController` for runtime graphics and state-machine control.

The photo mesh remains the default renderer until a real `.riv` facial asset is
created. This avoids shipping a fake/empty Rive asset and keeps arbitrary user
photos working now.
