import 'package:flutter/material.dart';
import 'package:journey_demo/common/text/abstract_text.dart';

class BoldText extends AbstractText {
  const BoldText(
    String data, {
    Key key,
    double fontSize,
    Color color,
    TextAlign align,
  }) : super(
          data,
          key: key,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          align: align,
        );
}
