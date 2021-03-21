import 'package:flutter/material.dart';
import 'package:journey_demo/environment/app_constants.dart';
import 'package:journey_demo/navigation/mixin/mixin_route.dart';
import 'package:journey_demo/navigation/routes.dart';

class TripApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.APP_NAME,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: Routes.routes,
      navigatorKey: RouteMixin.navigatorKey,
      initialRoute: Routes.initial,
    );
  }
}