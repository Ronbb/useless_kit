import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'converter.g.dart';

typedef ConverterExtraData = Map<String, String>;

typedef Converter = FutureOr<ConverterData> Function(ConverterData data);

@HiveType(typeId: 0)
class ConverterData {
  const ConverterData({
    required this.decoded,
    required this.encoded,
    required this.extraDecodedData,
    required this.extraEncodedData,
  });

  @HiveField(1)
  final String decoded;
  @HiveField(2)
  final String encoded;
  @HiveField(3)
  final ConverterExtraData extraDecodedData;
  @HiveField(4)
  final ConverterExtraData extraEncodedData;

  ConverterData copyWith({
    String? decoded,
    String? encoded,
    ConverterExtraData? extraDecodedData,
    ConverterExtraData? extraEncodedData,
  }) {
    return ConverterData(
      decoded: decoded ?? this.decoded,
      encoded: encoded ?? this.encoded,
      extraDecodedData: extraDecodedData ?? this.extraDecodedData,
      extraEncodedData: extraEncodedData ?? this.extraEncodedData,
    );
  }
}

class ConverterExtraItem {
  const ConverterExtraItem({
    required this.key,
    required this.label,
  });

  final String key;

  final Widget label;
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({
    Key? key,
    this.hintText,
    required this.restorationId,
    required this.decode,
    required this.encode,
    this.decodedLabel,
    this.encodedLabel,
    this.prefixActions = const [],
    this.suffixActions = const [],
    this.extraDecodedItems = const [],
    this.extraEncodedItems = const [],
  }) : super(key: key);

  final String restorationId;

  final String? hintText;

  final Converter decode;

  final Converter encode;

  final Widget? decodedLabel;

  final Widget? encodedLabel;

  final List<Widget> prefixActions;

  final List<Widget> suffixActions;

  final List<ConverterExtraItem> extraDecodedItems;

  final List<ConverterExtraItem> extraEncodedItems;

  static const _boxName = 'converter';

  static Box<ConverterData>? _box;

  static Future<void> openBox<ConverterData>() async {
    _box ??= await Hive.openBox(_boxName);
  }

  @override
  State<ConverterPage> createState() => ConverterPageState();
}

class ConverterPageState extends State<ConverterPage> {
  static const EdgeInsetsGeometry _cardPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 16,
  );

  Object? _error;

  late final ConverterData? _initData;

  final _extraDecodedControllers = <String, TextEditingController>{};
  final _extraEncodedControllers = <String, TextEditingController>{};

  late final TextEditingController _decodedTextController;
  late final TextEditingController _encodedTextController;

  Box<ConverterData> get box => ConverterPage._box!;

  set error(Object? error) {
    setState(() {
      _error = error;
    });
  }

  String get decoded {
    return _decodedTextController.text;
  }

  set decoded(String decoded) {
    _decodedTextController.text = decoded;
  }

  String get encoded {
    return _encodedTextController.text;
  }

  set encoded(String decoded) {
    _encodedTextController.text = decoded;
  }

  ConverterExtraData get extraDecodedData {
    return _extraDecodedControllers.map(
      (key, value) => MapEntry(key, value.text),
    );
  }

  set extraDecodedData(ConverterExtraData data) {
    _extraDecodedControllers.forEach(
      (key, value) => value.text = data[key]!,
    );
  }

  ConverterExtraData get extraEncodedData {
    return _extraEncodedControllers.map(
      (key, value) => MapEntry(key, value.text),
    );
  }

  set extraEncodedData(ConverterExtraData data) {
    _extraEncodedControllers.forEach(
      (key, value) => value.text = data[key]!,
    );
  }

  ConverterData get data {
    return ConverterData(
      decoded: decoded,
      encoded: encoded,
      extraDecodedData: extraDecodedData,
      extraEncodedData: extraEncodedData,
    );
  }

  set data(ConverterData data) {
    decoded = data.decoded;
    encoded = data.encoded;
    extraDecodedData = data.extraDecodedData;
    extraEncodedData = data.extraEncodedData;

    box.put(widget.restorationId, data);
  }

  @override
  void initState() {
    _initData = box.get(widget.restorationId);
    _decodedTextController = TextEditingController(
      text: _initData?.decoded,
    );
    _encodedTextController = TextEditingController(
      text: _initData?.encoded,
    );
    super.initState();
  }

  @override
  void dispose() {
    _decodedTextController.dispose();
    _encodedTextController.dispose();
    super.dispose();
  }

  Widget _buildTextFieldCard({
    required BuildContext context,
    required TextEditingController controller,
    Widget? label,
  }) {
    return Card(
      child: Padding(
        padding: _cardPadding,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            label: label,
          ),
          minLines: 1,
          maxLines: 64,
        ),
      ),
    );
  }

  Widget _buildExtraDecodedTextFieldCard({
    required BuildContext context,
    required ConverterExtraItem item,
  }) {
    return _buildTextFieldCard(
      context: context,
      label: item.label,
      controller: _extraDecodedControllers[item.key] ??= TextEditingController(
        text: _initData?.extraDecodedData[item.key],
      ),
    );
  }

  Widget _buildExtraEncodedTextFieldCard({
    required BuildContext context,
    required ConverterExtraItem item,
  }) {
    return _buildTextFieldCard(
      context: context,
      label: item.label,
      controller: _extraEncodedControllers[item.key] ??= TextEditingController(
        text: _initData?.extraEncodedData[item.key],
      ),
    );
  }

  Widget _buildError({
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    return Card(
      color: theme.errorColor,
      child: Padding(
        padding: _cardPadding,
        child: Text(
          _error?.toString().trim() ?? '',
          style: TextStyle(
            color: theme.colorScheme.onError,
          ),
        ),
      ),
    );
  }

  Widget _buildConvertButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }

  Future<void> _encode() async {
    try {
      data = await widget.encode(data);
      error = null;
    } catch (e) {
      error = e;
    }
  }

  Future<void> _decode() async {
    try {
      data = await widget.decode(data);
      error = null;
    } catch (e) {
      error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = ConverterPage._box;
    final hintText = widget.hintText;
    final theme = Theme.of(context);

    if (box == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (hintText != null)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              hintText,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        _buildTextFieldCard(
          context: context,
          controller: _decodedTextController,
          label: widget.decodedLabel,
        ),
        for (final item in widget.extraDecodedItems)
          _buildExtraDecodedTextFieldCard(
            context: context,
            item: item,
          ),
        Wrap(
          spacing: 16.0,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...widget.prefixActions,
            _buildConvertButton(
              context: context,
              onPressed: _encode,
              icon: Icons.keyboard_arrow_down_rounded,
            ),
            _buildConvertButton(
              context: context,
              onPressed: _decode,
              icon: Icons.keyboard_arrow_up_rounded,
            ),
            ...widget.suffixActions,
          ],
        ),
        _buildTextFieldCard(
          context: context,
          controller: _encodedTextController,
          label: widget.encodedLabel,
        ),
        for (final item in widget.extraEncodedItems)
          _buildExtraEncodedTextFieldCard(
            context: context,
            item: item,
          ),
        if (_error != null) _buildError(context: context),
      ],
    );
  }
}
