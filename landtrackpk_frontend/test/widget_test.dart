import 'package:flutter_test/flutter_test.dart';
import 'package:landtrackpk_frontend/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LandTrackPKApp());

    // Verify that the title is displayed on the splash screen.
    expect(find.text('LandTrack PK'), findsOneWidget);
  });
}
