import 'package:flutter/material.dart';
import 'package:useless_kit/pages/converter/converter.dart';
import 'package:useless_kit/pages/home/delegate.dart';

class UnicodeConverterPage extends ConverterPage {
  const UnicodeConverterPage({Key? key})
      : super(
          key: key,
          encode: _encode,
          decode: _decode,
          decodedLabel: const Text('Plain Text'),
          encodedLabel: const Text('Hex'),
          hintText: 'Convert plain text into utf-8 hex string.',
          restorationId: 'unicode',
        );

  static const HomeContentDelegate delegate = HomeContentChildDelegate(
    destination: NavigationRailDestination(
      icon: Icon(Icons.abc),
      selectedIcon: Icon(Icons.abc),
      label: Text('Unicode'),
    ),
    child: UnicodeConverterPage(),
  );

  static final _regexp = RegExp(r'\\u([\da-f]+)');

  static ConverterData _encode(ConverterData data) {
    return data.copyWith(
      encoded: data.decoded.codeUnits
          .map(
            (e) => '\\u${e.toRadixString(16)}',
          )
          .join(),
    );
  }

  static ConverterData _decode(ConverterData data) {
    return data.copyWith(
      decoded: String.fromCharCodes(
        _regexp
            .allMatches(data.encoded)
            .map(
              (e) => int.parse(
                e[1]!,
                radix: 16,
              ),
            )
            .toList(),
      ),
    );
  }
}
