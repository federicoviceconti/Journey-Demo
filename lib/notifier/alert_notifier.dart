import 'package:journey_demo/navigation/bundle/alert_bundle.dart';
import 'package:journey_demo/navigation/mixin/mixin_route.dart';
import 'package:journey_demo/notifier/base_notifier.dart';

class AlertNotifier extends BaseNotifier with RouteMixin {
  final AlertBundle bundle;

  AlertNotifier({
    this.bundle,
  });

  onActionRightTap() =>
      bundle?.onRightAction?.call(RouteMixin.navigatorKey.currentContext);
}
