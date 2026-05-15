import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(
    String message, {
      Color backgroundColor = Colors.black87,
      Color textColor = Colors.white,
    }) {

  Fluttertoast.showToast(
    msg: message,

    toastLength: Toast.LENGTH_SHORT,

    gravity: ToastGravity.BOTTOM,

    backgroundColor: backgroundColor,

    textColor: textColor,

    fontSize: 14,
  );
}