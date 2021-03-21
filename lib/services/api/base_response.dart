import 'package:journey_demo/services/api/client.dart';

class BaseResponse {
  int code;

  fromResponseData(ResponseData responseData) {
    this.code = responseData.statusCode;
  }
}
