import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:useless_kit/platform/platform.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = GetIt.instance<GoRouter>();

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: Colors.blueGrey,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: TextStyle(height: 0.5),
      ),
      cardTheme: const CardTheme(
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      fontFamily: defaultFontFamily,
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.lightBlue,
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: TextStyle(height: 0.5),
      ),
      cardTheme: const CardTheme(
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      fontFamily: defaultFontFamily,
    );

    return MaterialApp.router(
      title: 'Useless Kit',
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: defaultLocale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
