import 'package:lottie/lottie.dart';

loadLottieAsset(String assetName) {
  return LottieBuilder.asset("assets/animation/$assetName.json");
}