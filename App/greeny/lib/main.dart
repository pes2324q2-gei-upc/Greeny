import 'package:flutter/material.dart';
import 'package:greeny/appState.dart';
import 'package:provider/provider.dart';
import 'Registration/log_in.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en_US', supportedLocales: ['en_US', 'es', 'ca']);

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: LocalizedApp(
        delegate,
        const Greeny(),
      ),
    ),
  );
}

class Greeny extends StatelessWidget {
  const Greeny({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: 'Greeny',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 1, 167, 164)),
          useMaterial3: true,
        ),
        home: const LogInPage(),
      ),
    );
  }
}
