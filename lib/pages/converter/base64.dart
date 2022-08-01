import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:useless_kit/pages/converter/converter.dart';
import 'package:useless_kit/pages/home/delegate.dart';

class Base64ConverterPage extends ConverterPage {
  const Base64ConverterPage({Key? key})
      : super(
          key: key,
          encode: _encode,
          decode: _decode,
          decodedLabel: const Text('Plain Text'),
          encodedLabel: const Text('Encoded'),
          hintText:
              'Convert plain text into base64 format with encoding utf-8.',
          restorationId: 'base64',
        );

  static const HomeContentDelegate delegate = HomeContentChildDelegate(
    destination: NavigationRailDestination(
      icon: Icon(Icons.swap_horiz_outlined),
      selectedIcon: Icon(Icons.swap_horiz_outlined),
      label: Text('Base64'),
    ),
    child: Base64ConverterPage(),
  );

  static ConverterData _encode(ConverterData data) {
    return data.copyWith(
      encoded: base64.encode(
        utf8.encode(data.decoded),
      ),
    );
  }

  static ConverterData _decode(ConverterData data) {
    return data.copyWith(
      decoded: utf8.decode(
        base64.decode(data.encoded),
      ),
    );
  }
}
