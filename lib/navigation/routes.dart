import 'package:flutter/material.dart';
import 'package:journey_demo/navigation/bundle/alert_bundle.dart';
import 'package:journey_demo/navigation/bundle/route_detail_bundle.dart';
import 'package:journey_demo/notifier/alert_notifier.dart';
import 'package:journey_demo/notifier/create_ev_notifier.dart';
import 'package:journey_demo/notifier/grid_notifier.dart';
import 'package:journey_demo/notifier/map_notifier.dart';
import 'package:journey_demo/notifier/onboarding_notifier.dart';
import 'package:journey_demo/notifier/route_detail_notifier.dart';
import 'package:journey_demo/notifier/selectev_notifier.dart';
import 'package:journey_demo/widgets/alert_widget.dart';
import 'package:journey_demo/widgets/grid_widget.dart';
import 'package:journey_demo/widgets/map_widget.dart';
import 'package:journey_demo/widgets/onboarding_widget.dart';
import 'package:journey_demo/widgets/create_ev_widget.dart';
import 'package:journey_demo/widgets/route_detail_widget.dart';
import 'package:journey_demo/widgets/select_ev_widget.dart';
import 'package:provider/provider.dart';

class Routes {
  static Map<String, WidgetBuilder> get routes {
    return {
      RouteEnum.onBoarding.name: (_) {
        return ChangeNotifierProvider(
          create: (_) => OnBoardingNotifier(),
          child: OnBoardingWidget(),
        );
      },
      RouteEnum.createEv.name: (_) {
        return ChangeNotifierProvider(
          create: (_) => CreateEvNotifier(),
          child: CreateYourEvWidget(),
        );
      },
      RouteEnum.selectEv.name: (_) {
        return ChangeNotifierProvider(
          create: (_) => SelectEvNotifier(),
          child: SelectEvWidget(),
        );
      },
      RouteEnum.alert.name: (context) {
        AlertBundle alertBundle = ModalRoute.of(context).settings.arguments;
        return ChangeNotifierProvider(
          create: (_) => AlertNotifier(bundle: alertBundle),
          child: AlertWidget(),
        );
      },
      RouteEnum.map.name: (context) {
        return ChangeNotifierProvider(
          create: (_) => MapNotifier(),
          child: MapWidget(),
        );
      },
      RouteEnum.grid.name: (context) {
        return ChangeNotifierProvider(
          create: (_) => GridNotifier(),
          child: GridWidget(),
        );
      },
      RouteEnum.routeDetail.name: (context) {
        RouteDetailBundle bundle = ModalRoute.of(context).settings.arguments;

        return ChangeNotifierProvider(
          create: (_) => RouteDetailNotifier(routeDetailBundle: bundle),
          child: RouteDetailWidget(),
        );
      },
    };
  }

  static String get initial => RouteEnum.onBoarding.name;
}

enum RouteEnum {
  onBoarding,
  createEv,
  selectEv,
  alert,
  map,
  grid,
  routeDetail,
}

extension RouteExtension on RouteEnum {
  String get name {
    return {
      RouteEnum.onBoarding: '/onBoarding',
      RouteEnum.createEv: '/createEv',
      RouteEnum.selectEv: '/selectEv',
      RouteEnum.alert: '/alert',
      RouteEnum.map: '/map',
      RouteEnum.grid: '/grid',
      RouteEnum.routeDetail: '/routeDetail',
    }[this];
  }
}
