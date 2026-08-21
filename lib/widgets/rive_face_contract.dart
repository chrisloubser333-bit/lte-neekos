/// Contract for the future Rive facial renderer.
///
/// The Flutter app already exposes the inputs needed by a Rive state machine.
/// A .riv asset can later bind these names to actual facial deformation:
///
///   mouthOpen   0..1
///   mouthWidth  -1..1
///   mouthRound  0..1
///   blink       0..1
///   speaking    0..1
///   emotion     0..1 (reserved)
///
/// Keeping this contract stable means the TTS/ML layers do not need to know
/// whether Eve is rendered by the current textured mesh, Rive, or another
/// avatar renderer.
class RiveFaceContract {
  static const mouthOpen = 'mouthOpen';
  static const mouthWidth = 'mouthWidth';
  static const mouthRound = 'mouthRound';
  static const blink = 'blink';
  static const speaking = 'speaking';
  static const emotion = 'emotion';
}
