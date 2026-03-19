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
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stadium_outlined, size: 64, color: AppColors.border),
                const SizedBox(height: 16),
                Text(
                  '아직 친선전 요청이 없어요',
                  style: TextStyle(fontSize: 16, color: AppColors.subText),
                ),
                const SizedBox(height: 8),
                Text(
                  '동아리 대표가 친선전을 신청할 수 있습니다',
                  style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadRequests,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.requests.length,
            itemBuilder: (context, index) {
              return _ClubMatchCard(request: provider.requests[index]);
            },
          ),
        );
      },
    );
  }
}

class _ClubMatchCard extends StatelessWidget {
  final ClubMatchRequestModel request;

  const _ClubMatchCard({required this.request});

  Color _statusColor() {
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
            '/club-match-detail',
            arguments: request.id,
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
                      color: _statusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      request.statusDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _statusColor(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.activeBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '5:5',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.activeBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          request.homeClubName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${request.homeAttendanceCount}명',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.subText),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.activeBlue,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          request.hasAway ? request.awayClubName! : '???',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: request.hasAway
                                ? AppColors.titleText
                                : AppColors.textDisabled,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (request.hasAway)
                          Text(
                            '${request.awayAttendanceCount}명',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.subText),
                          )
                        else
                          const Text(
                            '상대 모집중',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textDisabled),
                          ),
                      ],
                    ),
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
                    request.locationName,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time,
                      size: 16, color: AppColors.subText),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(request.startAt),
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
