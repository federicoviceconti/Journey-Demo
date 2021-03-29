import 'package:journey_demo/notifier/model/tuple.dart';

class TooltipBundle<T> {
  final String title;
  final String subtitle;
  final double top;
  final double left;
  final double width;
  final Tuple2<String, List<T>> descriptionWithImages;

  TooltipBundle({
    this.title,
    this.subtitle,
    this.top,
    this.left,
    this.width,
    this.descriptionWithImages
  });
}
