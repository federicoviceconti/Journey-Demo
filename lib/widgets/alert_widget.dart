import 'package:flutter/material.dart';
import 'package:journey_demo/common/asset/lottie_helper.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/common/text/regular_text.dart';
import 'package:journey_demo/common/widget/base_widget.dart';
import 'package:journey_demo/common/widget/border_button.dart';
import 'package:journey_demo/notifier/alert_notifier.dart';
import 'package:provider/provider.dart';

class AlertWidget extends StatefulWidget {
  @override
  _AlertWidgetState createState() => _AlertWidgetState();
}

class _AlertWidgetState extends State<AlertWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AlertNotifier>(
      builder: (_, notifier, __) {
        return BaseWidget(
          safeArea: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: loadLottieAsset('success'),
                    ),
                    BoldText(
                      "Horray!",
                      color: Colors.black,
                      fontSize: 32,
                    ),
                    SizedBox(height: 32.0),
                    RegularText(
                      "You will redirect to home, enjoy!",
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              BorderButton(
                onTap: () => notifier.onActionRightTap(),
                child: BoldText("OK"),
              )
            ],
          ),
        );
      },
    );
  }
}
