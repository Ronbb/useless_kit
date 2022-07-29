import 'package:flutter/material.dart';
import 'package:useless_kit/app.dart';
import 'package:useless_kit/inject.dart';

Future<void> main() async {
  await inject();
  runApp(const App());
}
