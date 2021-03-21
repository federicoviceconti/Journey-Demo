import 'package:flutter/material.dart';
import 'package:journey_demo/common/get_it.dart';
import 'package:journey_demo/environment/trip_app.dart';

void main() {
  setupLocator();
  runApp(TripApp());
}
