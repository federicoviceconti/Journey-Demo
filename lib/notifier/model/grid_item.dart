class GridItem {
  int row;
  int column;
  GridSelectionType selectionType;

  GridItem(
      {this.row, this.column, this.selectionType = GridSelectionType.none});
}

enum GridSelectionType { none, start, end, path, wall, cu }