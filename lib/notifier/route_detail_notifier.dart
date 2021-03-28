import 'package:journey_demo/navigation/bundle/route_detail_bundle.dart';
import 'package:journey_demo/notifier/base_notifier.dart';
import 'package:journey_demo/notifier/model/grid_item.dart';

class RouteDetailNotifier extends BaseNotifier {
  final RouteDetailBundle routeDetailBundle;

  RouteDetailNotifier({
    this.routeDetailBundle,
  });

  init() {
    _buildDirections();
  }

  void _buildDirections() {
    final directions = [];

    final solution = routeDetailBundle.solution;
    GridItem lastCheck = solution.first;

    for (int i = 1; i < solution.length; i++) {
      if (lastCheck.selectionType != solution[i].selectionType || _hasRowOrColumnChanged(solution[i], solution[i - 2])) {
        directions.add(DirectionModel(
          message: _buildMessage(),
          direction: DirectionEnum.down,
          km: 0,
        ));

        lastCheck = solution[i];
      }
    }
  }

  bool _hasRowOrColumnChanged(GridItem current, GridItem previous) {
    return true;
  }

  _buildMessage() {
    return "";
  }
}

class DirectionModel {
  final String message;
  final DirectionEnum direction;
  final double km;

  DirectionModel({
    this.message,
    this.direction,
    this.km,
  });
}

enum DirectionEnum { up, down, left, right }
