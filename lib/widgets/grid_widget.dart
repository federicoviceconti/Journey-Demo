import 'package:flutter/material.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/text/regular_text.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
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
        child: Column(
          children: [
            _buildGridView(),
            SizedBox(height: 40),
            _buildButtons(),
            _buildData(),
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
      child: Container(
        key: key,
        width: 15,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 0.5,
            style: BorderStyle.solid,
          ),
          color: notifier.getGridColor(item),
        ),
        child: Container(
          child: RegularText(
            "(${item.row}, ${item.column})",
            fontSize: 6.5,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  List<Widget> _generateGrid(GridNotifier notifier) {
    return notifier.items
        .map(
          (item) => _buildGrid(notifier, item),
        )
        .toList();
  }

  _buildButtons() {
    return Consumer<GridNotifier>(
      builder: (_, notifier, __) {
        return Row(
          children: [
            Spacer(),
            Expanded(
              flex: 3,
              child: RaisedButton(
                child: BoldText(
                  notifier.wallText,
                  color: Colors.black,
                ),
                onPressed: () => notifier.buildWall(),
              ),
            ),
            Spacer(),
            Expanded(
              flex: 3,
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
        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: notifier.width,
          children: _generateGrid(notifier),
        );
      },
    );
  }

  _buildData() {
    return Consumer<GridNotifier>(
      builder: (_, notifier, __) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              )
            ],
          ),
        );
      },
    );
  }
}
