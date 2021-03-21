import 'dart:convert';

import 'package:journey_demo/notifier/model/plug_type.dart';
import 'package:journey_demo/services/api/base_response.dart';
import 'package:journey_demo/services/api/client.dart';

class EvResponseList extends BaseResponse {
  List<EvItem> items = [];
  List<Brand> brands = [];

  EvResponseList.fromResponseData(ResponseData responseData) {
    super.fromResponseData(responseData);
    final body = jsonDecode(responseData.body);
    this.items = body['data']
        .where((item) => item['vehicle_type'] == 'car')
        .map((item) {
          return EvItem.fromJson(item);
        })
        .toList()
        .cast<EvItem>();

    this.brands = body['data']
        .map((item) {
          return Brand(
            id: item['id'],
            name: item['name'],
          );
        })
        .toList()
        .cast<Brand>();
  }
}

class Brand {
  final String id;
  final String name;

  Brand({
    this.id,
    this.name,
  });
}

class EvItem {
  String uuid;
  String brand;
  String model;
  String type;
  num usableBatterySizeInKwh;
  double averageConsumption;
  int year;
  Set<PlugType> plugs = {};

  EvItem.fromJson(Map<String, dynamic> json) {
    this.uuid = json['id'];
    this.brand = json['brand'];
    this.year = json['release_year'];
    this.model = json['model'];
    this.type = json['type'];
    this.usableBatterySizeInKwh = json['usable_battery_size'];
    this.averageConsumption = json['energy_consumption']['average_consumption'];

    try {
      _addToPlugs(json['ac_charger']['ports']);
    } catch(e) {}

    try {
      _addToPlugs(json['dc_charger']['ports']);
    } catch(e) {}
  }

  void _addToPlugs(items) {
    items.forEach((item) {
      final type = (item as String).type;
      if(type != PlugType.none) {
        plugs.add(type);
      }
    });
  }
}