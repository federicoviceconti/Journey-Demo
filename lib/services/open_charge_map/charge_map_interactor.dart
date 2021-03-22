import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey_demo/services/open_charge_map/response/charging_station_list_response.dart';

import 'charge_map_service.dart';

class ChargeMapInteractor {
  ChargeMapService service;

  ChargeMapInteractor({this.service});

  Future<ChargingStationListResponse> getChargingStationsFromStartingPoint({
    LatLng startingPoint,
    int maxResult,
  }) async {
    return await service.getChargingStationsFromStartingPoint(
      latitude: startingPoint.latitude,
      longitude: startingPoint.longitude,
      maxResult: maxResult,
    );
  }
}
