import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey_demo/environment/app_constants.dart';
import 'package:journey_demo/services/api/client.dart';
import 'package:journey_demo/services/base_service.dart';
import 'package:journey_demo/services/open_charge_map/response/charging_station_list_response.dart';

class ChargeMapService extends BaseService {
  final apiKey = AppConstants.JOURNEY_KEY;

  ChargeMapService({
    @required Client client,
  }): super(client) {
    initHeaders();
  }

  Future<ChargingStationListResponse> getChargingStationsFromStartingPoint(
      {LatLng startingPoint,
      int maxResult = 10}) {
    return client.makeGet(
      "/poi",
      queryParameters: {
        "countrycode": "IT",
        "latitude": startingPoint.latitude,
        "longitude": startingPoint.longitude,
        "maxresults": maxResult,
      },
      converter: (data) => ChargingStationListResponse.fromResponseData(data),
    );
  }

  void initHeaders() {
    client.setCustomHeaders(
        'X-API-Key', apiKey);
    client.setCustomHeaders(
        'User-Agent', 'Journey Demo');
  }
}
