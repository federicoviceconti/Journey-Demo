import 'package:journey_demo/notifier/model/map_item.dart';

class GridItem {
  int row;
  int column;
  GridSelectionType selectionType;
  StationItem station;
  Spot spot;

  GridItem({
    this.row,
    this.column,
    this.selectionType = GridSelectionType.none,
    this.spot,
  });
}

class Spot {
  int f;
  int g;
  int h;

  Spot({
    this.f,
    this.g,
    this.h,
  });

  Spot.zeroCost() {
    this.f = 0;
    this.g = 0;
    this.h = 0;
  }
}

enum GridSelectionType { none, start, end, path, wall, cu }
