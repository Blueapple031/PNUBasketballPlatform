import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/club_match_model.dart';
import '../../providers/club_match_provider.dart';

class ClubMatchListView extends StatefulWidget {
  const ClubMatchListView({super.key});

  @override
  State<ClubMatchListView> createState() => _ClubMatchListViewState();
}

class _ClubMatchListViewState extends State<ClubMatchListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClubMatchProvider>().loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClubMatchProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.requests.isEmpty) {
          return const ColoredBox(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.activeBlue),
            ),
          );
        }

        return ColoredBox(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  children: [
                    Text(
                      '총 ${provider.requests.length}개의 친선전',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.titleText,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '동아리 대표만 개설할 수 있어요',
                      style: TextStyle(fontSize: 10, color: AppColors.subText),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: provider.requests.isEmpty
                    ? const _EmptyClubMatches()
                    : RefreshIndicator(
                        color: AppColors.activeBlue,
                        onRefresh: provider.loadRequests,
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 96),
                          itemCount: provider.requests.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 84),
                          itemBuilder: (context, index) => _ClubMatchRow(
                            request: provider.requests[index],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyClubMatches extends StatelessWidget {
  const _EmptyClubMatches();

  @override
  Widget build(BuildContext context) {
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
                Icons.stadium_outlined,
                size: 32,
                color: AppColors.activeBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '예정된 친선전이 없어요',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              '상대 동아리를 찾아 새로운 경기를 열어보세요.',
              style: TextStyle(fontSize: 12, color: AppColors.subText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubMatchRow extends StatelessWidget {
  final ClubMatchRequestModel request;

  const _ClubMatchRow({required this.request});

  Color get _statusColor {
    switch (request.status) {
      case 'GATHERING':
      case 'READY':
        return AppColors.alertOrange;
      case 'MATCHED':
      case 'CONFIRMED':
        return AppColors.classTeal;
      case 'DONE':
        return AppColors.activeBlue;
      case 'CANCELLED':
        return AppColors.errorRed;
      default:
        return AppColors.subText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('M/d').format(request.startAt);
    final weekday = DateFormat('E', 'ko').format(request.startAt);
    final startTime = DateFormat('HH:mm').format(request.startAt);
    final endTime = DateFormat('HH:mm').format(request.endAt);

    return Material(
      color: Colors.white,
      child: InkWell(
        splashColor: AppColors.activeBlue.withValues(alpha: 0.08),
        highlightColor: AppColors.activeBlue.withValues(alpha: 0.04),
        onTap: () => Navigator.pushNamed(
          context,
          '/club-match-detail',
          arguments: request.id,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.softPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.activeBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$weekday요일',
                      style: const TextStyle(
                        color: AppColors.activeBlue,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.homeClubName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7),
                          child: Text(
                            'VS',
                            style: TextStyle(
                              color: AppColors.activeBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            request.hasAway ? request.awayClubName! : '상대 모집중',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: request.hasAway
                                  ? AppColors.titleText
                                  : AppColors.subText,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      request.locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$startTime–$endTime · 홈 ${request.homeAttendanceCount}명'
                      '${request.hasAway ? ' · 원정 ${request.awayAttendanceCount}명' : ''}',
                      style: const TextStyle(
                        color: AppColors.subText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  request.statusDisplay,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
