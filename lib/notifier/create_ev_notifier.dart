import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:journey_demo/environment/session_manager.dart';
import 'package:journey_demo/environment/session_manager.dart';
import 'package:journey_demo/navigation/bundle/alert_bundle.dart';
import 'package:journey_demo/navigation/routes.dart';
import 'package:journey_demo/notifier/base_notifier.dart';
import 'package:journey_demo/services/ev/response/ev_list_response.dart';

import 'mixin/mixin_loader_notifier.dart';

class CreateEvNotifier extends BaseNotifier with LoaderNotifierMixin {
  final _nameController = TextEditingController();
  final _selectEvController = TextEditingController();

  EvItem _evItem;

  TextEditingController get nameController => _nameController;
  TextEditingController get selectEvController => _selectEvController;

  bool get isEnableButton => _nameController.text.isNotEmpty
    && _selectEvController.text.isNotEmpty;

  goToSelectEv() async {
    _evItem = (await navigateTo(RouteEnum.selectEv)) as EvItem;

    if(_evItem != null) {
      _selectEvController.text = "${_evItem.brand} ${_evItem.model}";
      notifyListeners();
    }
  }

  onFieldChange() => notifyListeners();

  onNextTap() {
    SessionManager.instance.evSelected = _evItem;

    navigateTo(RouteEnum.alert, arguments: AlertBundle(
      onRightAction: (_) {
        navigateTo(RouteEnum.grid, isRoot: true);
      }
    ));
  }
}