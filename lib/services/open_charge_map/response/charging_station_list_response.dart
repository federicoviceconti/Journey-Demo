import 'package:journey_demo/notifier/model/plug_type.dart';
import 'package:journey_demo/services/api/base_response.dart';
import 'package:journey_demo/services/api/client.dart';

class ChargingStationListResponse extends BaseResponse {
  List<ChargingStationItem> items = [];

  ChargingStationListResponse.fromResponseData(ResponseData responseData) {
    super.fromResponseData(responseData);

    this.items = responseData.body != null
        ? responseData.body
            .map((item) {
              try {
                return ChargingStationItem.fromJson(item);
              } catch (e) {
                return null;
              }
            })
            .where((item) => item != null)
            .toList()
            .cast<ChargingStationItem>()
        : [];
  }
}

class ChargingStationItem {
  String uuid;
  num id;
  double latitude;
  double longitude;
  String title;
  String addressLine;
  String city;
  String province;
  List<StationPlug> plugs;

  ChargingStationItem.fromJson(Map<String, dynamic> json) {
    this.uuid = json['UUID'];
    this.latitude = json['AddressInfo']['Latitude'];
    this.longitude = json['AddressInfo']['Longitude'];
    this.title = json['AddressInfo']['Title'];
    this.addressLine = _buildAddressLine(json['AddressInfo']);
    this.city = json['AddressInfo']['Town'];
    this.province = json['AddressInfo']['StateOrProvince'];
    this.plugs = _buildPlugs(json['Connections']);
    this.id = json['ID'];
  }

  String _buildAddressLine(Map<String, dynamic> json) {
    return '${json['AddressLine1'] ?? ''} ${json['AddressLine2'] ?? ''}'.trim();
  }

  List<StationPlug> _buildPlugs(List<dynamic> json) {
    return json
        .map((element) {
          try {
            return StationPlug(
              type: (element['ConnectionType']['Title'] as String).cuType,
              powerKW: element['PowerKW'],
            );
          } catch (e) {
            print(e);
            return null;
          }
        })
        .where((element) => element != null && element.type != PlugType.none)
        .toList();
  }
}

class StationPlug {
  PlugType type = PlugType.none;
  num powerKW = 0;

  StationPlug({
    this.type,
    this.powerKW,
  });
}
