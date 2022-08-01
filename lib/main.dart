import 'package:flutter/material.dart';
import 'package:useless_kit/app.dart';
import 'package:useless_kit/hive.dart';
import 'package:useless_kit/inject.dart';

Future<void> main() async {
  await initHive();
  await inject();
  runApp(const App());
}
