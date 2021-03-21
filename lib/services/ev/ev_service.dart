import 'package:flutter/material.dart';
import 'package:journey_demo/services/api/client.dart';
import 'package:journey_demo/services/base_service.dart';
import 'package:journey_demo/services/ev/response/ev_list_response.dart';

class EvService extends BaseService {
  EvService({
    @required Client client,
  }) : super(client);

  Future<EvResponseList> getCars() {
    return client.makeGet(
      "/chargeprice/open-ev-data/master/data/ev-data.json",
      converter: (data) => EvResponseList.fromResponseData(data),
    );
  }
}
