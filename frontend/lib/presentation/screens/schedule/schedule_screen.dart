import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/schedule_model.dart';
import '../../providers/schedule_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadSchedules(refresh: true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.headerGrey,
        elevation: 0,
        title: const Text(
          '일정',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          _buildLocationChips(context),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Consumer<ScheduleProvider>(
        builder: (context, provider, _) {
          final weekStart = provider.getWeekStart(0);
          final weekEnd = weekStart.add(const Duration(days: 6));
          final rangeStr =
              '${weekStart.month}/${weekStart.day} ~ ${weekEnd.month}/${weekEnd.day}';
          return Row(
            children: [
              Text(
                '${weekStart.year}년 ',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleText,
                ),
              ),
              Text(
                rangeStr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.activeBlue,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => provider.loadSchedules(refresh: true),
                icon: const Icon(Icons.refresh),
                color: AppColors.activeBlue,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationChips(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, _) {
        if (provider.locations.isEmpty) return const SizedBox.shrink();

        return Container(
          color: AppColors.white,
          padding: const EdgeInsets.only(bottom: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildLocationChip(context, provider, null, '전체'),
                ...provider.locations.map(
                  (loc) => _buildLocationChip(
                    context,
                    provider,
                    loc.id,
                    loc.name,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationChip(
    BuildContext context,
    ScheduleProvider provider,
    String? locationId,
    String label,
  ) {
    final isSelected = provider.selectedLocationId == locationId;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, overflow: TextOverflow.ellipsis),
        selected: isSelected,
        onSelected: (_) {
          provider.setSelectedLocationId(locationId);
          provider.loadSchedules(refresh: true);
        },
        selectedColor: AppColors.activeBlue.withValues(alpha: 0.3),
        checkmarkColor: AppColors.activeBlue,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.schedules.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.schedules.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.errorRed),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        provider.loadSchedules(refresh: true),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        return PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            final weekStart = provider.getWeekStart(index);
            return _buildWeekPage(context, provider, weekStart);
          },
        );
      },
    );
  }

  Widget _buildWeekPage(
    BuildContext context,
    ScheduleProvider provider,
    DateTime weekStart,
  ) {
    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return RefreshIndicator(
      onRefresh: () => provider.loadSchedules(refresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${weekStart.month}월 ${weekStart.day}일 ~ ${weekStart.add(const Duration(days: 6)).month}월 ${weekStart.add(const Duration(days: 6)).day}일',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (i) {
              final date = weekStart.add(Duration(days: i));
              final isToday = _isSameDay(date, DateTime.now());
              return Expanded(
                child: Column(
                  children: [
                    Text(
                      dayLabels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isToday
                            ? AppColors.activeBlue
                            : AppColors.subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildDayColumn(context, provider, date),
                  ],
                ),
              );
            }),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDayColumn(
    BuildContext context,
    ScheduleProvider provider,
    DateTime date,
  ) {
    final schedules = provider.getSchedulesForDate(date);
    final isToday = _isSameDay(date, DateTime.now());

    return Container(
      margin: const EdgeInsets.only(left: 2),
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.activeBlue.withValues(alpha: 0.08)
            : AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday ? AppColors.activeBlue : AppColors.boxBorder,
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${date.month}/${date.day}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isToday ? AppColors.activeBlue : AppColors.subText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '-',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.subText.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...schedules.map((s) => _buildCompactScheduleCard(s)),
        ],
      ),
    );
  }

  Widget _buildCompactScheduleCard(ScheduleModel schedule) {
    Color statusColor;
    switch (schedule.status) {
      case 'AVAILABLE':
        statusColor = AppColors.classTeal;
        break;
      case 'SCHEDULED':
        statusColor = AppColors.alertOrange;
        break;
      case 'CANCELLED':
        statusColor = AppColors.subText;
        break;
      default:
        statusColor = AppColors.titleText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(color: statusColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            schedule.locationName,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${schedule.startTime}~${schedule.endTime}',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.subText,
            ),
          ),
          Text(
            schedule.statusDisplayText,
            style: TextStyle(
              fontSize: 9,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
