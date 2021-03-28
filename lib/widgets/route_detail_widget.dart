import 'package:flutter/material.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
import 'package:journey_demo/notifier/route_detail_notifier.dart';
import 'package:provider/provider.dart';

class RouteDetailWidget extends StatefulWidget {
  @override
  _RouteDetailWidgetState createState() => _RouteDetailWidgetState();
}

class _RouteDetailWidgetState extends State<RouteDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      safeArea: true,
      child: _buildBody(),
    );
  }

  _buildBody() {
    final notifier = Provider.of<RouteDetailNotifier>(context, listen: false);
    return GestureDetector(
      onTap: () => notifier.pop(),
      child: Icon(
        Icons.arrow_back_ios,
        color: Colors.orange,
      ),
    );
  }
}