import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:journey_demo/common/asset/image_helper.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/text/regular_text.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
import 'package:journey_demo/notifier/model/plug_type.dart';
import 'package:journey_demo/notifier/selectev_notifier.dart';
import 'package:journey_demo/services/ev/response/ev_list_response.dart';
import 'package:journey_demo/widgets/search_box.dart';
import 'package:provider/provider.dart';

class SelectEvWidget extends StatefulWidget {
  @override
  _SelectEvWidgetState createState() => _SelectEvWidgetState();
}

class _SelectEvWidgetState extends State<SelectEvWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<SelectEvNotifier>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      safeArea: true,
      child: _buildBody(),
      loadingBundle: Provider.of<SelectEvNotifier>(context).loadingBundle,
    );
  }

  _buildBody() {
    return Consumer<SelectEvNotifier>(
      builder: (_, notifier, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              _buildBackButton(notifier),
              SizedBox(height: 16),
              BoldText(
                "Select EV",
                fontSize: 32,
                color: Colors.deepOrange,
              ),
              SizedBox(height: 16),
              SearchBox(
                controller: notifier.searchController,
                hintText: "Search your car...",
              ),
              SizedBox(height: 16),
              Expanded(
                child: _buildList(notifier),
              )
            ],
          ),
        );
      },
    );
  }

  _buildBackButton(SelectEvNotifier notifier) {
    return GestureDetector(
      onTap: () => notifier.pop(),
      child: Icon(
        Icons.arrow_back_ios,
        color: Colors.deepOrangeAccent,
      ),
    );
  }

  _buildList(SelectEvNotifier notifier) {
    return ListView.separated(
      separatorBuilder: (_, __) => Divider(),
      shrinkWrap: true,
      itemBuilder: (_, index) {
        final item = notifier.evItems[index];
        return _buildCarItem(item);
      },
      itemCount: notifier.evItems.length,
    );
  }

  _buildCarItem(EvItem item) {
    return Column(
      children: [
        ListTile(
          onTap: () => Provider.of<SelectEvNotifier>(context, listen: false)
              .onItemTap(item),
          leading: Container(
            alignment: Alignment.center,
            width: 80,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.black,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: BoldText(
              "${item.brand}",
              color: Colors.black,
              fontSize: 10,
              align: TextAlign.center,
            ),
          ),
          title: BoldText(
            "${item.model}, ${item.year ?? ''}",
            color: Colors.black,
          ),
          subtitle: _buildPlugs(item),
        ),
        SizedBox(height: 4.0),
      ],
    );
  }

  _buildPlugs(EvItem item) {
    return item.plugs == null
        ? Container()
        : Wrap(
            children: [
              ...item.plugs?.map(
                (plug) => Container(
                  width: 50,
                  height: 70,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      getSvg(
                        path: plug.svg,
                        width: 30,
                        height: 30,
                      ),
                      RegularText(
                        plug?.name ?? '',
                        color: Colors.black,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
