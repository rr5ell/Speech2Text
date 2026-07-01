import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text_sherpa/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SpeechToTextApp());
    expect(find.text('Speed_to_Text'), findsOneWidget);
  });
}
