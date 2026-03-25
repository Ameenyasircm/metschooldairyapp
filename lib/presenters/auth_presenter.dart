abstract class LoginView {
  void showError(String message);
  void navigateToHome();
}

class AuthPresenter {
  final LoginView _view;

  AuthPresenter(this._view);

  void login(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      _view.showError("Please enter all fields");
      return;
    }

    // 🔥 Replace with Firebase Auth later
    if (email == "123" && password == "123") {
      _view.navigateToHome();
    } else {
      _view.showError("Invalid credentials");
    }
  }
}