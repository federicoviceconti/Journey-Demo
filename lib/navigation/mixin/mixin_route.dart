import 'package:flutter/material.dart';
import 'package:journey_demo/navigation/routes.dart';

mixin RouteMixin {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  NavigatorState get navigatorState => navigatorKey.currentState;

  Future<T> navigateTo<T>(
    RouteEnum routeName, {
    Object arguments,
    bool isRoot = false,
  }) async {
    if (isRoot) {
      return await navigatorState.pushReplacementNamed(
        routeName.name,
        arguments: arguments,
      );
    } else {
      return await navigatorState.pushNamed(
        routeName.name,
        arguments: arguments,
      );
    }
  }

  void pop<T>([T result]) {
    return navigatorState.pop(result);
  }
}
