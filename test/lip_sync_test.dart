import 'package:flutter_test/flutter_test.dart';
import 'package:listen_with_eve/models/lip_sync.dart';

void main() {
  test('maps common characters to stable visemes', () {
    expect(visemeForCharacter('a'), 'open');
    expect(visemeForCharacter('e'), 'wide');
    expect(visemeForCharacter('o'), 'round');
    expect(visemeForCharacter('m'), 'closed');
    expect(visemeForCharacter(' '), 'rest');
    expect(visemeForCharacter('.'), 'rest');
  });

  test('cue contains its timing interval', () {
    const cue = LipSyncCue(
      viseme: 'open',
      start: Duration(milliseconds: 100),
      end: Duration(milliseconds: 200),
    );
    expect(cue.contains(const Duration(milliseconds: 150)), isTrue);
    expect(cue.contains(const Duration(milliseconds: 250)), isFalse);
  });
}
