import 'package:flutter/material.dart';

class AlertBundle {
  final AlertType type;
  final Function(BuildContext context) onRightAction;

  AlertBundle({
    this.onRightAction,
    this.type = AlertType.success
  });
}

enum AlertType {
  success, error, warning
}