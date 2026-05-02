import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:met_school/core/utils/loader/customLoader.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/constants/app_padding.dart';
import '../../../../../../core/constants/app_radius.dart';
import '../../../../../../core/constants/app_spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../provider/notification_provider.dart';

class ParentNotificationScreen extends StatefulWidget {
  final String parentId;
  const ParentNotificationScreen({super.key, required this.parentId});

  @override
  State<ParentNotificationScreen> createState() => _ParentNotificationScreenState();
}

class _ParentNotificationScreenState extends State<ParentNotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      provider.listenToNotifications(widget.parentId);
      provider.markAsSeen(widget.parentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text("Notifications", style: AppTypography.h5.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CustomLoader());
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.greyB2),
                  AppSpacing.vm,
                  Text("No notifications yet", style: AppTypography.body1.copyWith(color: AppColors.textGrey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: AppPadding.pM,
            itemCount: provider.notifications.length,
            separatorBuilder: (context, index) => AppSpacing.vs,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return Container(
                decoration: BoxDecoration(
                  color: notification.isSeen ? AppColors.white : AppColors.primary.withOpacity(0.05),
                  borderRadius: AppRadius.radiusM,
                  border: Border.all(
                    color: notification.isSeen ? AppColors.greyE0 : AppColors.primary.withOpacity(0.2),
                    width: notification.isSeen ? 1 : 1.5,
                  ),
                  boxShadow: [
                    if (!notification.isSeen)
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: ListTile(
                  contentPadding: AppPadding.pM,
                  leading: CircleAvatar(
                    backgroundColor: notification.isSeen ? AppColors.greyE0 : AppColors.primary,
                    child: Icon(
                      Icons.notifications_active,
                      color: notification.isSeen ? AppColors.grey5E : AppColors.white,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.subtitle2.copyWith(
                            fontWeight: notification.isSeen ? FontWeight.w500 : FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                      Text(
                        _formatDate(notification.createdAt),
                        style: AppTypography.caption.copyWith(color: AppColors.textGrey),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      notification.body,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(date);
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else {
      return DateFormat('dd MMM').format(date);
    }
  }
}
