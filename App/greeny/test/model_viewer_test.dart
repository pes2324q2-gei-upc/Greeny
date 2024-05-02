/*import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

//import 'package:greeny/main.dart';
import 'package:greeny/City/city.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: CityPage(),
    ));

    /*await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
    await tester.pump();

    await tester.tap(find.widgetWithText(NavigationDestination, 'City'));
    await tester.pump();*/

    //final modelViewerFinder = find.byKey(const Key('cityModelViewer'));

    //expect(modelViewerFinder, findsOneWidget);

    //final ModelViewer modelViewer = tester.widget(modelViewerFinder);
    //expect(modelViewer.src, 'assets/cities/city_1.glb');

    
    expect(find.byKey(const Key('cityModelViewer')), findsOneWidget);
  });
}*/
