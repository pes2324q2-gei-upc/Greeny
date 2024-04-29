import 'package:flutter/material.dart';
import 'package:greeny/app_state.dart';
import 'package:greeny/main_page.dart';
import 'package:provider/provider.dart';
import 'Registration/log_in.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greeny/API/requests.dart';

class TranslatePreferences implements ITranslatePreferences {
  static const String _selectedLocaleKey = 'selected_locale';

  @override
  Future<Locale?> getPreferredLocale() async {
    final preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey(_selectedLocaleKey)) return null;

    var locale = preferences.getString(_selectedLocaleKey);

    return localeFromString(locale!);
  }

  @override
  Future savePreferredLocale(Locale locale) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_selectedLocaleKey, localeToString(locale));
  }
}

Future<void> main() async {
  var delegate = await LocalizationDelegate.create(
      preferences: TranslatePreferences(),
      fallbackLocale: 'en_US',
      supportedLocales: ['en_US', 'es', 'ca']);

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
        home: FutureBuilder<Widget>(
          future: mainScreenIfUser(),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return snapshot.data ?? Container();
              }
            }
          },
        ),
      ),
    );
  }
}

Future<Widget> mainScreenIfUser() async {
  String token = await getToken();
  
  if (token != '') {
    return const MainPage();
  } else {
    return const LogInPage();
  }
}
