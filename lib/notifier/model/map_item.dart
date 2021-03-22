import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:journey_demo/services/open_charge_map/response/charging_station_list_response.dart';

class MapItem {
  MapItemType type;
  double latitude;
  double longitude;

  MapItem({
    this.type = MapItemType.marker,
    this.latitude,
    this.longitude,
  });
}

enum MapItemType { marker, chargingStation }

class PositionItem extends MapItem {
  PositionStatus status;

  PositionItem({
    double latitude,
    double longitude,
    this.status,
  }) : super(
          type: MapItemType.marker,
          longitude: longitude,
          latitude: latitude,
        );
}

enum PositionStatus { start, end }

class StationItem extends MapItem {
  num id;
  String uuid;
  String title;
  String addressLine;
  String city;
  String province;
  List<StationPlug> plugs;

  StationItem(
    double latitude,
    double longitude,
  ) : super(
          type: MapItemType.chargingStation,
          latitude: latitude,
          longitude: longitude,
        );

  StationItem.fromChargingStationItem(ChargingStationItem item) {
    this.type = MapItemType.chargingStation;
    this.latitude = item.latitude;
    this.longitude = item.longitude;
    this.title = item.title;
    this.addressLine = item.addressLine;
    this.city = item.city;
    this.province = item.province;
    this.plugs = item.plugs;
    this.id = item.id;
  }

  LatLng getLatLng() {
    return LatLng(latitude, longitude);
  }
}
