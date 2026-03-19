import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/recruitment_model.dart';
import '../../providers/recruitment_provider.dart';
import 'widgets/progress_bar_widget.dart';

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
        return Column(
          children: [
            _buildFilterChips(provider),
            Expanded(
              child: provider.isLoading && provider.recruitments.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.recruitments.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: provider.loadRecruitments,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.recruitments.length,
                            itemBuilder: (context, index) {
                              return _RecruitmentCard(
                                recruitment: provider.recruitments[index],
                              );
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips(RecruitmentProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _FilterChipItem(
              label: '전체',
              isActive: provider.filterGameFormat == null,
              onTap: () => provider.setFilter(
                gameFormat: null,
                status: provider.filterStatus,
              ),
            ),
            const SizedBox(width: 8),
            _FilterChipItem(
              label: '3:3',
              isActive: provider.filterGameFormat == 'THREE_VS_THREE',
              onTap: () => provider.setFilter(
                gameFormat: 'THREE_VS_THREE',
                status: provider.filterStatus,
              ),
            ),
            const SizedBox(width: 8),
            _FilterChipItem(
              label: '4:4',
              isActive: provider.filterGameFormat == 'FOUR_VS_FOUR',
              onTap: () => provider.setFilter(
                gameFormat: 'FOUR_VS_FOUR',
                status: provider.filterStatus,
              ),
            ),
            const SizedBox(width: 8),
            _FilterChipItem(
              label: '5:5',
              isActive: provider.filterGameFormat == 'FIVE_VS_FIVE',
              onTap: () => provider.setFilter(
                gameFormat: 'FIVE_VS_FIVE',
                status: provider.filterStatus,
              ),
            ),
            const SizedBox(width: 8),
            _FilterChipItem(
              label: '자유',
              isActive: provider.filterGameFormat == 'FLEXIBLE',
              onTap: () => provider.setFilter(
                gameFormat: 'FLEXIBLE',
                status: provider.filterStatus,
              ),
            ),
            const SizedBox(width: 16),
            _FilterChipItem(
              label: '모집중만',
              icon: Icons.circle,
              isActive: provider.filterStatus == 'OPEN',
              onTap: () => provider.setFilter(
                status: provider.filterStatus == 'OPEN' ? null : 'OPEN',
                gameFormat: provider.filterGameFormat,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_basketball_outlined,
              size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            '아직 모집글이 없어요',
            style: TextStyle(fontSize: 16, color: AppColors.subText),
          ),
          const SizedBox(height: 8),
          Text(
            'FAB 버튼을 눌러 모집을 시작해보세요!',
            style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10,
                color: isActive ? Colors.white : AppColors.classTeal),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isActive,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: AppColors.activeBlue,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : AppColors.titleText,
        fontSize: 12,
      ),
      side: BorderSide(color: isActive ? AppColors.activeBlue : AppColors.border),
    );
  }
}

class _RecruitmentCard extends StatelessWidget {
  final RecruitmentListModel recruitment;

  const _RecruitmentCard({required this.recruitment});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M/d(E) HH:mm', 'ko');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/recruitment-detail',
            arguments: recruitment.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.activeBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recruitment.gameFormatDisplay,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.activeBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: recruitment.isOpen
                          ? AppColors.classTeal.withValues(alpha: 0.1)
                          : AppColors.subText.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recruitment.statusDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: recruitment.isOpen
                            ? AppColors.classTeal
                            : AppColors.subText,
                      ),
                    ),
                  ),
                  if (recruitment.isFull) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.alertOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'FULL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.alertOrange,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    recruitment.authorNickname,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.subText),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.subText),
                  const SizedBox(width: 4),
                  Text(
                    recruitment.locationName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 16, color: AppColors.subText),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(recruitment.startAt)} ~ ${DateFormat('HH:mm').format(recruitment.endAt)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProgressBarWidget(
                currentCount: recruitment.currentCount,
                totalNeeded: recruitment.totalNeeded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
