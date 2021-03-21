import 'package:flutter/material.dart';
import 'package:journey_demo/common/text/abstract_text.dart';

class RegularText extends AbstractText {
  const RegularText(
    String data, {
    Key key,
    double fontSize,
    Color color,
    TextAlign align,
  }) : super(
          data,
          key: key,
          fontSize: fontSize,
          fontWeight: FontWeight.normal,
          color: color,
          align: align,
        );
}
