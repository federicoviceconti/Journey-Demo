import 'package:journey_demo/notifier/model/map_item.dart';

class GridItem {
  int row;
  int column;
  GridSelectionType selectionType;
  StationItem station;

  GridItem(
      {this.row, this.column, this.selectionType = GridSelectionType.none});
}

enum GridSelectionType { none, start, end, path, wall, cu }