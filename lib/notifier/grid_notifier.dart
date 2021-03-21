import 'package:flutter/material.dart';
import 'package:journey_demo/environment/session_manager.dart';
import 'package:journey_demo/notifier/base_notifier.dart';
import 'package:journey_demo/notifier/mixin/mixin_loader_notifier.dart';
import 'package:journey_demo/notifier/model/grid_item.dart';
import 'package:journey_demo/services/ev/response/ev_list_response.dart';

class GridNotifier extends BaseNotifier with LoaderNotifierMixin {
  List<GridItem> _items = [];

  num get batterySizeKWH => _evSelected?.usableBatterySizeInKwh ?? 0;

  List<GridItem> get items => _items;

  GridSelectionType currentState = GridSelectionType.none;

  EvItem _evSelected;

  int get width => 10;

  int get height => 12;

  String get wallText => "Change state";

  String get evNameTotal => _evSelected == null
      ? ''
      : "${_evSelected.brand ?? ''} ${_evSelected.model ?? ''} ${_evSelected.type ?? ''} ${_evSelected.year ?? ''}";

  String get currentStateText => getTextBySelectionType(currentState);

  void reload() {
    init();
  }

  void init() {
    showLoader();

    _evSelected = SessionManager.instance.evSelected;

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
      case GridSelectionType.cu:
        item.selectionType = item.selectionType == GridSelectionType.cu
            ? GridSelectionType.none
            : GridSelectionType.cu;
        break;
      default:
        return;
    }

    notifyListeners();
  }

  Color getGridColor(GridSelectionType type) {
    switch (type) {
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

  changeStateOnTap() {
    if (currentState == GridSelectionType.start ||
        currentState == GridSelectionType.end) {
      currentState = GridSelectionType.cu;
    } else if (currentState == GridSelectionType.none ||
        currentState == GridSelectionType.cu) {
      currentState = GridSelectionType.wall;
    } else {
      if (_containsTypeFromList(GridSelectionType.start) &&
          _containsTypeFromList(GridSelectionType.end)) {
        currentState = GridSelectionType.cu;
      } else if (_containsTypeFromList(GridSelectionType.start)) {
        currentState = GridSelectionType.start;
      } else if (_containsTypeFromList(GridSelectionType.end)) {
        currentState = GridSelectionType.wall;
      } else {
        currentState = GridSelectionType.none;
      }
    }

    notifyListeners();
  }

  _containsTypeFromList(GridSelectionType type) {
    final item = _items.firstWhere((element) => element.selectionType == type,
        orElse: () => null);

    return item != null;
  }

  String getTextBySelectionType(GridSelectionType type) {
    switch (type) {
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
      case GridSelectionType.cu:
        return "CU";
      default:
        return "";
    }
  }
}
