import 'package:get_it/get_it.dart';
import 'package:journey_demo/services/ev/ev_service.dart';
import 'package:journey_demo/services/ev/response/ev_list_response.dart';

mixin EvMixin {
  final service = GetIt.instance<EvService>();

  Future<EvResponseList> getCars() async {
    final responseCarList = await service.getCars();
    return responseCarList;
  }
}