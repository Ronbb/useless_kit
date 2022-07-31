import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = GetIt.instance<GoRouter>();

    return MaterialApp.router(
      title: 'Useless Kit',
      theme: ThemeData(
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
      ),
      locale: Locale(Platform.localeName.split('_')[0]),
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
