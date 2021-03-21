import 'package:journey_demo/services/ev/response/ev_list_response.dart';

class SessionManager {
  static SessionManager _instance = SessionManager._();

  SessionManager._();

  static SessionManager get instance => _instance;

  EvItem evSelected;
}
