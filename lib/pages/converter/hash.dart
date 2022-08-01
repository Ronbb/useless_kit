import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:useless_kit/pages/converter/converter.dart';
import 'package:useless_kit/pages/home/delegate.dart';

class HashPage extends StatefulWidget {
  const HashPage({Key? key}) : super(key: key);

  static const HomeContentDelegate delegate = HomeContentBuilderDelegate(
    destination: NavigationRailDestination(
      icon: Icon(Icons.numbers),
      selectedIcon: Icon(Icons.numbers),
      label: Text('Hash'),
    ),
    builder: _builder,
  );

  static Widget _builder(context) => const HashPage();

  @override
  State<HashPage> createState() => _HashPageState();
}

class _HashPageState extends State<HashPage> {
  late Algorithm _algorithm = algorithms.first;

  final algorithms = [
    const AlgorithmSha1(),
    const AlgorithmSha224(),
    const AlgorithmSha256(),
    const AlgorithmSha384(),
    const AlgorithmSha512(),
  ];

  Algorithm get algorithm {
    return _algorithm;
  }

  Future<ConverterData> _encode(ConverterData data) async {
    return algorithm.hash(data);
  }

  @override
  Widget build(BuildContext context) {
    return ConverterPage(
      restorationId: 'hash',
      hintText: 'Compute hash for plain text.',
      decodedLabel: const Text('Plain Text'),
      encodedLabel: const Text('Hash'),
      encode: _encode,
      prefixActions: [
        DropdownButton<Algorithm>(
          value: _algorithm,
          items: [
            for (final algorithm in algorithms)
              DropdownMenuItem(
                value: algorithm,
                child: Text(algorithm.name),
              ),
          ],
          onChanged: (algorithm) {
            if (algorithm == null) {
              return;
            }
            setState(() {
              _algorithm = algorithm;
            });
          },
        )
      ],
    );
  }
}

abstract class Algorithm {
  const Algorithm();

  String get name;

  Future<ConverterData> hash(ConverterData data);
}

abstract class AlgorithmHash extends Algorithm {
  const AlgorithmHash();

  HashAlgorithm get algorithm;

  @override
  Future<ConverterData> hash(ConverterData data) async {
    final hash = await algorithm.hash(
      utf8.encode(data.decoded),
    );

    return data.copyWith(encoded: base64.encode(hash.bytes));
  }
}

class AlgorithmSha1 extends AlgorithmHash {
  const AlgorithmSha1();

  static final _algorithm = Sha1();

  @override
  HashAlgorithm get algorithm => _algorithm;

  @override
  final String name = 'SHA1';
}

class AlgorithmSha224 extends AlgorithmHash {
  const AlgorithmSha224();

  static final _algorithm = Sha224();

  @override
  HashAlgorithm get algorithm => _algorithm;

  @override
  final String name = 'SHA2-224';
}

class AlgorithmSha256 extends AlgorithmHash {
  const AlgorithmSha256();

  static final _algorithm = Sha256();

  @override
  HashAlgorithm get algorithm => _algorithm;

  @override
  final String name = 'SHA2-256';
}

class AlgorithmSha384 extends AlgorithmHash {
  const AlgorithmSha384();

  static final _algorithm = Sha384();

  @override
  HashAlgorithm get algorithm => _algorithm;

  @override
  final String name = 'SHA2-384';
}

class AlgorithmSha512 extends AlgorithmHash {
  const AlgorithmSha512();

  static final _algorithm = Sha512();

  @override
  HashAlgorithm get algorithm => _algorithm;

  @override
  final String name = 'SHA2-512';
}
