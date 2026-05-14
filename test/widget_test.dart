import 'package:flutter_test/flutter_test.dart';
import 'package:audiomood/main.dart';

void main() {
  testWidgets('AudioMood app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AudioMoodApp());
    expect(find.byType(AudioMoodApp), findsOneWidget);
  });
}
