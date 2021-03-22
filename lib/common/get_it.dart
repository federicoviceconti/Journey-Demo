import 'package:get_it/get_it.dart';
import 'package:journey_demo/services/api/client.dart';
import 'package:journey_demo/services/ev/ev_service.dart';
import 'package:journey_demo/services/open_charge_map/charge_map_interactor.dart';
import 'package:journey_demo/services/open_charge_map/charge_map_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final openChargeClient = Client(basePath: "https://api.openchargemap.io/v3");
  final chargeMapService = ChargeMapService(
    client: openChargeClient,
  );

  getIt.registerLazySingleton(
    () => ChargeMapInteractor(
      service: chargeMapService
    ),
  );

  final evClient = Client(basePath: "https://raw.githubusercontent.com");
  getIt.registerLazySingleton(
    () => EvService(
      client: evClient,
    ),
  );
}
