import 'package:journey_demo/navigation/mixin/mixin_route.dart';
import 'package:journey_demo/navigation/routes.dart';
import 'package:journey_demo/notifier/base_notifier.dart';

class OnBoardingNotifier extends BaseNotifier with RouteMixin {
  onNextTap() => navigateTo(RouteEnum.createEv);
}