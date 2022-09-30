import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart' hide State;
import 'package:pointycastle/pointycastle.dart';
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
    const AlgorithmRsaOaepSha256(),
  ];

  Algorithm get algorithm {
    return _algorithm;
  }

  Future<ConverterData> _decode(ConverterData data) async {
    return algorithm.decrypt(data);
  }

  Future<ConverterData> _encode(ConverterData data) async {
    return algorithm.encrypt(data);
  }

  @override
  Widget build(BuildContext context) {
    return ConverterPage(
      restorationId: 'crypto',
      hintText: 'Crypto',
      extraDecodedItems: algorithm.extraDecodedItems,
      extraEncodedItems: algorithm.extraEncodedItems,
      decodedLabel: const Text('Plain Text'),
      encodedLabel: const Text('Cipher Text'),
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

  List<ConverterExtraItem> get extraDecodedItems => const [];

  List<ConverterExtraItem> get extraEncodedItems => const [];

  Future<ConverterData> decrypt(ConverterData data);

  Future<ConverterData> encrypt(ConverterData data);

  bool get enableDecryption => false;

  bool get enableEncryption => false;
}

// for library cryptography AES
abstract class AlgorithmCipher extends Algorithm {
  const AlgorithmCipher();

  Cipher get algorithm;

  List<int> get nonce => List.filled(algorithm.nonceLength, 0);

  String get kKey => 'Key';

  @override
  bool get enableDecryption => true;

  @override
  bool get enableEncryption => true;

  @override
  List<ConverterExtraItem> get extraDecodedItems => [
        ConverterExtraItem(
          key: kKey,
          label: const Text('Key'),
        ),
      ];

  @override
  Future<ConverterData> decrypt(ConverterData data) async {
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
  Future<ConverterData> encrypt(ConverterData data) async {
    final key = data.extraDecodedData[kKey]!;
    final secretBox = await algorithm.encrypt(
      utf8.encode(data.decoded),
      nonce: nonce,
      secretKey: SecretKey(utf8.encode(key)),
    );

    return data.copyWith(encoded: base64.encode(secretBox.cipherText));
  }
}

// for library pointycastle RSA
abstract class AlgorithmCipher2 extends Algorithm {
  const AlgorithmCipher2();

  AsymmetricBlockCipher get algorithm;

  String get kPublicKey => 'PublicKey';

  String get kPrivateKey => 'PrivateKey';

  @override
  bool get enableEncryption => true;

  @override
  bool get enableDecryption => true;

  @override
  List<ConverterExtraItem> get extraDecodedItems => [
        ConverterExtraItem(
          key: kPublicKey,
          label: const Text('PublicKey'),
        ),
        ConverterExtraItem(
          key: kPrivateKey,
          label: const Text('PrivateKey'),
        ),
      ];

  @override
  Future<ConverterData> encrypt(ConverterData data) async {
    final key = data.extraDecodedData[kPublicKey]!;
    final publicKey = RSAKeyParser().parse(key) as RSAPublicKey;

    algorithm.reset();
    algorithm.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    final encrypted = algorithm.process(
      Uint8List.fromList(
        utf8.encode(data.decoded),
      ),
    );

    return data.copyWith(encoded: base64.encode(encrypted));
  }

  @override
  Future<ConverterData> decrypt(ConverterData data) async {
    final key = data.extraDecodedData[kPrivateKey]!;
    final privateKey = RSAKeyParser().parse(key) as RSAPrivateKey;

    algorithm.reset();
    algorithm.init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final decrypted = algorithm.process(base64.decode(data.encoded));
    return data.copyWith(decoded: utf8.decode(decrypted));
  }
}

/// RSA PEM parser.
class RSAKeyParser {
  static RSAAsymmetricKey parseFromString(String key) {
    RSAKeyParser rsaKeyParser = RSAKeyParser();
    return rsaKeyParser.parse(key);
  }

  /// Parses the PEM key no matter it is public or private, it will figure it out.
  RSAAsymmetricKey parse(String key) {
    final rows = key.split(RegExp(r'\r\n?|\n'));
    final header = rows.first;

    if (header == '-----BEGIN RSA PUBLIC KEY-----') {
      return _parsePublic(_parseSequence(rows));
    }

    if (header == '-----BEGIN PUBLIC KEY-----') {
      return _parsePublic(_pkcs8PublicSequence(_parseSequence(rows)));
    }

    if (header == '-----BEGIN RSA PRIVATE KEY-----') {
      return _parsePrivate(_parseSequence(rows));
    }

    if (header == '-----BEGIN PRIVATE KEY-----') {
      return _parsePrivate(_pkcs8PrivateSequence(_parseSequence(rows)));
    }

    throw FormatException('Unable to parse key, invalid format.', header);
  }

  /// 0 modulus(n), 1 publicExponent(e)
  RSAAsymmetricKey _parsePublic(ASN1Sequence sequence) {
    final List<ASN1Integer> asn1IntList =
        sequence.elements!.cast<ASN1Integer>();
    final modulus = asn1IntList.elementAt(0).integer;
    final exponent = asn1IntList.elementAt(1).integer;
    return RSAPublicKey(modulus!, exponent!);
  }

  /// 0 version, 1 modulus(n), 2 publicExponent(e), 3 privateExponent(d), 4 prime1(p), 5 prime2(q)
  /// 6 exponent1(d mod (p-1)), 7 exponent2 (d mod (q-1)), 8 coefficient
  RSAAsymmetricKey _parsePrivate(ASN1Sequence sequence) {
    final List<ASN1Integer> asn1IntList =
        sequence.elements!.cast<ASN1Integer>();
    final modulus = asn1IntList.elementAt(1).integer;
    final exponent = asn1IntList.elementAt(3).integer;
    final p = asn1IntList.elementAt(4).integer;
    final q = asn1IntList.elementAt(5).integer;
    return RSAPrivateKey(modulus!, exponent!, p, q);
  }

  ASN1Sequence _parseSequence(List<String> rows) {
    final keyText = rows
        .skipWhile((row) => row.startsWith('-----BEGIN'))
        .takeWhile((row) => !row.startsWith('-----END'))
        .map((row) => row.trim())
        .join('');

    final keyBytes = Uint8List.fromList(base64.decode(keyText));
    final asn1Parser = ASN1Parser(keyBytes);

    return asn1Parser.nextObject() as ASN1Sequence;
  }

  ASN1Sequence _pkcs8PublicSequence(ASN1Sequence sequence) {
    final ASN1Object bitString = sequence.elements![1];
    final bytes = bitString.valueBytes!.sublist(1);
    final parser = ASN1Parser(Uint8List.fromList(bytes));

    return parser.nextObject() as ASN1Sequence;
  }

  ASN1Sequence _pkcs8PrivateSequence(ASN1Sequence sequence) {
    final ASN1Object bitString = sequence.elements![2];
    final bytes = bitString.valueBytes!;
    final parser = ASN1Parser(bytes);

    return parser.nextObject() as ASN1Sequence;
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

class AlgorithmRsaOaepSha256 extends AlgorithmCipher2 {
  const AlgorithmRsaOaepSha256();

  static final _algorithm = OAEPEncoding(RSAEngine());

  @override
  AsymmetricBlockCipher get algorithm => _algorithm;

  @override
  final String name = 'RSA-OAEP-SHA256';
}
