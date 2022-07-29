import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:useless_kit/pages/home/delegate.dart';

class Base64ConverterPage extends StatefulWidget {
  const Base64ConverterPage({Key? key}) : super(key: key);

  static const HomeContentDelegate delegate = HomeContentChildDelegate(
    destination: NavigationRailDestination(
      icon: Icon(Icons.transform),
      selectedIcon: Icon(Icons.transform),
      label: Text('Base64'),
    ),
    child: Base64ConverterPage(),
  );

  @override
  State<Base64ConverterPage> createState() => _Base64ConverterPageState();
}

class _Base64ConverterPageState extends State<Base64ConverterPage> {
  static const EdgeInsetsGeometry _cardPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 16,
  );

  final _decodedTextController = TextEditingController();
  final _encodedTextController = TextEditingController();

  Object? _error;

  Widget _buildTextFieldCard({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
  }) {
    return Card(
      child: Padding(
        padding: _cardPadding,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
          ),
          minLines: 1,
          maxLines: 64,
        ),
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

  void _encode() {
    final decoded = _decodedTextController.text;
    try {
      _encodedTextController.text = base64Encode(utf8.encode(decoded));
      if (_error != null) {
        setState(() {
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = e;
      });
    }
  }

  void _decode() {
    final encoded = _encodedTextController.text;
    try {
      _decodedTextController.text = utf8.decode(base64Decode(encoded));
      if (_error != null) {
        setState(() {
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildTextFieldCard(
          context: context,
          controller: _decodedTextController,
          label: 'Decoded',
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
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
          ],
        ),
        _buildTextFieldCard(
          context: context,
          controller: _encodedTextController,
          label: 'Encoded',
        ),
        if (_error != null) _buildError(context: context),
      ],
    );
  }
}
