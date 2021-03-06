import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey_demo/environment/app_constants.dart';
import 'package:journey_demo/environment/session_manager.dart';
import 'package:journey_demo/navigation/bundle/route_detail_bundle.dart';
import 'package:journey_demo/navigation/routes.dart';
import 'package:journey_demo/notifier/base_notifier.dart';
import 'package:journey_demo/notifier/mixin/a_star_mixin.dart';
import 'package:journey_demo/notifier/mixin/grid_mixin.dart';
import 'package:journey_demo/notifier/mixin/mixin_loader_notifier.dart';
import 'package:journey_demo/notifier/model/grid_item.dart';
import 'package:journey_demo/notifier/model/map_item.dart';
import 'package:journey_demo/notifier/model/tooltip_bundle.dart';
import 'package:journey_demo/notifier/model/tuple.dart';
import 'package:journey_demo/services/ev/response/ev_list_response.dart';
import 'package:journey_demo/notifier/model/plug_type.dart';
import 'package:journey_demo/services/open_charge_map/response/charging_station_list_response.dart';
import 'mixin/charge_map_mixin.dart';

class GridNotifier extends BaseNotifier
    with LoaderNotifierMixin, ChargeMapMixin, AStarMixin, GridMixin {
  List<GridItem> _items = [];
  List<StationItem> _cuList = [];

  TooltipBundle _tooltipBundle;

  int _solutionIndexSelected = -1;

  int get solutionIndexSelected => _solutionIndexSelected;

  bool _calculatingPath = false;

  bool get calculatingPath => _calculatingPath;

  TooltipBundle get tooltipBundle => _tooltipBundle;

  bool _allowDiagonal = false;

  bool get allowDiagonal => _allowDiagonal;

  num get batterySizeKWH => _evSelected?.usableBatterySizeInKwh ?? 0;

  num get averageConsumptionKwh => _evSelected?.averageConsumption ?? 0;

  List<GridItem> get items => _items;

  GridSelectionType currentState = GridSelectionType.none;

  EvItem _evSelected;

  int _width = 15;

  int get width => _width;

  int _height = 15;

  int get height => _height;

  String get evNameTotal => _evSelected == null
      ? ''
      : "${_evSelected.brand ?? ''} ${_evSelected.model ?? ''} ${_evSelected.type ?? ''} ${_evSelected.year ?? ''}";

  String get currentStateText => getTextBySelectionType(currentState);

  bool _lockClick = false;

  bool get lockClick => _lockClick;

  num _totalSolutionKm = 0;

  num get totalSolutionKm => _totalSolutionKm;

  num get cuAvailable => _cuList?.length ?? 0;

  num get _necessaryKwhSolution =>
      (averageConsumptionKwh * totalSolutionKm / 100);

  String get necessaryKwhForSolution =>
      _necessaryKwhSolution.toStringAsFixed(2);

  List<List<GridItem>> _solutions = [];

  List<List<GridItem>> get solutions => _solutions;

  void reload() {
    clearAll();
    init();
  }

  Future<void> init() async {
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

    showLoader();

    _evSelected = SessionManager.instance.evSelected;

    if (_cuList.isEmpty) {
      _cuList = await getChargingStationsAndConvertToItem(
        startingPoint: LatLng(
          AppConstants.START_POINT_LAT,
          AppConstants.START_POINT_LNG,
        ),
        maxResult: 5,
      );
    }

    hideLoader();
  }

  void allowDiagonalChange() {
    _allowDiagonal = !allowDiagonal;
  }

  void onGridTap(GridItem item) {
    if (tooltipBundle == null) {
      if (lockClick) return;

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
      case GridSelectionType.solution:
        return Colors.lightBlue;
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
    _calculatingPath = false;
    _solutions = [];
    _solutionIndexSelected = -1;
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
    final item = getElementByType(_items, type);

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
      case GridSelectionType.solution:
        return "Solution";
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
      _tooltipBundle = TooltipBundle<StationPlug>(
        top: position.dy,
        left: xAxisPosition,
        title: item.station.title,
        subtitle: item.station.addressLine,
        width: width,
        descriptionWithImages: Tuple2<String, List<StationPlug>>(
          "Plugs:",
          item.station.plugs,
        ),
      );
    } else {
      _tooltipBundle = null;
    }

    notifyListeners();
  }

  void calculatePath() async {
    _lockClick = true;
    _calculatingPath = true;
    notifyListeners();

    await _calculateSolutions();

    _calculatingPath = false;
    notifyListeners();
  }

  onSolutionTap(int index) {
    final solution = solutions[index];
    _solutionIndexSelected = index;

    _items.forEach((element) {
      markElementSolutionAsWalked(element);
    });

    markPathAsSolution(solution);
    _setTotalKm(solution);
  }

  void onIntermediateStepDone(List<GridItem> singleSolution) {
    markPathAsSolution(singleSolution);
    _setTotalKm(singleSolution);
    notifyListeners();
  }

  void markPathAsSolution(List<GridItem> path) {
    path.forEach((e) {
      if (e.selectionType != GridSelectionType.start &&
          e.selectionType != GridSelectionType.cu &&
          e.selectionType != GridSelectionType.end)
        e.selectionType = GridSelectionType.solution;
    });
  }

  void _setTotalKm(List<GridItem> singleSolution) {
    _totalSolutionKm = _getTotalKmForPath(singleSolution);
    notifyListeners();
  }

  onTripDetail(int index) {
    final solution = solutions[index];

    navigateTo(
      RouteEnum.routeDetail,
      arguments: RouteDetailBundle(solution),
    );
  }

  num _getTotalKmForPath(List<GridItem> singleSolution) {
    return singleSolution.length * AppConstants.KM_MULTIPLIER;
  }

  List<GridItem> _filterCUForEvSelected() {
    return getElementsByType(_items, GridSelectionType.cu).where((cu) {
      final cuPlugs = cu.station.plugs;
      final evPlugs = _evSelected.plugs;

      return cuPlugs.firstWhere(
            (plug) => evPlugs.contains(plug.type),
            orElse: () => null,
          ) !=
          null;
    }).toList();
  }

  _calculateSolutions() async {
    final cuElements = _filterCUForEvSelected();

    final endOnlySearch = getElementsByType(items, GridSelectionType.end);
    final endSolutionSearch = await _calculateAStar(endOnlySearch);
    _solutions.add(endSolutionSearch);

    if (cuElements.isNotEmpty) {
      final List<GridItem> cuSearch = [
        ...cuElements,
        ...getElementsByType(items, GridSelectionType.end),
      ];
      final cuSearchSolution = await _calculateAStar(cuSearch);
      _solutions.add(cuSearchSolution);
    }
  }

  Future<List<GridItem>> _calculateAStar(
      List<GridItem> endStepsToSearch) async {
    return await calculateAStar(
      allItems: _items,
      endSteps: endStepsToSearch,
      allowDiagonal: _allowDiagonal,
      width: _width,
      height: _height,
      delay: AppConstants.DELAY_ANIMATION_SOLUTION,
      onIntermediateStepDone: onIntermediateStepDone,
    );
  }
}
