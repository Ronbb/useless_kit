import 'dart:io';

import 'package:flutter/material.dart';
import 'package:useless_kit/pages/converter/base64.dart';
import 'package:useless_kit/pages/home/delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<HomeContentDelegate> delegates = [
    Base64ConverterPage.delegate,
    Base64ConverterPage.delegate,
  ];

  @override
  Widget build(BuildContext context) {
    final delegate = delegates[_selectedIndex];

    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            labelType: NavigationRailLabelType.selected,
            groupAlignment: Alignment.center.y,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: delegates.map((e) => e.destination).toList(),
          ),
          Expanded(
            child: Builder(
              builder: delegate.build,
            ),
          )
        ],
      ),
    );
  }
}
