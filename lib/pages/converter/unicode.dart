import 'package:flutter/material.dart';
import 'package:useless_kit/pages/converter/converter.dart';
import 'package:useless_kit/pages/home/delegate.dart';

class UnicodeConverterPage extends ConverterPage {
  const UnicodeConverterPage({Key? key})
      : super(
          key: key,
          encode: _encode,
          decode: _decode,
          decodedLabel: const Text('Decoded'),
          encodedLabel: const Text('Encoded'),
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

  static DataGroup _encode(DataGroup data) {
    return data.copyWith(
      encoded: data.decoded.codeUnits
          .map(
            (e) => '\\u${e.toRadixString(16)}',
          )
          .join(),
    );
  }

  static DataGroup _decode(DataGroup data) {
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
