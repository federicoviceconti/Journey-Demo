import 'package:journey_demo/environment/app_constants.dart';
import 'package:journey_demo/navigation/bundle/route_detail_bundle.dart';
import 'package:journey_demo/notifier/base_notifier.dart';
import 'package:journey_demo/notifier/mixin/grid_mixin.dart';
import 'package:journey_demo/notifier/model/grid_item.dart';

class RouteDetailNotifier extends BaseNotifier with GridMixin {
  final RouteDetailBundle routeDetailBundle;

  List<DirectionModel> _directions = [];

  List<DirectionModel> get directions => _directions;

  RouteDetailNotifier({
    this.routeDetailBundle,
  });

  init() {
    _buildDirections();
  }

  void _buildDirections() {
    _directions = [];

    List<GridItem> solution = [...routeDetailBundle.solution];

    _directions.add(DirectionModel(
        title: _buildTitle(solution[0], DirectionEnum.none, 0),
        message: _buildMessage(solution[0], DirectionEnum.none, 0)));

    for (int i = 2; i < solution.length; i++) {
      final current = solution[i];
      final prev = solution[i - 1];

      final direction = _getDirection(current, prev);
      final km = AppConstants.KM_MULTIPLIER;

      _directions.add(
        DirectionModel(
          title: _buildTitle(solution[i], direction, km),
          message: _buildMessage(solution[i], direction, km),
          km: km.toDouble(),
        ),
      );
    }

    notifyListeners();
  }

  DirectionEnum _getDirection(GridItem current, GridItem prev) {
    if (prev.row != current.row) {
      return current.row > prev.row ? DirectionEnum.left : DirectionEnum.right;
    }

    return prev.column != current.column && prev.column < prev.column
        ? DirectionEnum.up
        : DirectionEnum.down;
  }

  _buildTitle(GridItem solution, DirectionEnum direction, num km) {
    switch (solution.selectionType) {
      default:
        return "Step (${solution.row}, ${solution.column})";
    }
  }

  _buildMessage(GridItem solution, DirectionEnum direction, num km) {
    switch (solution.selectionType) {
      case GridSelectionType.start:
        return "Start route.";
      case GridSelectionType.end:
        return "End route.";
      case GridSelectionType.cu:
        return """Found CU with UUID: ${solution.station.uuid}
Address: ${solution.station.addressLine}
""";
      default:
        if(direction == DirectionEnum.none) {
          return "";
        }

        return "Go ${direction.name}";
    }
  }
}

class DirectionModel {
  final String title;
  final String message;
  final DirectionEnum direction;
  final double km;

  DirectionModel({
    this.title,
    this.message,
    this.direction,
    this.km,
  });
}

enum DirectionEnum { up, down, left, right, none }

extension EnumDirectionExtension on DirectionEnum {
  String get name {
    switch (this) {
      case DirectionEnum.up:
        return "up";
      case DirectionEnum.down:
        return "down";
      case DirectionEnum.left:
        return "left";
      case DirectionEnum.right:
        return "right";
      default:
        return "";
    }
  }
}
