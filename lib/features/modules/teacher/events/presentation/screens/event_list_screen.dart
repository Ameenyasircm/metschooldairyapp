import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_padding.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';
import '../../../../../../core/utils/loader/customLoader.dart';
import '../provider/event_provider.dart';
import '../widgets/event_card.dart';
import 'add_edit_event_screen.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<EventProvider>().fetchEvents(refresh: true),
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
    /// pagination trigger
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
          'Events',
          style: AppTypography.h6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditEventScreen(),
            ),
          );
        },
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
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusM,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          /// LIST
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
                final filteredEvents = provider.events.where((event) {

                  final title =
                  event.title.toLowerCase();

                  final description =
                  event.description.toLowerCase();

                  return title.contains(_searchQuery) ||
                      description.contains(_searchQuery);

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

                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) =>
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
                              _searchQuery.isEmpty
                              ? 1
                              : 0),

                      itemBuilder: (context, index) {

                        /// PAGINATION LOADER
                        if (index == filteredEvents.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CustomLoader(),
                            ),
                          );
                        }

                        final event =
                        filteredEvents[index];

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: EventCard(
                            event: event,

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailScreen(
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
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.event_note,
              size: 80,
              color: AppColors.greyE0,
            ),

            AppSpacing.h16,

            Text(
              'No events found',
              textAlign: TextAlign.center,
              style: AppTypography.body1.copyWith(
                color: AppColors.grey5E,
                fontWeight: FontWeight.w600,
              ),
            ),

            AppSpacing.h8,

            Text(
              'Tap the + button to create a new event.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.grey5E,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
