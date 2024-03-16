import 'package:flutter/material.dart';
import 'package:greeny/appState.dart';
import 'package:provider/provider.dart';
import 'Registration/log_in.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslatePreferences implements ITranslatePreferences
{
    static const String _selectedLocaleKey = 'selected_locale';

    @override
    Future<Locale?> getPreferredLocale() async
    {
        final preferences = await SharedPreferences.getInstance();

        if(!preferences.containsKey(_selectedLocaleKey)) return null;

        var locale = preferences.getString(_selectedLocaleKey);

        return localeFromString(locale!);
    }

    @override
    Future savePreferredLocale(Locale locale) async
    {
        final preferences = await SharedPreferences.getInstance();

        await preferences.setString(_selectedLocaleKey, localeToString(locale));
    }
}

Future<void> main() async {
  var delegate = await LocalizationDelegate.create(
    preferences: TranslatePreferences(),
      fallbackLocale: 'en_US', supportedLocales: ['en_US', 'es', 'ca']);

  await dotenv.load(fileName: ".env");
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
