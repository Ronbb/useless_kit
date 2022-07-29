import 'package:flutter/material.dart';

abstract class HomeContentDelegate {
  const HomeContentDelegate();

  NavigationRailDestination get destination;

  Widget build(BuildContext context);
}

class HomeContentChildDelegate extends HomeContentDelegate {
  const HomeContentChildDelegate({
    required this.destination,
    required this.child,
  });

  final Widget child;

  @override
  final NavigationRailDestination destination;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class HomeContentBuilderDelegate extends HomeContentDelegate {
  const HomeContentBuilderDelegate({
    required this.destination,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  final NavigationRailDestination destination;

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
