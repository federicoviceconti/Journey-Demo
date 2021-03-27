import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey_demo/environment/session_manager.dart';
import 'package:journey_demo/notifier/base_notifier.dart';
import 'package:journey_demo/notifier/mixin/mixin_loader_notifier.dart';
import 'package:journey_demo/notifier/model/grid_item.dart';
import 'package:journey_demo/notifier/model/map_item.dart';
import 'package:journey_demo/notifier/model/tooltip_bundle.dart';
import 'package:journey_demo/services/ev/response/ev_list_response.dart';

import 'mixin/charge_map_mixin.dart';

class GridNotifier extends BaseNotifier
    with LoaderNotifierMixin, ChargeMapMixin {
  List<GridItem> _items = [];
  List<StationItem> _cuList = [];

  TooltipBundle _tooltipBundle;

  TooltipBundle get tooltipBundle => _tooltipBundle;

  bool _allowDiagonal = false;

  bool get allowDiagonal => _allowDiagonal;

  num get batterySizeKWH => _evSelected?.usableBatterySizeInKwh ?? 0;

  List<GridItem> get items => _items;

  GridSelectionType currentState = GridSelectionType.none;

  EvItem _evSelected;

  int get width => 10;

  int get height => 12;

  String get evNameTotal => _evSelected == null
      ? ''
      : "${_evSelected.brand ?? ''} ${_evSelected.model ?? ''} ${_evSelected.type ?? ''} ${_evSelected.year ?? ''}";

  String get currentStateText => getTextBySelectionType(currentState);

  bool _lockClick = false;

  bool get lockClick => _lockClick;

  void reload() {
    init();
  }

  Future<void> init() async {
    showLoader();

    _evSelected = SessionManager.instance.evSelected;
    _cuList = await getChargingStationsAndConvertToItem(
      startingPoint: LatLng(42, 12),
      maxResult: 5,
    );

    final itemGenerated = List.generate(
      width * height,
      (index) {
        return GridItem(
          column: index % width,
          row: (index / width).floor(),
        );
      },
    );

    _items = itemGenerated;

    hideLoader();
  }

  void allowDiagonalChange() {
    _allowDiagonal = !allowDiagonal;
  }

  void onGridTap(GridItem item) {
    if (lockClick) return;

    if (tooltipBundle == null) {
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
          _handleTapWhenCU(item);
          break;
        default:
          return;
      }
    } else {
      _tooltipBundle = null;
    }

    notifyListeners();
  }

  void _handleTapWhenCU(GridItem item) {
    item.selectionType =
        item.selectionType == GridSelectionType.cu || _cuList.isEmpty
            ? GridSelectionType.none
            : GridSelectionType.cu;

    if (item.selectionType == GridSelectionType.cu && _cuList.isNotEmpty) {
      item.station = _cuList.removeLast();
    } else {
      item.station = null;
    }
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
      case GridSelectionType.walked:
        return Colors.yellow;
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
    _lockClick = false;
    notifyListeners();
  }

  changeStateOnTap() {
    if (lockClick) return;

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

  bool _containsTypeFromList(GridSelectionType type) {
    final item = _getElementByType(type);

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
      case GridSelectionType.walked:
        return "Walked";
      default:
        return "";
    }
  }

  void showTooltipOnPosition(GlobalKey key, GridItem item) {
    final width = 200.0;
    final navContext = navigatorState.context;
    final phoneWidth = MediaQuery.of(navContext).size.width;

    final renderBox = key.currentContext.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    final xAxisPosition =
        position.dx + width > phoneWidth ? position.dx - width : position.dx;

    if (item.station != null) {
      _tooltipBundle = TooltipBundle(
        top: position.dy,
        left: xAxisPosition,
        title: item.station.title,
        subtitle: item.station.addressLine,
        width: width,
      );
    } else {
      _tooltipBundle = null;
    }

    notifyListeners();
  }

  void calculatePath() {
    _lockClick = true;
    notifyListeners();

    _initSpots();

    GridItem current;
    final GridItem start = _getElementByType(GridSelectionType.start);
    final GridItem end = _getElementByType(GridSelectionType.end);

    if (start != null && end != null) {
      final List<GridItem> openSet = [start];
      final List<GridItem> closeSet = _items
          .where((item) => item.selectionType == GridSelectionType.wall)
          .toList();
      final List<GridItem> cameFrom = [];

      while (openSet.isNotEmpty) {
        current = _getLowestFScoreFromSet(openSet);

        if (current == end) {
          debugPrint("END!");
          break;
        }

        openSet.remove(current);
        closeSet.add(current);

        final neighbors = current.getNeighbors(maxRows: height, maxCols: width);

        for (final tupleItem in neighbors) {
          final neighbor =
              _getItemFromGridFromRowAndCols(tupleItem.item1, tupleItem.item2);

          if (!closeSet.contains(neighbor)) {
            final tentativeGScore =
                neighbor.spot.g + _heuristic(current, neighbor);

            if (!openSet.contains(neighbor)) {
              openSet.add(neighbor);
            } else if (tentativeGScore <= neighbor.spot.g) {
              neighbor.spot.g = tentativeGScore;
              neighbor.spot.h = _heuristic(current, end);
              neighbor.spot.f = neighbor.spot.g + neighbor.spot.h;

              cameFrom.add(current);
            }
          }
        }
      }

      print("No solution :(\n$closeSet");

      closeSet.forEach((e) {
        if(e.selectionType != GridSelectionType.start)
          e.selectionType = GridSelectionType.walked;
      });
      cameFrom.forEach((e) {
        e.selectionType = GridSelectionType.cu;
      });

      notifyListeners();
    }
  }

  GridItem _getItemFromGridFromRowAndCols(int row, int col) {
    try {
      return _items
          .firstWhere((element) => element.row == row && element.column == col);
    } catch(e) {
      throw UnsupportedError("no element");
    }
  }

  void _initSpots() {
    _items.forEach((element) {
      element.spot = Spot.zeroCost();
    });
  }

  GridItem _getElementByType(GridSelectionType type) {
    return _items.firstWhere((element) => element.selectionType == type,
        orElse: () => null);
  }

  GridItem _getLowestFScoreFromSet(List<GridItem> openSet) {
    var winner = 0;
    for (var i = 1; i < openSet.length; i++) {
      if (openSet[i].spot.f < openSet[winner].spot.f) {
        winner = i;
      }

      if (openSet[i].spot.f == openSet[winner].spot.f) {
        if (openSet[i].spot.g > openSet[winner].spot.g) {
          winner = i;
        }

        /*if (!this.allowDiagonals) {
          if (this.openSet[i].g == this.openSet[winner].g &&
              this.openSet[i].vh < this.openSet[winner].vh) {
            winner = i;
          }
        }*/
      }
    }

    return openSet[winner];
  }

  num _dist(GridItem current, GridItem gridItem) {
    final x = gridItem.row - gridItem.row;
    final y = gridItem.column - gridItem.column;
    return sqrt(pow(x, 2) + pow(y, 2));
  }

  num _heuristic(GridItem current, GridItem gridItem) {
    int d;
    if (_allowDiagonal) {
      d = _dist(current, gridItem);
    } else {
      d = (current.row - gridItem.row).abs() +
          (current.column - gridItem.column).abs();
    }

    return d;
  }
}
