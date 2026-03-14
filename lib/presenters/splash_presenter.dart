class SplashPresenter {
  final SplashView _view;

  SplashPresenter(this._view);

  void init() {
    _view.navigateToHomeAfterDelay();
  }
}

abstract class SplashView {
  void navigateToHomeAfterDelay();
}
