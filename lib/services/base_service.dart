import 'package:journey_demo/services/api/client.dart';

abstract class BaseService {
  final Client client;

  BaseService(this.client);
}