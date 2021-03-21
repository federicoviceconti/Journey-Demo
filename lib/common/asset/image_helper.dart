import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Widget getPng({
  String path,
  BoxFit fit,
  double height,
}) {
  return Image.asset(
    "assets/images/$path",
    fit: fit,
    height: height,
  );
}

Widget getSvg({String path, BoxFit fit, double height, double width}) {
  return SvgPicture.asset(
    _getSvgPath(path),
    fit: fit ?? BoxFit.contain,
    height: height,
    width: width,
  );
}

String _getSvgPath(String path) => "assets/svg/$path.svg";

Future<BitmapDescriptor> getBitmapDescriptorFromSvg(
    BuildContext context, String assetName, int width, int height) async {
  String svgString =
      await DefaultAssetBundle.of(context).loadString(_getSvgPath(assetName));
  //Draws string representation of svg to DrawableRoot
  DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, null);
  ui.Picture picture = svgDrawableRoot.toPicture();
  ui.Image image = await picture.toImage(width, height);
  ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
}
