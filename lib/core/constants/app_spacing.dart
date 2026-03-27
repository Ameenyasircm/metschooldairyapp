import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  AppSpacing._();

  // Raw values
  static double get xs => 4.r;
  static double get s => 8.r;
  static double get m => 16.r;
  static double get l => 24.r;
  static double get xl => 32.r;
  static double get xxl => 48.r;

  // Vertical Spacing
  static SizedBox get vxs => SizedBox(height: 4.h);
  static SizedBox get vs => SizedBox(height: 8.h);
  static SizedBox get v12 => SizedBox(height: 12.h);
  static SizedBox get vm => SizedBox(height: 16.h);
  static SizedBox get vl => SizedBox(height: 24.h);
  static SizedBox get vxl => SizedBox(height: 32.h);
  static SizedBox get vxxl => SizedBox(height: 40.h);

  // Horizontal Spacing
  static SizedBox get hxs => SizedBox(width: 4.w);
  static SizedBox get hs => SizedBox(width: 8.w);
  static SizedBox get hm => SizedBox(width: 16.w);
  static SizedBox get hl => SizedBox(width: 24.w);
  static SizedBox get hxl => SizedBox(width: 32.w);
  static SizedBox get hxxl => SizedBox(width: 40.w);

  // Legacy/Specific values (keeping for compatibility if needed, but promoting the above)
  static SizedBox get h2 => SizedBox(height: 2.h);
  static SizedBox get h4 => SizedBox(height: 4.h);
  static SizedBox get h6 => SizedBox(height: 6.h);
  static SizedBox get h8 => SizedBox(height: 8.h);
  static SizedBox get h12 => SizedBox(height: 12.h);
  static SizedBox get h16 => SizedBox(height: 16.h);
  static SizedBox get h20 => SizedBox(height: 20.h);
  static SizedBox get h24 => SizedBox(height: 24.h);
  static SizedBox get h32 => SizedBox(height: 32.h);
  static SizedBox get h40 => SizedBox(height: 40.h);
  static SizedBox get h80 => SizedBox(height: 80.h);
  static SizedBox get h100 => SizedBox(height: 100.h);

  static SizedBox get w2 => SizedBox(width: 2.w);
  static SizedBox get w4 => SizedBox(width: 4.w);
  static SizedBox get w8 => SizedBox(width: 8.w);
  static SizedBox get w12 => SizedBox(width: 12.w);
  static SizedBox get w16 => SizedBox(width: 16.w);
  static SizedBox get w24 => SizedBox(width: 24.w);
  static SizedBox get w32 => SizedBox(width: 32.w);
}