import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greeny/City/city.dart';

void main() {
  testWidgets('CityPage UI Test', (WidgetTester tester) async {
    // Build our CityPage widget.
    await tester.pumpWidget(const MaterialApp(
      home: CityPage(),
    ));

    // Verify that the title 'Julia's City' is displayed.
    expect(find.text("Julia's City"), findsOneWidget);

    // Verify that the progress bar is displayed.
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Verify that the play button is displayed.
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Verify that the view history button is displayed.
    expect(find.byIcon(Icons.restore), findsOneWidget);
  });
}
