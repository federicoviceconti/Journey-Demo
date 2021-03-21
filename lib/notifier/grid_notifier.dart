import 'package:flutter/material.dart';
import 'package:journey_demo/notifier/base_notifier.dart';
import 'package:journey_demo/notifier/mixin/mixin_loader_notifier.dart';
import 'package:journey_demo/notifier/model/grid_item.dart';

class GridNotifier extends BaseNotifier with LoaderNotifierMixin {
  List<GridItem> _items = [];

  List<GridItem> get items => _items;

  GridSelectionType currentState = GridSelectionType.none;

  int get width => 10;

  int get height => 15;

  String get wallText =>
      currentState == GridSelectionType.wall ? "Build path" : "Build wall";

  String get currentStateText {
    switch (currentState) {
      case GridSelectionType.none:
        return "None";
      case GridSelectionType.start:
        return "Start";
      case GridSelectionType.end:
        return "End";
      case GridSelectionType.path:
        return "Path finding";
      case GridSelectionType.wall:
        return "Wall";
      default:
        return "";
    }
  }

  void reload() {
    init();
  }

  void init() {
    showLoader();

    final itemGenerated = List.generate(
      width * height,
      (index) {
        return GridItem(
          column: index % width,
          row: (index / width).ceil(),
        );
      },
    );

    _items = itemGenerated;

    hideLoader();
  }

  void onGridTap(GridItem item) {
    switch (currentState) {
      case GridSelectionType.none:
        item.selectionType = GridSelectionType.start;
        currentState = GridSelectionType.start;
        break;
      case GridSelectionType.start:
        item.selectionType = GridSelectionType.end;
        currentState = GridSelectionType.end;
        break;
      case GridSelectionType.end:
        item.selectionType = GridSelectionType.wall;
        currentState = GridSelectionType.wall;
        break;
      case GridSelectionType.wall:
        item.selectionType = item.selectionType == GridSelectionType.wall
            ? GridSelectionType.none
            : GridSelectionType.wall;
        break;
      default:
        return;
    }

    notifyListeners();
  }

  Color getGridColor(GridItem color) {
    switch (color.selectionType) {
      case GridSelectionType.none:
        return Colors.white;
      case GridSelectionType.start:
        return Colors.orange;
      case GridSelectionType.end:
        return Colors.orange;
      case GridSelectionType.path:
        return Colors.redAccent;
      case GridSelectionType.wall:
        return Colors.black;
      case GridSelectionType.cu:
        return Colors.green;
      default:
        throw UnsupportedError("Type not found!");
    }
  }

  clearAll() {
    _items = _items.map((e) {
      e.selectionType = GridSelectionType.none;
      return e;
    }).toList();

    currentState = GridSelectionType.none;
    notifyListeners();
  }

  buildWall() {
    if (currentState != GridSelectionType.wall) {
      currentState = GridSelectionType.wall;
    } else {
      final item = _items.firstWhere(
          (element) => element.selectionType == GridSelectionType.start,
          orElse: () => null);

      if (item != null) {
        currentState = GridSelectionType.end;
      } else {
        currentState = GridSelectionType.start;
      }
    }

    notifyListeners();
  }
}
