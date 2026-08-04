import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/recruitment_model.dart';
import '../../providers/recruitment_provider.dart';

class RecruitmentListView extends StatefulWidget {
  const RecruitmentListView({super.key});

  @override
  State<RecruitmentListView> createState() => _RecruitmentListViewState();
}

class _RecruitmentListViewState extends State<RecruitmentListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecruitmentProvider>().loadRecruitments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecruitmentProvider>(
      builder: (context, provider, _) {
        return ColoredBox(
          color: Colors.white,
          child: Column(
            children: [
              _buildFilters(provider),
              _buildListHeader(provider),
              const Divider(height: 1),
              Expanded(child: _buildContent(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(RecruitmentProvider provider) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        children: [
          _FilterChipItem(
            label: '전체',
            isActive: provider.filterGameFormat == null,
            onTap: () => provider.setFilter(
              gameFormat: null,
              status: provider.filterStatus,
            ),
          ),
          const SizedBox(width: 6),
          _FilterChipItem(
            label: '3:3',
            isActive: provider.filterGameFormat == 'THREE_VS_THREE',
            onTap: () => provider.setFilter(
              gameFormat: 'THREE_VS_THREE',
              status: provider.filterStatus,
            ),
          ),
          const SizedBox(width: 6),
          _FilterChipItem(
            label: '4:4',
            isActive: provider.filterGameFormat == 'FOUR_VS_FOUR',
            onTap: () => provider.setFilter(
              gameFormat: 'FOUR_VS_FOUR',
              status: provider.filterStatus,
            ),
          ),
          const SizedBox(width: 6),
          _FilterChipItem(
            label: '5:5',
            isActive: provider.filterGameFormat == 'FIVE_VS_FIVE',
            onTap: () => provider.setFilter(
              gameFormat: 'FIVE_VS_FIVE',
              status: provider.filterStatus,
            ),
          ),
          const SizedBox(width: 6),
          _FilterChipItem(
            label: '자유',
            isActive: provider.filterGameFormat == 'FLEXIBLE',
            onTap: () => provider.setFilter(
              gameFormat: 'FLEXIBLE',
              status: provider.filterStatus,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(RecruitmentProvider provider) {
    final onlyOpen = provider.filterStatus == 'OPEN';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 12, 8),
      child: Row(
        children: [
          Text(
            '총 ${provider.recruitments.length}개의 번개',
            style: const TextStyle(
              color: AppColors.titleText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Text(
            '마감 경기 가리기',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
          Transform.scale(
            scale: 0.72,
            child: Switch(
              value: onlyOpen,
              activeTrackColor: AppColors.activeBlue,
              onChanged: (value) => provider.setFilter(
                status: value ? 'OPEN' : null,
                gameFormat: provider.filterGameFormat,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RecruitmentProvider provider) {
    if (provider.isLoading && provider.recruitments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.activeBlue),
      );
    }
    if (provider.recruitments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.activeBlue,
      onRefresh: provider.loadRecruitments,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: provider.recruitments.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 84),
        itemBuilder: (context, index) => _RecruitmentRow(
          recruitment: provider.recruitments[index],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.softPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_basketball_outlined,
                size: 32,
                color: AppColors.activeBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '지금 열려 있는 번개가 없어요',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              '직접 모집을 열어 첫 경기를 만들어보세요.',
              style: TextStyle(fontSize: 12, color: AppColors.subText),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF595A61),
      labelStyle: TextStyle(
        color: isActive ? Colors.white : AppColors.titleText,
        fontSize: 11,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      shape: StadiumBorder(
        side: BorderSide(
          color: isActive ? const Color(0xFF595A61) : AppColors.border,
        ),
      ),
    );
  }
}

class _RecruitmentRow extends StatelessWidget {
  final RecruitmentListModel recruitment;

  const _RecruitmentRow({required this.recruitment});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(recruitment.startAt);
    final endTime = DateFormat('HH:mm').format(recruitment.endAt);
    final date = DateFormat('M/d').format(recruitment.startAt);
    final weekday = DateFormat('E', 'ko').format(recruitment.startAt);
    final remaining = recruitment.totalNeeded - recruitment.currentCount;

    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: AppColors.activeBlue.withValues(alpha: 0.08),
        highlightColor: AppColors.activeBlue.withValues(alpha: 0.04),
        onTap: () => Navigator.pushNamed(
          context,
          '/recruitment-detail',
          arguments: recruitment.id,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TimeBadge(time: time, date: date),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$time–$endTime',
                      style: const TextStyle(
                        color: AppColors.subText,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      recruitment.locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.titleText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          size: 13,
                          color: AppColors.titleText,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          recruitment.gameFormatDisplay,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SegmentedProgress(
                            current: recruitment.currentCount,
                            total: recruitment.totalNeeded,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          recruitment.isFull || remaining <= 0
                              ? '마감'
                              : '${remaining.clamp(0, recruitment.totalNeeded)}명 남음',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.subText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _DateBadge(
                date: date,
                weekday: weekday,
                isOpen: recruitment.isOpen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  final String time;
  final String date;

  const _TimeBadge({required this.time, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.softSurface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.titleText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            date,
            style: const TextStyle(fontSize: 9, color: AppColors.subText),
          ),
        ],
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String date;
  final String weekday;
  final bool isOpen;

  const _DateBadge({
    required this.date,
    required this.weekday,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 64,
      decoration: BoxDecoration(
        color: isOpen ? AppColors.softPrimary : AppColors.softSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: TextStyle(
              color: isOpen ? AppColors.activeBlue : AppColors.subText,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$weekday요일',
            style: TextStyle(
              color: isOpen ? AppColors.activeBlue : AppColors.subText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedProgress extends StatelessWidget {
  final int current;
  final int total;

  const _SegmentedProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final segmentCount = total <= 0 ? 1 : (total > 10 ? 10 : total);
    final ratio = total <= 0 ? 0.0 : (current / total).clamp(0.0, 1.0);
    final activeCount = (ratio * segmentCount).round();

    return Row(
      children: List.generate(
        segmentCount,
        (index) => Expanded(
          child: Container(
            height: 7,
            margin: EdgeInsets.only(right: index == segmentCount - 1 ? 0 : 2),
            decoration: BoxDecoration(
              color: index < activeCount
                  ? AppColors.activeBlue
                  : const Color(0xFFD9DAE0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
