import 'package:journey_demo/notifier/base_notifier.dart';

mixin LoaderNotifierMixin on BaseNotifier {
  String _subtitle;
  LoadingState _state = LoadingState.idle;

  LoadingBundle get loadingBundle =>
      LoadingBundle(state: _state, subtitle: _subtitle);

  _setLoadingState(LoadingState state, {String subtitle}) {
    _state = state;
    _subtitle = subtitle;
    notifyListeners();
  }

  void showLoader({String subtitle}) {
    _setLoadingState(
      LoadingState.loading,
      subtitle: subtitle,
    );
  }

  void hideLoader() {
    _setLoadingState(LoadingState.idle);
  }
}

class LoadingBundle {
  final LoadingState state;
  final String subtitle;

  LoadingBundle({
    this.state,
    this.subtitle,
  });
}

enum LoadingState { idle, loading }
