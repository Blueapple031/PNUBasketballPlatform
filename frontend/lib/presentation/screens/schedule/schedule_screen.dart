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
  static const double _hourRowHeight = 48;
  static const double _dayColumnWidth = 60;
  static const double _timeColumnWidth = 44;
  static const int _startHour = 8;
  static const int _endHour = 22;
  static const int _totalHours = _endHour - _startHour;

  static const List<Color> _locationColors = [
    Color(0xFF26A69A), // teal - 넉넉한터 본관 방향
    Color(0xFF5C6BC0), // indigo - 넉넉한터 공원 방향
    Color(0xFF42A5F5), // blue - 온천천 부산대역
    Color(0xFF66BB6A), // green
    Color(0xFFFFA726), // orange
    Color(0xFFAB47BC), // purple
    Color(0xFFEC407A), // pink
  ];

  Color _colorForLocation(String locationId, List<ScheduleLocationModel> locations) {
    final idx = locations.indexWhere((l) => l.id == locationId);
    if (idx >= 0) return _locationColors[idx % _locationColors.length];
    final hash = locationId.hashCode.abs();
    return _locationColors[hash % _locationColors.length];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().loadSchedules(refresh: true);
    });
  }

  int _parseTimeToMinutes(String time) {
    final parts = time.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return h * 60 + m;
  }

  double _timeToTop(String time) {
    final min = _parseTimeToMinutes(time);
    final startMin = _startHour * 60;
    return ((min - startMin) / 60) * _hourRowHeight;
  }

  double _timeToHeight(String start, String end) {
    final startMin = _parseTimeToMinutes(start);
    final endMin = _parseTimeToMinutes(end);
    return ((endMin - startMin) / 60) * _hourRowHeight;
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
          final weekStart = provider.weekBase;
          final weekEnd = weekStart.add(const Duration(days: 20));
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

        return RefreshIndicator(
          onRefresh: () => provider.loadSchedules(refresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildTimetableGrid(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildTimetableGrid(
    BuildContext context,
    ScheduleProvider provider,
  ) {
    const dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
    final weekStart = provider.weekBase;
    final totalHeight = _totalHours * _hourRowHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시간 열 (고정, 가로 스크롤 시에도 고정)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: _timeColumnWidth,
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      ...List.generate(_totalHours, (i) {
                        final hour = _startHour + i;
                        return SizedBox(
                          height: _hourRowHeight,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              '$hour',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.subText,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // 3주(21일) 일정 그리드 - 연속 가로 스크롤
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: List.generate(21, (dayIndex) {
              final date = weekStart.add(Duration(days: dayIndex));
              final dayLabel = dayLabels[date.weekday - 1];
              final isToday = _isSameDay(date, DateTime.now());
              final schedules = provider.getSchedulesForDate(date);

              return SizedBox(
                width: _dayColumnWidth,
                child: Column(
                  children: [
                    // 요일 헤더
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              dayLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isToday
                                    ? AppColors.activeBlue
                                    : AppColors.subText,
                              ),
                            ),
                            Text(
                              '${date.month}/${date.day}',
                              style: TextStyle(
                                fontSize: 9,
                                color: isToday
                                    ? AppColors.activeBlue
                                    : AppColors.subText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 시간 슬롯 + 일정 블록
                    SizedBox(
                      height: totalHeight,
                      child: Stack(
                        children: [
                          // 시간 구분선
                          ...List.generate(_totalHours + 1, (i) {
                            return Positioned(
                              left: 0,
                              right: 0,
                              top: i * _hourRowHeight,
                              child: Container(
                                height: 1,
                                color: AppColors.boxBorder.withValues(alpha: 0.6),
                              ),
                            );
                          }),
                          // 일정 블록
                          ...schedules.map((s) {
                            final top = _timeToTop(s.startTime);
                            final height = _timeToHeight(s.startTime, s.endTime);
                            if (top < 0 || top + height > totalHeight) return const SizedBox.shrink();

                            return _buildScheduleBlock(context, provider, s, top, height);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleBlock(
    BuildContext context,
    ScheduleProvider provider,
    ScheduleModel schedule,
    double top,
    double height,
  ) {
    final locationColor = _colorForLocation(schedule.locationId, provider.locations);
    const textStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w500);
    const subStyle = TextStyle(fontSize: 10, color: AppColors.subText);

    return Positioned(
      left: 2,
      right: 2,
      top: top + 2,
      child: GestureDetector(
        onTap: () => _showScheduleDetail(context, schedule, locationColor),
        child: Container(
          height: height.clamp(24, double.infinity) - 4,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: locationColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(color: locationColor, width: 3),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final showFull = h >= 88;
              final showLocation = h >= 36;

              return ClipRect(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (schedule.isTraining && showFull)
                      Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: locationColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '훈련',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: locationColor,
                          ),
                        ),
                      ),
                    if (showLocation)
                      Text(
                        schedule.locationName,
                        style: textStyle.copyWith(fontWeight: FontWeight.w600),
                        maxLines: showFull ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    if (showFull &&
                        schedule.title != null &&
                        schedule.title!.isNotEmpty)
                      Text(
                        schedule.title!,
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    Text(
                      '${schedule.startTime}~${schedule.endTime}',
                      style: subStyle,
                    ),
                    Text(
                      schedule.statusDisplayText,
                      style: subStyle.copyWith(
                        color: locationColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showScheduleDetail(
    BuildContext context,
    ScheduleModel schedule,
    Color accentColor,
  ) {
    final dateStr =
        '${schedule.scheduleDate.year}.${schedule.scheduleDate.month.toString().padLeft(2, '0')}.${schedule.scheduleDate.day.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.boxBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    schedule.locationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.titleText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.calendar_today, '날짜', dateStr),
            _buildDetailRow(
              Icons.access_time,
              '시간',
              '${schedule.startTime} ~ ${schedule.endTime}',
            ),
            _buildDetailRow(
              Icons.info_outline,
              '상태',
              schedule.statusDisplayText,
              valueColor: accentColor,
            ),
            if (schedule.isTraining)
              _buildDetailRow(Icons.fitness_center, '종류', '훈련', valueColor: accentColor),
            if (schedule.title != null && schedule.title!.isNotEmpty)
              _buildDetailRow(Icons.title, '제목', schedule.title!),
            if (schedule.description != null && schedule.description!.isNotEmpty)
              _buildDetailRow(Icons.notes, '설명', schedule.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.subText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.titleText,
                  ),
                ),
              ],
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
