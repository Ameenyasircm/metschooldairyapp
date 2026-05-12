import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_padding.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../../../../teacher/events/presentation/provider/event_provider.dart';
import '../../../../teacher/events/presentation/widgets/event_card.dart';
import '../../../../teacher/events/data/models/event_model.dart';
import '../../../../teacher/events/presentation/widgets/event_status_chip.dart';
import 'parent_event_detail_screen.dart';

class ParentEventListScreen extends StatefulWidget {
  const ParentEventListScreen({super.key});

  @override
  State<ParentEventListScreen> createState() =>
      _ParentEventListScreenState();
}

class _ParentEventListScreenState extends State<ParentEventListScreen> {

  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(
          () => context
          .read<EventProvider>()
          .fetchEvents(refresh: true),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _onScrollNotification(
      ScrollNotification scrollInfo,
      EventProvider provider,
      ) {

    /// PAGINATION
    if (scrollInfo.metrics.pixels >=
        scrollInfo.metrics.maxScrollExtent - 200 &&
        !provider.isLoading &&
        provider.hasMore &&
        _searchQuery.isEmpty) {

      provider.fetchEvents();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: AppBar(
        title: Text(
          'School Events',
          style: AppTypography.h6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: Column(
        children: [

          /// SEARCH
          Padding(
            padding: AppPadding.pL,
            child: TextField(
              controller: _searchController,

              onChanged: (value) {
                setState(() {
                  _searchQuery =
                      value.trim().toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: 'Search events...',

                prefixIcon: const Icon(
                  Icons.search,
                ),

                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusM,
                ),

                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          /// EVENT LIST
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, provider, child) {

                /// INITIAL LOADING
                if (provider.isInitialLoading) {
                  return const Center(
                    child: CustomLoader(),
                  );
                }

                /// FILTER EVENTS
                final filteredEvents =
                provider.events.where((event) {

                  final title =
                  event.title.toLowerCase();

                  final description =
                  event.description.toLowerCase();

                  return title.contains(
                    _searchQuery,
                  ) ||
                      description.contains(
                        _searchQuery,
                      );

                }).toList();

                /// EMPTY STATE
                if (filteredEvents.isEmpty &&
                    !provider.isLoading) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  backgroundColor: Colors.white,
                  color: AppColors.primary,

                  onRefresh: () async {
                    await provider.fetchEvents(
                      refresh: true,
                    );
                  },

                  child:
                  NotificationListener<
                      ScrollNotification>(
                    onNotification:
                        (scrollInfo) =>
                        _onScrollNotification(
                          scrollInfo,
                          provider,
                        ),

                    child: ListView.builder(
                      physics:
                      const AlwaysScrollableScrollPhysics(),

                      padding: AppPadding.phMvS,

                      itemCount:
                      filteredEvents.length +
                          (provider.hasMore &&
                              _searchQuery
                                  .isEmpty
                              ? 1
                              : 0),

                      itemBuilder:
                          (context, index) {

                        /// PAGINATION LOADER
                        if (index ==
                            filteredEvents.length) {

                          return  Padding(
                            padding:AppPadding.pM,
                            child: Center(
                              child:
                              CustomLoader(),
                            ),
                          );
                        }

                        final event =
                        filteredEvents[index];

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 8.h,
                          ),

                          child: EventCard(
                            event: event,
                            statusWidget: event.isTaskRequired
                                ? FutureBuilder<StudentEventTaskModel?>(
                                    future: provider.getMyChildTaskStatus(event.id),
                                    builder: (context, snapshot) {
                                      final status = snapshot.data?.status ?? 'Pending';
                                      return EventStatusChip(status: status);
                                    },
                                  )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ParentEventDetailScreen(
                                    event: event,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 24,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Icon(
              Icons.event_note,
              size: 80,
              color: AppColors.greyE0,
            ),

            AppSpacing.h16,

            Text(
              'No events scheduled yet',

              textAlign: TextAlign.center,

              style:
              AppTypography.body1.copyWith(
                color: AppColors.grey5E,
                fontWeight: FontWeight.w600,
              ),
            ),

            AppSpacing.h8,

            Text(
              'New school events will appear here.',

              textAlign: TextAlign.center,

              style:
              AppTypography.caption.copyWith(
                color: AppColors.grey5E,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
