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
          row: (index / width).ceil(),
        );
      },
    );

    _items = itemGenerated;

    hideLoader();
  }

  void onGridTap(GridItem item) {
    if(tooltipBundle == null) {
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
    item.selectionType = item.selectionType == GridSelectionType.cu || _cuList.isEmpty
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

  void showTooltipOnPosition(GlobalKey key, GridItem item) {
    final renderBox = key.currentContext.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    if(item.station != null) {
      _tooltipBundle = TooltipBundle(
        top: position.dy,
        left: position.dx,
        title: item.station.title,
        subtitle: item.station.addressLine
      );
    } else {
      _tooltipBundle = null;
    }

    notifyListeners();
  }
}
