import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:useless_kit/pages/converter/converter.dart';
import 'package:useless_kit/pages/home/delegate.dart';

class CryptoPage extends StatefulWidget {
  const CryptoPage({Key? key}) : super(key: key);

  static const HomeContentDelegate delegate = HomeContentBuilderDelegate(
    destination: NavigationRailDestination(
      icon: Icon(Icons.lock_outline_rounded),
      selectedIcon: Icon(Icons.lock_rounded),
      label: Text('Crypto'),
    ),
    builder: _builder,
  );

  static Widget _builder(context) => const CryptoPage();

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  late Algorithm _algorithm = algorithms.first;

  final algorithms = [
    const AlgorithmAesCbc128(),
    const AlgorithmAesCbc192(),
    const AlgorithmAesCbc256(),
  ];

  Algorithm get algorithm {
    return _algorithm;
  }

  Future<DataGroup> _decode(DataGroup data) async {
    return algorithm.decrypt(data);
  }

  Future<DataGroup> _encode(DataGroup data) async {
    return algorithm.encrypt(data);
  }

  @override
  Widget build(BuildContext context) {
    return ConverterPage(
      hintText: 'AES with PKCS7 padding.',
      extraDecodedItems: algorithm.extraDecodedItems,
      extraEncodedItems: algorithm.extraEncodedItems,
      decodedLabel: const Text('PlainText'),
      encodedLabel: const Text('CipherText'),
      decode: _decode,
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

  List<ExtraItem> get extraDecodedItems => const [];

  List<ExtraItem> get extraEncodedItems => const [];

  Future<DataGroup> decrypt(DataGroup data);

  Future<DataGroup> encrypt(DataGroup data);
}

abstract class AlgorithmCipher extends Algorithm {
  const AlgorithmCipher();

  Cipher get algorithm;

  List<int> get nonce => List.filled(algorithm.nonceLength, 0);

  String get kKey => 'Key';

  @override
  List<ExtraItem> get extraDecodedItems => [
        ExtraItem(
          key: kKey,
          label: const Text('Key'),
        ),
      ];

  @override
  Future<DataGroup> decrypt(DataGroup data) async {
    final decodedCipherText = base64.decode(data.encoded);
    final key = data.extraDecodedData[kKey]!;
    final plainText = await algorithm.decrypt(
      SecretBox(
        decodedCipherText,
        nonce: nonce,
        mac: await algorithm.macAlgorithm.calculateMac(
          decodedCipherText,
          secretKey: SecretKey(utf8.encode(key)),
        ),
      ),
      secretKey: SecretKey(utf8.encode(key)),
    );

    return data.copyWith(decoded: utf8.decode(plainText));
  }

  @override
  Future<DataGroup> encrypt(DataGroup data) async {
    final key = data.extraDecodedData[kKey]!;
    final secretBox = await algorithm.encrypt(
      utf8.encode(data.decoded),
      nonce: nonce,
      secretKey: SecretKey(utf8.encode(key)),
    );

    return data.copyWith(encoded: base64.encode(secretBox.cipherText));
  }
}

class AlgorithmAesCbc128 extends AlgorithmCipher {
  const AlgorithmAesCbc128();

  static final _algorithm = AesCbc.with128bits(macAlgorithm: Hmac.sha256());

  @override
  Cipher get algorithm => _algorithm;

  @override
  final String name = 'AES-CBC-128';
}

class AlgorithmAesCbc192 extends AlgorithmCipher {
  const AlgorithmAesCbc192();

  static final _algorithm = AesCbc.with192bits(macAlgorithm: Hmac.sha256());

  @override
  Cipher get algorithm => _algorithm;

  @override
  final String name = 'AES-CBC-128';
}

class AlgorithmAesCbc256 extends AlgorithmCipher {
  const AlgorithmAesCbc256();

  static final _algorithm = AesCbc.with256bits(macAlgorithm: Hmac.sha256());

  @override
  Cipher get algorithm => _algorithm;

  @override
  final String name = 'AES-CBC-256';
}

class AlgorithmAesGcm128 extends AlgorithmCipher {
  const AlgorithmAesGcm128();

  static final _algorithm = AesGcm.with128bits();

  @override
  Cipher get algorithm => _algorithm;

  @override
  final String name = 'AES-GCM-128';
}
