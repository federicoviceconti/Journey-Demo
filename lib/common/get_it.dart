import 'package:get_it/get_it.dart';
import 'package:journey_demo/services/api/client.dart';
import 'package:journey_demo/services/ev/ev_service.dart';
import 'package:journey_demo/services/open_charge_map/charge_map_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final openChargeClient = Client(basePath: "https://api.openchargemap.io/v3");
  getIt.registerLazySingleton(
    () => ChargeMapService(
      client: openChargeClient,
    ),
  );

  final evClient = Client(basePath: "https://raw.githubusercontent.com");
  getIt.registerLazySingleton(
    () => EvService(
      client: evClient,
    ),
  );
}
