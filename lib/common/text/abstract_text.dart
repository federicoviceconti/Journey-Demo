import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AbstractText extends StatelessWidget {
  final String data;
  final FontWeight fontWeight;
  final double fontSize;
  final Color color;
  final TextAlign align;

  const AbstractText(
    this.data, {
    Key key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.align,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: GoogleFonts.openSans(
        fontWeight: fontWeight,
        color: color ?? Colors.white,
        fontSize: fontSize,
      ),
      textAlign: align ?? TextAlign.left,
    );
  }
}
