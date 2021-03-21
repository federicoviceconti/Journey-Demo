import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:journey_demo/navigation/mixin/mixin_route.dart';
import 'package:journey_demo/notifier/base_notifier.dart';
import 'package:journey_demo/notifier/mixin/mixin_loader_notifier.dart';
import 'package:journey_demo/services/ev/ev_service.dart';
import 'package:journey_demo/services/ev/response/ev_list_response.dart';

class SelectEvNotifier extends BaseNotifier
    with RouteMixin, LoaderNotifierMixin {
  final searchController = TextEditingController();

  List<EvItem> _evList;
  List<EvItem> _filterEvList;

  List<EvItem> get evItems {
    return _filterEvList ?? [];
  }

  init() async {
    showLoader();

    searchController.addListener(() {
      onTextSearchChanged();
    });

    final service = GetIt.instance<EvService>();
    final responseCarList = await service.getCars();
    if (responseCarList.items.isNotEmpty) {
      _evList = responseCarList.items;
      _filterEvList = [..._evList];
    }

    hideLoader();
  }

  onTextSearchChanged() {
    String value = searchController.text.toLowerCase();

    if (value.isEmpty) {
      _filterEvList = _evList.toList();
    } else {
      _filterEvList = _evList
          .where(
            (element) =>
                element.model.toLowerCase().contains(value) ||
                element.year.toString().contains(value),
          )
          .toList();
    }

    notifyListeners();
  }

  onItemTap(EvItem item) => pop(item);

  onBackTap() => pop();
}
