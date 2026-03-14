abstract class HomeView {
  void navigateToAdmissions();
}

class HomePresenter {
  final HomeView _view;

  HomePresenter(this._view);

  List<String> getSliderImages() {
    return [
      'https://images.unsplash.com/photo-1509062522246-3755977927d7?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1577896851231-70ef18881754?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
    ];
  }

  void onAdmissionsClicked() {
    _view.navigateToAdmissions();
  }
}
