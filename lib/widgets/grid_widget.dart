import 'package:flutter/material.dart';
import 'package:journey_demo/common/asset/image_helper.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/text/regular_text.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
import 'package:journey_demo/common/widget/card_tooltip.dart';
import 'package:journey_demo/notifier/grid_notifier.dart';
import 'package:journey_demo/notifier/model/plug_type.dart';
import 'package:journey_demo/services/open_charge_map/response/charging_station_list_response.dart';
import 'package:provider/provider.dart';
import 'package:journey_demo/notifier/model/grid_item.dart';

class GridWidget extends StatefulWidget {
  @override
  _GridWidgetState createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<GridNotifier>(context, listen: false).init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      loadingBundle: Provider
          .of<GridNotifier>(context)
          .loadingBundle,
      child: _buildBody(),
    );
  }

  _buildBody() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          Provider.of<GridNotifier>(context, listen: false).reload();
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildGridView(),
                  SizedBox(height: 8),
                  _buildSolutionInfo(),
                  _buildButtons(),
                  _buildSolutions(),
                  _buildData(),
                ],
              ),
            ),
            _buildTooltip(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(GridNotifier notifier, GridItem item) {
    final key = GlobalKey();

    return GestureDetector(
      onTap: () {
        notifier.onGridTap(item);
      },
      onLongPress: () {
        notifier.showTooltipOnPosition(key, item);
      },
      child: Container(
        key: key,
        width: 15,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 0.5,
            style: BorderStyle.solid,
          ),
          color: notifier.getGridColor(item.selectionType),
        ),
        child: Container(
          child: RegularText(
            "(${item.row}, ${item.column})",
            fontSize: 7,
            color: item.selectionType != GridSelectionType.wall
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    );
  }

  List<Widget> _generateGrid(GridNotifier notifier) {
    return notifier.items.map((item) => _buildGrid(notifier, item)).toList();
  }

  _buildButtons() {
    return Consumer<GridNotifier>(
      builder: (_, notifier, __) {
        return Visibility(
          visible: !notifier.calculatingPath,
          child: Row(
            children: [
              Spacer(),
              Visibility(
                visible: !notifier.lockClick,
                child: Expanded(
                  flex: 4,
                  child: RaisedButton(
                    child: BoldText(
                      "Change state",
                      color: Colors.black,
                    ),
                    onPressed: () => notifier.changeStateOnTap(),
                  ),
                ),
              ),
              Visibility(
                visible: !notifier.lockClick,
                child: Spacer(),
              ),
              Visibility(
                visible: !notifier.lockClick,
                child: Expanded(
                  flex: 4,
                  child: RaisedButton(
                    child: BoldText(
                      "Calculate",
                      color: Colors.black,
                    ),
                    onPressed: () => notifier.calculatePath(),
                  ),
                ),
              ),
              Visibility(
                visible: !notifier.lockClick,
                child: Spacer(),
              ),
              Expanded(
                flex: 4,
                child: RaisedButton(
                  child: BoldText(
                    "Clear all",
                    color: Colors.black,
                  ),
                  onPressed: () => notifier.clearAll(),
                ),
              ),
              Spacer(),
            ],
          ),
        );
      },
    );
  }

  _buildGridView() {
    return Consumer<GridNotifier>(
      builder: (_, notifier, __) {
        return Stack(
          children: [
            GridView.count(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: notifier.width,
              children: _generateGrid(notifier),
            ),
          ],
        );
      },
    );
  }

  _buildData() {
    return Consumer<GridNotifier>(
      builder: (_, notifier, __) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend(notifier),
              _buildGridInformation(notifier),
            ],
          ),
        );
      },
    );
  }

  _buildLegendItem(GridNotifier notifier, GridSelectionType type,
      {String append}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 0.5,
              style: BorderStyle.solid,
            ),
            color: notifier.getGridColor(type),
          ),
        ),
        SizedBox(width: 5),
        RegularText(
          "${notifier.getTextBySelectionType(type)}${append ?? ''}",
          color: Colors.black,
        ),
      ],
    );
  }

  _buildLegend(GridNotifier notifier) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoldText(
            "Legend",
            color: Colors.black,
          ),
          SizedBox(height: 4),
          _buildLegendItem(notifier, GridSelectionType.start, append: "/End"),
          _buildLegendItem(notifier, GridSelectionType.wall),
          _buildLegendItem(notifier, GridSelectionType.path),
          _buildLegendItem(notifier, GridSelectionType.walked),
          _buildLegendItem(notifier, GridSelectionType.cu),
          _buildLegendItem(notifier, GridSelectionType.solution),
          _buildLegendItem(notifier, GridSelectionType.none),
        ],
      ),
    );
  }

  _buildGridInformation(GridNotifier notifier) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoldText(
            "Grid data",
            color: Colors.black,
          ),
          SizedBox(height: 4),
          _buildRowInformation(
            "Grid size: ",
            "${notifier.width}x${notifier.height}",
          ),
          _buildRowInformation(
            "Diagonal move: ",
            "${notifier.allowDiagonal}",
          ),
          _buildRowInformation(
            "Current state: ",
            "${notifier.currentStateText}",
          ),
          _buildRowInformation(
            "EV: ",
            "${notifier.evNameTotal ?? ''}",
          ),
          _buildRowInformation(
            "Battery size (kWh): ",
            "${notifier.batterySizeKWH ?? ''}",
          ),
          _buildRowInformation(
            "kWh/100km: ",
            "${notifier.averageConsumptionKwh ?? ''}",
          ),
          _buildRowInformation(
            "CU available: ",
            "${notifier.cuAvailable ?? ''}",
          ),
        ],
      ),
    );
  }

  _buildTooltip() {
    return Consumer<GridNotifier>(
      builder: (_, notifier, __) {
        final bundle = notifier.tooltipBundle;

        if (bundle == null) {
          return IgnorePointer();
        } else {
          final List<StationPlug> stationPlugs = bundle.descriptionWithImages
              .item2;

          return Positioned(
            top: bundle.top,
            left: bundle.left,
            child: CardTooltip(
              width: bundle.width,
              title: bundle.title,
              subtitle: bundle.subtitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  BoldText(
                    bundle.descriptionWithImages.item1,
                    color: Colors.black,
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    children: _buildPlugs(stationPlugs),
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }

  _buildPlugs(final List<StationPlug> plugs) {
    return plugs
        .map(
          (e) =>
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: getSvg(
              path: e.type.svg,
              width: 30,
            ),
          ),
    )
        .toList();
  }

  _buildRowInformation(String title, String text) {
    return Row(
      children: [
        BoldText(
          title,
          color: Colors.black,
        ),
        RegularText(
          text,
          color: Colors.black,
        ),
      ],
    );
  }

  _buildSolutionInfo() {
    return Consumer<GridNotifier>(
      builder: (_, notifier, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Column(
            children: [
              Visibility(
                visible: notifier.lockClick,
                child: _buildRowInformation(
                    "Total km: ", "${notifier.totalSolutionKm}"),
              ),
              Visibility(
                visible: notifier.lockClick,
                child: _buildRowInformation(
                  "Necessary kWh/${notifier.totalSolutionKm}km: ",
                  "${notifier.necessaryKwhForSolution}",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildSolutions() {
    return Consumer<GridNotifier>(
      builder: (_, notifier, __) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoldText("Solutions:", color: Colors.black),
              SizedBox(height: 4),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, index) =>
                    _buildSolutionItem(
                      index,
                      notifier,
                    ),
                separatorBuilder: (_, __) => Divider(),
                itemCount: notifier.solutions.length,
              ),
            ],
          ),
        );
      },
    );
  }

  _buildSolutionItem(int index, GridNotifier notifier) {
    final solution = notifier.solutions[index];
    final cuInPath = notifier
        .getElementsByType(solution, GridSelectionType.cu)
        .length;

    return GestureDetector(
      onTap: () => notifier.onSolutionTap(index),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RegularText(
                  "Solution #$index len ${solution.length}",
                  color: Colors.black,
                ),
                RegularText(
                  "CU in path: $cuInPath",
                  color: Colors.black,
                ),
              ],
            ),
          ),
          RaisedButton(
            onPressed: () => notifier.onTripDetail(index),
            color: Colors.white,
            elevation: 2,
            child: BoldText("Show trip detail", color: Colors.black),
          )
        ],
      ),
    );
  }
}
