import 'package:journey_demo/notifier/model/map_item.dart';
import 'package:journey_demo/notifier/model/tuple.dart';

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

  List<Tuple2<int, int>> getNeighbors({
    int maxRows = 0,
    int maxCols = 0,
  }) {
    final List<Tuple2<int,int>> neighbors = [];

    if (row > 0) {
      neighbors.add(Tuple2.fromList([row - 1, column]));
    }
    if ((row + 1) < maxRows) {
      neighbors.add(Tuple2.fromList([row + 1, column]));
    }
    if (column > 0) {
      neighbors.add(Tuple2.fromList([row, column - 1]));
    }
    if ((column + 1) < maxCols) {
      neighbors.add(Tuple2.fromList([row, column + 1]));
    }

    return neighbors;
  }

  @override
  String toString() {
    return 'GridItem{row: $row, column: $column, selectionType: $selectionType}';
  }
}

class Spot {
  int f;
  int g;
  int h;
  GridItem previous;

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

  Spot.zeroCostWithPrevious(GridItem previous) {
    this.f = 0;
    this.g = 0;
    this.h = 0;
    this.previous = previous;
  }
}

enum GridSelectionType { none, start, end, path, wall, cu, walked, solution }
