import 'dart:math';

import 'package:journey_demo/notifier/model/grid_item.dart';

mixin GridMixin {
  GridItem getElementByType(List<GridItem> items, GridSelectionType type,
      {GridItem excludes}) {
    return items.firstWhere(
      (element) => element.selectionType == type && element != excludes,
      orElse: () => null,
    );
  }

  List<GridItem> getElementsByType(
      List<GridItem> items, GridSelectionType type) {
    return items.where((item) => item.selectionType == type).toList();
  }

  GridItem getItemFromGridFromRowAndCols(
      List<GridItem> items, int row, int col) {
    try {
      return items
          .firstWhere((element) => element.row == row && element.column == col);
    } catch (e) {
      throw UnsupportedError("No element inside grid at ($row,$col)");
    }
  }

  num dist(GridItem current, GridItem gridItem) {
    final x = gridItem.row - gridItem.row;
    final y = gridItem.column - gridItem.column;
    return sqrt(pow(x, 2) + pow(y, 2)).toInt();
  }
}
