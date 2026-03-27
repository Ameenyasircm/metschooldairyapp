import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationService {

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  /// Push a new screen
  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.push(
      context,
      MaterialPageRoute(

          builder: (_) => screen),
    );
  }

  /// Replace current screen
  static Future<T?> pushReplacement<T>(BuildContext context, Widget screen) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  /// Remove all previous screens
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget screen) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(

          builder: (_) => screen),
          (route) => false,
    );
  }

  /// Pop screen
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}