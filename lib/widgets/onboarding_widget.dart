import 'package:flutter/material.dart';
import 'package:journey_demo/common/asset/image_helper.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/text/regular_text.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
import 'package:journey_demo/common/widget/border_button.dart';
import 'package:journey_demo/environment/app_constants.dart';
import 'package:journey_demo/notifier/onboarding_notifier.dart';
import 'package:provider/provider.dart';

class OnBoardingWidget extends StatefulWidget {
  @override
  _OnBoardingWidgetState createState() => _OnBoardingWidgetState();
}

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: _buildBody(),
    );
  }

  _buildBody() {
    return Stack(
      children: [
        getPng(
          path: "autumn_bg.jpeg",
          fit: BoxFit.fitHeight,
          height: double.infinity,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 50.0),
                      child: getSvg(
                        path: "marker_dash_line",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  _buildBottom(),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Wrap(
        children: [
          BoldText(
            AppConstants.APP_NAME,
            fontSize: 28.0,
          ),
          BoldText(
            ".",
            fontSize: 28.0,
            color: Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  _buildBottom() {
    return Consumer<OnBoardingNotifier>(
      builder: (_, notifier, __) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BoldText("Start your travel, with us!", fontSize: 20.0),
            SizedBox(height: 8.0),
            RegularText(
                "Select your car, choose your plug\nand enjoy your travel!",
                fontSize: 14.0),
            SizedBox(height: 16.0),
            BorderButton(
              onTap: () => notifier.onNextTap(),
              child: BoldText("Get started!"),
            ),
            SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
