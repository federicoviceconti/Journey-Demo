import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey_demo/notifier/model/map_item.dart';
import 'package:journey_demo/services/open_charge_map/charge_map_interactor.dart';
import 'package:journey_demo/services/open_charge_map/response/charging_station_list_response.dart';

mixin ChargeMapMixin {
  final _interactor = GetIt.instance<ChargeMapInteractor>();

  Future<ChargingStationListResponse> getChargingStationsFromStartingPoint({
    LatLng startingPoint,
    int maxResult,
  }) async {
    final response = await _interactor.getChargingStationsFromStartingPoint(
      startingPoint: startingPoint,
      maxResult: maxResult,
    );

    return response;
  }

  List<StationItem> convertChargingStationResponseToItem(
      ChargingStationListResponse response,
      ) {
    return response.items.map((item) {
      return StationItem.fromChargingStationItem(item);
    }).toList();
  }

  Future<List<StationItem>> getChargingStationsAndConvertToItem({
    LatLng startingPoint,
    int maxResult,
  }) async {
    final response = await getChargingStationsFromStartingPoint(
      maxResult: maxResult,
      startingPoint: startingPoint
    );

    if(response.items != null && response.items.isNotEmpty) {
      return convertChargingStationResponseToItem(response);
    } else {
      return [];
    }
  }
}
