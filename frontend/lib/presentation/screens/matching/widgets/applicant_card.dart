import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/recruitment_model.dart';

class ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool showActions;

  const ApplicantCard({
    super.key,
    required this.application,
    this.onAccept,
    this.onReject,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.activeBlue.withValues(alpha: 0.15),
                  child: Text(
                    application.applicantNickname.isNotEmpty
                        ? application.applicantNickname[0]
                        : '?',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.activeBlue),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.applicantNickname,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _tag(application.positionDisplay),
                          const SizedBox(width: 6),
                          _tag('EXP ${application.applicantExp}'),
                          if (application.applicantNoShowCount > 0) ...[
                            const SizedBox(width: 6),
                            _tag(
                              '노쇼 ${application.applicantNoShowCount}',
                              color: AppColors.errorRed,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (application.isAccepted)
                  const Icon(Icons.check_circle, color: AppColors.classTeal, size: 22),
                if (application.isRejected)
                  const Icon(Icons.cancel, color: AppColors.errorRed, size: 22),
              ],
            ),
            if (application.message != null &&
                application.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  application.message!,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ],
            if (showActions && application.isPending) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                    ),
                    child: const Text('거절', style: TextStyle(fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.classTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                    ),
                    child: const Text('수락', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, {Color? color}) {
    final c = color ?? AppColors.subText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w500),
      ),
    );
  }
}
