/// A timed mouth cue derived from xAI's character-level TTS timestamps.
class LipSyncCue {
  final String viseme;
  final Duration start;
  final Duration end;

  const LipSyncCue({
    required this.viseme,
    required this.start,
    required this.end,
  });

  bool contains(Duration position) =>
      position >= start && position <= end;
}

/// Maps written characters to simple mouth shapes.
/// This is intentionally provider-agnostic so a phoneme/viseme engine can
/// replace it later without changing the rest of the app.
String visemeForCharacter(String char) {
  final c = char.toLowerCase();
  if (c.trim().isEmpty || RegExp(r'[,.!?;:]').hasMatch(c)) return 'rest';
  if ('aáàâäã'.contains(c)) return 'open';
  if ('eéèêë'.contains(c)) return 'wide';
  if ('iíìîïy'.contains(c)) return 'smile';
  if ('oóòôöõ'.contains(c)) return 'round';
  if ('uúùûü'.contains(c)) return 'pucker';
  if ('bmp'.contains(c)) return 'closed';
  if ('fv'.contains(c)) return 'teeth';
  if ('kgq'.contains(c)) return 'open';
  if ('w'.contains(c)) return 'round';
  return 'neutral';
}
