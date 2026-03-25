abstract class HomeView {
  void navigateToAdmissions();
}

class HomePresenter {
  final HomeView _view;

  HomePresenter(this._view);

  List<String> getSliderImages() {
    return [
      'https://picsum.photos/id/1/200/300',
      'https://picsum.photos/id/1/200/300',
    ];
  }

  void onAdmissionsClicked() {
    _view.navigateToAdmissions();
  }
}
