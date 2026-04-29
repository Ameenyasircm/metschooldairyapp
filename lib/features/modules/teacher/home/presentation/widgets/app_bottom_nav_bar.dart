import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:met_school/core/theme/app_colors.dart';
import 'package:met_school/core/theme/app_typography.dart';

import '../../viewmodels/teacher_home_viewmodel.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherHomeViewModel>(
      builder: (context, viewModel, _) {
        final selectedIndex = viewModel.selectedIndex;
        return BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => context.read<TeacherHomeViewModel>().setSelectedIndex(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey5E,
          selectedLabelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTypography.caption,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      },
    );
  }
}
