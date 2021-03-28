import 'package:journey_demo/notifier/model/grid_item.dart';

mixin GridMixin {
  GridItem getElementByType(List<GridItem> items, GridSelectionType type) {
    return items.firstWhere((element) => element.selectionType == type,
        orElse: () => null);
  }

  List<GridItem> getElementsByType(List<GridItem> items, GridSelectionType type) {
    return items
        .where((item) => item.selectionType == type)
        .toList();
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
}