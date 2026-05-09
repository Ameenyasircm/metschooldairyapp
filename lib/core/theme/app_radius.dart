import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class AppRadius {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;
  static const double xl = 24.0;
  static double get circular => 999.r;

  static BorderRadius radiusS = BorderRadius.circular(s);
  static BorderRadius radiusM = BorderRadius.circular(m);
  static BorderRadius radiusL = BorderRadius.circular(l);
  static BorderRadius radiusXL = BorderRadius.circular(xl);
}