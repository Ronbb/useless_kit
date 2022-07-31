import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:useless_kit/pages/converter/converter.dart';
import 'package:useless_kit/pages/home/delegate.dart';

class Base64ConverterPage extends ConverterPage {
  const Base64ConverterPage({Key? key})
      : super(key: key, encode: _encode, decode: _decode);

  static const HomeContentDelegate delegate = HomeContentChildDelegate(
    destination: NavigationRailDestination(
      icon: Icon(Icons.transform),
      selectedIcon: Icon(Icons.transform),
      label: Text('Base64'),
    ),
    child: Base64ConverterPage(),
  );

  static DataGroup _encode(DataGroup data) {
    return data.copyWith(
      encoded: base64.encode(
        utf8.encode(data.decoded),
      ),
    );
  }

  static DataGroup _decode(DataGroup data) {
    return data.copyWith(
      decoded: utf8.decode(
        base64.decode(data.encoded),
      ),
    );
  }
}
