import 'package:flutter/material.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/text/regular_text.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
import 'package:journey_demo/common/widget/card_tooltip.dart';
import 'package:journey_demo/notifier/grid_notifier.dart';
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
      loadingBundle: Provider.of<GridNotifier>(context).loadingBundle,
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildGridView(),
              SizedBox(height: 8),
              _buildButtons(),
              _buildData(),
            ],
          ),
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
        return Row(
          children: [
            Spacer(),
            Expanded(
              flex: 4,
              child: RaisedButton(
                child: BoldText(
                  "Change state",
                  color: Colors.black,
                ),
                onPressed: () => notifier.changeStateOnTap(),
              ),
            ),
            Spacer(),
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
            _buildTooltip(notifier),
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

  _buildLegendItem(GridNotifier notifier, GridSelectionType type) {
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
          "${notifier.getTextBySelectionType(type)}",
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
          _buildLegendItem(notifier, GridSelectionType.start),
          _buildLegendItem(notifier, GridSelectionType.end),
          _buildLegendItem(notifier, GridSelectionType.wall),
          _buildLegendItem(notifier, GridSelectionType.path),
          _buildLegendItem(notifier, GridSelectionType.cu),
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
          Row(
            children: [
              BoldText(
                "Grid size: ",
                color: Colors.black,
              ),
              RegularText(
                "${notifier.width}x${notifier.height}",
                color: Colors.black,
              ),
            ],
          ),
          Row(
            children: [
              BoldText(
                "Current state: ",
                color: Colors.black,
              ),
              RegularText(
                "${notifier.currentStateText}",
                color: Colors.black,
              ),
            ],
          ),
          Row(
            children: [
              BoldText(
                "EV: ",
                color: Colors.black,
              ),
              RegularText(
                "${notifier.evNameTotal ?? ''}",
                color: Colors.black,
              ),
            ],
          ),
          Row(
            children: [
              BoldText(
                "Battery size (kWh): ",
                color: Colors.black,
              ),
              RegularText(
                "${notifier.batterySizeKWH ?? ''}",
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildTooltip(GridNotifier notifier) {
    final bundle = notifier.tooltipBundle;

    if (bundle == null) {
      return IgnorePointer();
    } else {
      return Positioned(
        top: bundle.top,
        left: bundle.left,
        child: CardTooltip(
          width: bundle.width,
          title: bundle.title,
          subtitle: bundle.subtitle,
        ),
      );
    }
  }
}
