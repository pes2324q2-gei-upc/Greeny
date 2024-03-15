/* import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greeny/appState.dart';
import 'package:provider/provider.dart';
import 'package:greeny/City/city.dart'; // Asegúrate de importar correctamente tu archivo CityPage

void main() {
  testWidgets('Test de botó de play', (WidgetTester tester) async {
    // Construye la UI con CityPage envuelto en un ChangeNotifierProvider
    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => AppState(), // Crea una instancia real de AppState
        child: CityPage(),/*  */
      ),
    ));

    // Ahora puedes escribir tus pruebas aquí
    // Por ejemplo, puedes buscar widgets específicos en la pantalla y realizar aserciones sobre ellos
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    // Toca el botón de play
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    // Verifica que el botón de play se haya actualizado a pausa
    expect(find.byKey(const Key('pause_icon_key')), findsOneWidget);
  });

  testWidgets('Test de comprovarUbicacio()', (WidgetTester tester) async {
    // Simula que los servicios de ubicación están habilitados
    LocationServiceMock.locationServiceEnabled = true;
    // Simula que el permiso de ubicación está otorgado
    LocationServiceMock.locationPermission = LocationPermission.always;

    // Ejecuta la función comprovarUbicacio()
    bool result = await comprovarUbicacio();

    // Comprueba que la función devuelve true
    expect(result, true);
  });
}

// Mock de LocationService para simular respuestas de Geolocator
class LocationServiceMock {
  static bool locationServiceEnabled = false;
  static LocationPermission locationPermission = LocationPermission.denied;

  static Future<bool> isLocationServiceEnabled() async {
    return locationServiceEnabled;
  }

  static Future<LocationPermission> checkPermission() async {
    return locationPermission;
  }

  static Future<bool> openLocationSettings() async {
    // Simula abrir la configuración de ubicación
    locationServiceEnabled = true;
    return true;
  }

  static Future<LocationPermission> requestPermission() async {
    // Simula otorgar el permiso de ubicación
    locationPermission = LocationPermission.always;
    return locationPermission;
  }
}
 */