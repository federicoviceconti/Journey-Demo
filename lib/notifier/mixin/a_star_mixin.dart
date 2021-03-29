import 'dart:math';

import 'package:journey_demo/notifier/mixin/grid_mixin.dart';
import 'package:journey_demo/notifier/model/grid_item.dart';

mixin AStarMixin implements GridMixin {
  Future<List<GridItem>> calculateAStar({
    List<GridItem> allItems,
    bool allowDiagonal,
    int width,
    int height,
    int delay,
    Function(List<GridItem> singleSolution) onIntermediateStepDone,
    List<GridSelectionType> stepsToSearch,
  }) async {
    List<GridItem> singleSolution = [];
    _initSpotsAndMarkSolutionAsWalked(allItems);

    GridItem current;
    GridItem start = getElementByType(allItems, GridSelectionType.start);
    GridItem end = getElementByType(allItems, stepsToSearch.removeAt(0));

    if (start != null && end != null) {
      List<GridItem> openSet = [start];
      List<GridItem> closeSet =
          getElementsByType(allItems, GridSelectionType.wall);

      while (openSet.isNotEmpty) {
        current =
            _getLowestFScoreFromSet(openSet, allowDiagonal: allowDiagonal);

        if (current == end) {
          if (stepsToSearch.isNotEmpty) {
            openSet = [current];
            end = getElementByType(allItems, stepsToSearch.removeAt(0), excludes: end);

            _initSpotWithPrevious(allItems);
          } else {
            singleSolution.insert(0, start);
            singleSolution.insert(singleSolution.length - 1, end);
            break;
          }
        }

        openSet.remove(current);
        closeSet.add(current);

        final neighbors = current.getNeighbors(maxRows: height, maxCols: width);

        for (final tupleItem in neighbors) {
          final neighbor = getItemFromGridFromRowAndCols(
              allItems, tupleItem.item1, tupleItem.item2);

          if (!closeSet.contains(neighbor)) {
            final tentativeGScore =
                current.spot.g + _heuristic(current, neighbor, allowDiagonal);

            if (!openSet.contains(neighbor)) {
              openSet.add(neighbor);
            }

            neighbor.spot.g = tentativeGScore;
            neighbor.spot.h = _heuristic(current, end, allowDiagonal);
            neighbor.spot.f = neighbor.spot.g + neighbor.spot.h;

            neighbor.spot.previous = current;
          }
        }

        _buildWalkPath(openSet, closeSet);
        singleSolution = buildPathForSolution(current);

        onIntermediateStepDone(singleSolution);
        await Future.delayed(Duration(
          milliseconds: delay,
        ));
      }
    }

    _initSpotsAndMarkSolutionAsWalked(allItems);
    return singleSolution;
  }

  void _initSpotsAndMarkSolutionAsWalked(List<GridItem> items) {
    items.forEach((element) {
      element.spot = Spot.zeroCost();

      markElementSolutionAsWalked(element);
    });
  }

  GridItem _getLowestFScoreFromSet(List<GridItem> openSet,
      {bool allowDiagonal = false}) {
    var winner = 0;
    for (var i = 1; i < openSet.length; i++) {
      if (openSet[i].spot.f < openSet[winner].spot.f) {
        winner = i;
      }

      if (openSet[i].spot.f == openSet[winner].spot.f) {
        if (openSet[i].spot.g > openSet[winner].spot.g) {
          winner = i;
        }

        if (!allowDiagonal) {
          if (openSet[i].spot.g == openSet[winner].spot.g) {
            winner = i;
          }
        }
      }
    }

    return openSet[winner];
  }

  num _dist(GridItem current, GridItem gridItem) {
    final x = gridItem.row - gridItem.row;
    final y = gridItem.column - gridItem.column;
    return sqrt(pow(x, 2) + pow(y, 2)).toInt();
  }

  num _heuristic(GridItem current, GridItem gridItem, bool allowDiagonal) {
    int d;
    if (allowDiagonal) {
      d = _dist(current, gridItem);
    } else {
      d = (current.row - gridItem.row).abs() +
          (current.column - gridItem.column).abs();
    }

    return d;
  }

  void _buildWalkPath(List<GridItem> openSet, List<GridItem> closeSet) {
    final walkedSet = [...openSet, ...closeSet];

    walkedSet.forEach((e) {
      if (e.selectionType != GridSelectionType.start &&
          e.selectionType != GridSelectionType.wall &&
          e.selectionType != GridSelectionType.cu &&
          e.selectionType != GridSelectionType.end) {
        e.selectionType = GridSelectionType.walked;
      }
    });
  }

  List<GridItem> buildPathForSolution(GridItem end) {
    final path = <GridItem>[];
    GridItem temp = end;
    path.add(temp);

    while (temp.spot.previous != null) {
      path.add(temp.spot.previous);
      temp = temp.spot.previous;
    }

    return path;
  }

  void _initSpotWithPrevious(List<GridItem> allItems) {
    allItems.forEach((element) {
      element.spot = Spot.zeroCostWithPrevious(element.spot.previous);
    });
  }

  void markElementSolutionAsWalked(GridItem element) {
    element.selectionType =
    element.selectionType == GridSelectionType.solution
        ? GridSelectionType.walked
        : element.selectionType;
  }
}
