import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/schedule_model.dart';
import '../../providers/schedule_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadSchedules(refresh: true);
    });
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(context, provider),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        DateFormat('yyyy년 M월').format(provider.selectedDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.titleText,
                        side: const BorderSide(color: AppColors.boxBorder),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: provider.selectedLocationId,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('전체 장소'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('전체 장소'),
                        ),
                        ...provider.locations.map(
                          (loc) => DropdownMenuItem<String>(
                            value: loc.id,
                            child: Text(
                              loc.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        provider.setSelectedLocationId(v);
                        provider.loadSchedules(refresh: true);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () =>
                    provider.loadSchedules(refresh: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('새로고침'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.activeBlue,
                ),
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
                _buildLocationChip(
                  context,
                  provider,
                  null,
                  '전체',
                ),
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

  Future<void> _pickDate(BuildContext context, ScheduleProvider provider) async {
    final now = provider.selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      provider.setSelectedDate(
          DateTime(picked.year, picked.month, 1));
      provider.loadSchedules(refresh: true);
    }
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

        final startDate =
            DateTime(provider.selectedDate.year, provider.selectedDate.month, 1);
        final endDate = DateTime(
            provider.selectedDate.year, provider.selectedDate.month + 1, 0);
        final days = endDate.difference(startDate).inDays + 1;

        if (days <= 0) {
          return const Center(
            child: Text('해당 월에 일정이 없습니다.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: days,
          itemBuilder: (context, index) {
            final date = startDate.add(Duration(days: index));
            final grouped = provider.getSchedulesGroupedByLocation(date);
            final hasAny = grouped.values.any((list) => list.isNotEmpty);
            if (!hasAny &&
                date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
              return const SizedBox.shrink();
            }

            return _buildDateSection(date, grouped);
          },
        );
      },
    );
  }

  Widget _buildDateSection(
    DateTime date,
    Map<String, List<ScheduleModel>> groupedByLocation,
  ) {
    final isToday = _isSameDay(date, DateTime.now());
    final dateStr = DateFormat('M/d (E)', 'ko').format(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.activeBlue
                        : AppColors.boxBorder.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.white : AppColors.titleText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...groupedByLocation.entries.map((entry) {
            final locationName = entry.key;
            final schedules = entry.value;
            if (schedules.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    locationName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.activeBlue,
                    ),
                  ),
                ),
                ...schedules.map((s) => _buildScheduleCard(s)),
              ],
            );
          }),
          if (groupedByLocation.values.every((list) => list.isEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '등록된 일정이 없습니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.subText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.boxBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${schedule.startTime} ~ ${schedule.endTime}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (schedule.title != null && schedule.title!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          schedule.title!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    schedule.statusDisplayText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
