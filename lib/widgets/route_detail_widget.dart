import 'package:flutter/material.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/text/regular_text.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
import 'package:journey_demo/notifier/route_detail_notifier.dart';
import 'package:provider/provider.dart';

class RouteDetailWidget extends StatefulWidget {
  @override
  _RouteDetailWidgetState createState() => _RouteDetailWidgetState();
}

class _RouteDetailWidgetState extends State<RouteDetailWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<RouteDetailNotifier>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      safeArea: true,
      child: _buildBody(),
    );
  }

  _buildBody() {
    return Consumer<RouteDetailNotifier>(
      builder: (_, notifier, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => notifier.pop(),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.deepOrange,
                ),
              ),
              SizedBox(height: 16),
              BoldText(
                "Trip detail",
                fontSize: 32,
                color: Colors.deepOrange,
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (_, index) {
                    final direction = notifier.directions[index];
                    return ListTile(
                      title: direction.title.isNotEmpty
                          ? BoldText(
                              direction.title,
                              color: Colors.black,
                            )
                          : Container(),
                      subtitle: direction.message.isNotEmpty
                          ? RegularText(
                              direction.message,
                              color: Colors.black,
                            )
                          : Container(),
                    );
                  },
                  itemCount: notifier.directions.length,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
