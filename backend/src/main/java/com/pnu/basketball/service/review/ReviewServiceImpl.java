package com.pnu.basketball.service.review;

import com.pnu.basketball.domain.*;
import com.pnu.basketball.dto.request.ReviewSubmitRequest;
import com.pnu.basketball.dto.response.NoShowReportResponse;
import com.pnu.basketball.dto.response.ReviewFormResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReviewServiceImpl implements ReviewService {

    private static final int REVIEW_DEADLINE_HOURS = 24;

    private final MatchRepository matchRepository;
    private final MatchParticipationRepository participationRepository;
    private final ParticipationReviewRepository reviewRepository;
    private final NoShowReportRepository noShowReportRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public ReviewFormResponse getReviewForm(UUID matchId, Long userId) {
        Match match = findMatch(matchId);
        validateParticipant(matchId, userId);

        boolean alreadySubmitted = !reviewRepository.findByMatchId(matchId).stream()
                .filter(r -> r.getReviewer().getUserId().equals(userId))
                .toList().isEmpty();

        List<MatchParticipation> participations = participationRepository.findByMatchId(matchId);
        List<ReviewFormResponse.ParticipantInfo> participants = participations.stream()
                .filter(p -> !p.getUser().getUserId().equals(userId))
                .map(p -> ReviewFormResponse.ParticipantInfo.builder()
                        .userId(p.getUser().getUserId())
                        .nickname(p.getUser().getNickname())
                        .position(p.getUser().getPosition())
                        .exp(p.getUser().getExp())
                        .build())
                .collect(Collectors.toList());

        return ReviewFormResponse.builder()
                .matchId(matchId)
                .startAt(match.getStartAt())
                .endAt(match.getEndAt())
                .locationName(match.getLocation().getName())
                .alreadySubmitted(alreadySubmitted)
                .participants(participants)
                .build();
    }

    @Override
    @Transactional
    public void submitReview(UUID matchId, Long userId, ReviewSubmitRequest request) {
        Match match = findMatch(matchId);
        validateParticipant(matchId, userId);

        if (match.getEndAt().plusHours(REVIEW_DEADLINE_HOURS).isBefore(LocalDateTime.now())) {
            throw new CustomException(ErrorCode.REVIEW_PERIOD_EXPIRED);
        }

        User reviewer = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (request.getThumbsUpUserIds() != null) {
            for (Long revieweeId : request.getThumbsUpUserIds()) {
                if (revieweeId.equals(userId)) continue;
                if (reviewRepository.existsByMatchIdAndReviewerUserIdAndRevieweeUserId(matchId, userId, revieweeId)) {
                    continue;
                }
                User reviewee = userRepository.findById(revieweeId)
                        .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
                reviewRepository.save(ParticipationReview.builder()
                        .match(match)
                        .reviewer(reviewer)
                        .reviewee(reviewee)
                        .build());
            }
        }

        if (request.getNoShowUserIds() != null) {
            for (Long reportedId : request.getNoShowUserIds()) {
                if (reportedId.equals(userId)) continue;
                if (noShowReportRepository.existsByMatchIdAndReporterUserIdAndReportedUserUserId(matchId, userId, reportedId)) {
                    continue;
                }
                User reportedUser = userRepository.findById(reportedId)
                        .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
                noShowReportRepository.save(NoShowReport.builder()
                        .match(match)
                        .reporter(reviewer)
                        .reportedUser(reportedUser)
                        .build());
            }
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<NoShowReportResponse> getPendingNoShowReports() {
        return noShowReportRepository.findByStatus(NoShowReportStatus.PENDING).stream()
                .map(this::toNoShowResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void confirmNoShow(UUID reportId) {
        NoShowReport report = noShowReportRepository.findById(reportId)
                .orElseThrow(() -> new CustomException(ErrorCode.NO_SHOW_REPORT_NOT_FOUND));
        report.confirm();
        report.getReportedUser().incrementNoShowCount();
    }

    @Override
    @Transactional
    public void rejectNoShow(UUID reportId) {
        NoShowReport report = noShowReportRepository.findById(reportId)
                .orElseThrow(() -> new CustomException(ErrorCode.NO_SHOW_REPORT_NOT_FOUND));
        report.reject();
    }

    private Match findMatch(UUID matchId) {
        return matchRepository.findById(matchId)
                .orElseThrow(() -> new CustomException(ErrorCode.MATCH_NOT_FOUND));
    }

    private void validateParticipant(UUID matchId, Long userId) {
        if (!participationRepository.existsByMatchIdAndUserUserId(matchId, userId)) {
            throw new CustomException(ErrorCode.REVIEW_NOT_PARTICIPANT);
        }
    }

    private NoShowReportResponse toNoShowResponse(NoShowReport report) {
        return NoShowReportResponse.builder()
                .id(report.getId())
                .matchId(report.getMatch().getId())
                .reporterNickname(report.getReporter().getNickname())
                .reportedUserId(report.getReportedUser().getUserId())
                .reportedUserNickname(report.getReportedUser().getNickname())
                .status(report.getStatus())
                .createdAt(report.getCreatedAt())
                .build();
    }
}
