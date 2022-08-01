import 'package:hive_flutter/hive_flutter.dart';
import 'package:useless_kit/pages/converter/converter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ConverterDataAdapter());
  await ConverterPage.openBox();
}
