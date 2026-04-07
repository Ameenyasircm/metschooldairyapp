import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPadding {
  AppPadding._();

  static double get xs => 4.r;
  static double get s => 8.r;
  static double get m => 16.r;
  static double get l => 24.r;
  static double get xl => 32.r;

  static EdgeInsets get pS => EdgeInsets.all(s);
  static EdgeInsets get p12 => EdgeInsets.all(12);
  static EdgeInsets get pM => EdgeInsets.all(m);
  static EdgeInsets get pL => EdgeInsets.all(l);
  static EdgeInsets get phS => EdgeInsets.symmetric(horizontal: s);
  static EdgeInsets get phM => EdgeInsets.symmetric(horizontal: m);
  static EdgeInsets get pvS => EdgeInsets.symmetric(vertical: s);
  static EdgeInsets get pvM => EdgeInsets.symmetric(vertical: m);
  static EdgeInsets get phL => EdgeInsets.symmetric(horizontal: l);
  static EdgeInsets get phvS => EdgeInsets.symmetric(horizontal: s,vertical: s);
  static EdgeInsets get phMvS => EdgeInsets.symmetric(horizontal: s,vertical: 5);
}