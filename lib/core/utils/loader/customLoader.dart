import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';

class CustomLoader extends StatelessWidget {
  final  Color loaderColor;
  const CustomLoader({super.key,this.loaderColor=AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 32.w,
          height: 32.h,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            value: 1.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[300]!),
          ),
        ),
        SizedBox(
          width: 30.w,
          height: 30.h,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
          ),
        ),
      ],
    );
  }
}