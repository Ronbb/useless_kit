import 'dart:async';

import 'package:flutter/material.dart';

typedef ExtraData = Map<Object?, String>;

typedef Converter = FutureOr<DataGroup> Function(DataGroup data);

class DataGroup {
  const DataGroup({
    required this.decoded,
    required this.encoded,
    required this.extraDecodedData,
    required this.extraEncodedData,
  });

  final String decoded;
  final String encoded;
  final ExtraData extraDecodedData;
  final ExtraData extraEncodedData;

  DataGroup copyWith({
    String? decoded,
    String? encoded,
    ExtraData? extraDecodedData,
    ExtraData? extraEncodedData,
  }) {
    return DataGroup(
      decoded: decoded ?? this.decoded,
      encoded: encoded ?? this.encoded,
      extraDecodedData: extraDecodedData ?? this.extraDecodedData,
      extraEncodedData: extraEncodedData ?? this.extraEncodedData,
    );
  }
}

class ExtraItem {
  const ExtraItem({
    required this.key,
    required this.label,
  });

  final Object? key;

  final Widget label;
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({
    Key? key,
    this.hintText,
    required this.decode,
    required this.encode,
    this.decodedLabel,
    this.encodedLabel,
    this.prefixActions = const [],
    this.suffixActions = const [],
    this.extraDecodedItems = const [],
    this.extraEncodedItems = const [],
  }) : super(key: key);

  final String? hintText;

  final Converter decode;

  final Converter encode;

  final Widget? decodedLabel;

  final Widget? encodedLabel;

  final List<Widget> prefixActions;

  final List<Widget> suffixActions;

  final List<ExtraItem> extraDecodedItems;

  final List<ExtraItem> extraEncodedItems;

  @override
  State<ConverterPage> createState() => ConverterPageState();
}

class ConverterPageState extends State<ConverterPage> {
  static const EdgeInsetsGeometry _cardPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 16,
  );

  final _decodedTextController = TextEditingController();
  final _encodedTextController = TextEditingController();

  final _extraDecodedControllers = <Object?, TextEditingController>{};
  final _extraEncodedControllers = <Object?, TextEditingController>{};

  Object? _error;

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

  ExtraData get extraDecodedData {
    return _extraDecodedControllers.map(
      (key, value) => MapEntry(key, value.text),
    );
  }

  set extraDecodedData(ExtraData data) {
    _extraDecodedControllers.forEach(
      (key, value) => value.text = data[key]!,
    );
  }

  ExtraData get extraEncodedData {
    return _extraEncodedControllers.map(
      (key, value) => MapEntry(key, value.text),
    );
  }

  set extraEncodedData(ExtraData data) {
    _extraEncodedControllers.forEach(
      (key, value) => value.text = data[key]!,
    );
  }

  DataGroup get data {
    return DataGroup(
      decoded: decoded,
      encoded: encoded,
      extraDecodedData: extraDecodedData,
      extraEncodedData: extraEncodedData,
    );
  }

  set data(DataGroup data) {
    decoded = data.decoded;
    encoded = data.encoded;
    extraDecodedData = data.extraDecodedData;
    extraEncodedData = data.extraEncodedData;
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
    required ExtraItem item,
  }) {
    return _buildTextFieldCard(
      context: context,
      label: item.label,
      controller: _extraDecodedControllers[item.key] ??=
          TextEditingController(),
    );
  }

  Widget _buildExtraEncodedTextFieldCard({
    required BuildContext context,
    required ExtraItem item,
  }) {
    return _buildTextFieldCard(
      context: context,
      label: item.label,
      controller: _extraEncodedControllers[item.key] ??=
          TextEditingController(),
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
    final hintText = widget.hintText;
    final theme = Theme.of(context);

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
