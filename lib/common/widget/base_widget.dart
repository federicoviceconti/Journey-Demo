import 'package:flutter/material.dart';
import 'package:journey_demo/common/asset/lottie_helper.dart';
import 'package:journey_demo/common/text/bold_text.dart';
import 'package:journey_demo/notifier/mixin/mixin_loader_notifier.dart';

class BaseWidget extends StatelessWidget {
  final Widget child;
  final bool safeArea;
  final LoadingBundle loadingBundle;

  const BaseWidget({
    Key key,
    this.child,
    this.safeArea,
    this.loadingBundle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasSafeArea = safeArea ?? false;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            top: hasSafeArea,
            bottom: hasSafeArea,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: child,
            ),
          ),
          _buildLoader()
        ],
      ),
    );
  }

  _buildLoader() {
    final loadingState = loadingBundle?.state ?? LoadingState.idle;
    return Visibility(
      visible: loadingState != LoadingState.idle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.15),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                child: loadLottieAsset('car_loading'),
              ),
              _buildDescription(),
            ],
          )
        ],
      ),
    );
  }

  _buildDescription() {
    return Visibility(
      visible: loadingBundle?.subtitle?.isNotEmpty ?? false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BoldText(
          loadingBundle?.subtitle ?? '',
          color: Colors.black,
          fontSize: 22,
          align: TextAlign.center,
        ),
      ),
    );
  }
}
