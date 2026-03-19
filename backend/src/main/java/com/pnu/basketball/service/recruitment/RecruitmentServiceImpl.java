package com.pnu.basketball.service.recruitment;

import com.pnu.basketball.domain.*;
import com.pnu.basketball.dto.request.RecruitmentApplyRequest;
import com.pnu.basketball.dto.request.RecruitmentCreateRequest;
import com.pnu.basketball.dto.response.ApplicationResponse;
import com.pnu.basketball.dto.response.RecruitmentDetailResponse;
import com.pnu.basketball.dto.response.RecruitmentListResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecruitmentServiceImpl implements RecruitmentService {

    private final RecruitmentPostRepository recruitmentPostRepository;
    private final RecruitmentApplicationRepository applicationRepository;
    private final UserRepository userRepository;
    private final ScheduleLocationRepository locationRepository;
    private final MatchRepository matchRepository;
    private final MatchParticipationRepository matchParticipationRepository;
    private final ScheduleRepository scheduleRepository;

    @Override
    @Transactional
    public RecruitmentDetailResponse create(Long userId, RecruitmentCreateRequest request) {
        User author = findUser(userId);

        if (!request.getStartAt().isBefore(request.getEndAt())) {
            throw new CustomException(ErrorCode.RECRUITMENT_INVALID_TIME);
        }
        if (request.getStartAt().isBefore(LocalDateTime.now())) {
            throw new CustomException(ErrorCode.RECRUITMENT_PAST_TIME);
        }

        ScheduleLocationEntity location = locationRepository.findById(request.getLocationId())
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_LOCATION_NOT_FOUND));

        RecruitmentPost post = RecruitmentPost.builder()
                .author(author)
                .startAt(request.getStartAt())
                .endAt(request.getEndAt())
                .location(location)
                .baseMembersCount(request.getBaseMembersCount())
                .neededMembers(request.getNeededMembers())
                .gameFormat(request.getGameFormat())
                .deadlineAt(request.getDeadlineAt())
                .build();
        recruitmentPostRepository.save(post);

        return toDetailResponse(post, 0L, List.of());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<RecruitmentListResponse> getList(RecruitmentStatus status, UUID locationId,
                                                  RecruitmentGameFormat gameFormat,
                                                  LocalDateTime startFrom, LocalDateTime startTo,
                                                  Pageable pageable) {
        var spec = RecruitmentSpecification.withFilters(status, locationId, gameFormat, startFrom, startTo);
        return recruitmentPostRepository.findAll(spec, pageable)
                .map(post -> {
                    long acceptedCount = applicationRepository.countByRecruitmentIdAndStatus(
                            post.getId(), ApplicationStatus.ACCEPTED);
                    return toListResponse(post, acceptedCount);
                });
    }

    @Override
    @Transactional(readOnly = true)
    public RecruitmentDetailResponse getDetail(UUID recruitmentId, Long currentUserId) {
        RecruitmentPost post = findPost(recruitmentId);
        long acceptedCount = applicationRepository.countByRecruitmentIdAndStatus(
                recruitmentId, ApplicationStatus.ACCEPTED);
        List<RecruitmentApplication> applications = applicationRepository.findByRecruitmentId(recruitmentId);

        return toDetailResponse(post, acceptedCount, applications.stream()
                .map(this::toApplicationResponse)
                .collect(Collectors.toList()));
    }

    @Override
    @Transactional
    public void apply(UUID recruitmentId, Long userId, RecruitmentApplyRequest request) {
        RecruitmentPost post = findPost(recruitmentId);
        User applicant = findUser(userId);

        if (post.getStatus() != RecruitmentStatus.OPEN) {
            throw new CustomException(ErrorCode.RECRUITMENT_NOT_OPEN);
        }
        if (post.isAuthor(userId)) {
            throw new CustomException(ErrorCode.RECRUITMENT_SELF_APPLY);
        }
        if (applicationRepository.existsByRecruitmentIdAndApplicantUserId(recruitmentId, userId)) {
            throw new CustomException(ErrorCode.RECRUITMENT_ALREADY_APPLIED);
        }

        RecruitmentApplication application = RecruitmentApplication.builder()
                .recruitment(post)
                .applicant(applicant)
                .message(request.getMessage())
                .build();
        applicationRepository.save(application);
    }

    @Override
    @Transactional
    public void acceptApplication(UUID recruitmentId, UUID applicationId, Long userId) {
        RecruitmentPost post = findPost(recruitmentId);
        validateAuthor(post, userId);

        RecruitmentApplication application = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new CustomException(ErrorCode.APPLICATION_NOT_FOUND));
        if (application.getStatus() != ApplicationStatus.PENDING) {
            throw new CustomException(ErrorCode.APPLICATION_NOT_PENDING);
        }

        application.accept();
    }

    @Override
    @Transactional
    public void rejectApplication(UUID recruitmentId, UUID applicationId, Long userId) {
        RecruitmentPost post = findPost(recruitmentId);
        validateAuthor(post, userId);

        RecruitmentApplication application = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new CustomException(ErrorCode.APPLICATION_NOT_FOUND));
        if (application.getStatus() != ApplicationStatus.PENDING) {
            throw new CustomException(ErrorCode.APPLICATION_NOT_PENDING);
        }

        application.reject();
    }

    @Override
    @Transactional
    public RecruitmentDetailResponse confirm(UUID recruitmentId, Long userId) {
        RecruitmentPost post = findPost(recruitmentId);
        validateAuthor(post, userId);

        if (post.getStatus() != RecruitmentStatus.OPEN) {
            throw new CustomException(ErrorCode.RECRUITMENT_NOT_OPEN);
        }
        if (matchRepository.findByRecruitmentId(recruitmentId).isPresent()) {
            throw new CustomException(ErrorCode.MATCH_ALREADY_EXISTS);
        }

        post.confirm();

        Match match = Match.builder()
                .sourceType(MatchSourceType.RECRUITMENT)
                .recruitmentId(recruitmentId)
                .location(post.getLocation())
                .startAt(post.getStartAt())
                .endAt(post.getEndAt())
                .gameFormat(post.getGameFormat())
                .build();
        matchRepository.save(match);

        Schedule schedule = Schedule.builder()
                .location(post.getLocation())
                .scheduleDate(post.getStartAt().toLocalDate())
                .startTime(post.getStartAt().toLocalTime())
                .endTime(post.getEndAt().toLocalTime())
                .status(ScheduleStatus.SCHEDULED)
                .scheduleType("MATCH")
                .title("게스트 모집 경기")
                .matchId(match.getId())
                .build();
        scheduleRepository.save(schedule);

        List<RecruitmentApplication> accepted = applicationRepository
                .findByRecruitmentIdAndStatus(recruitmentId, ApplicationStatus.ACCEPTED);

        MatchParticipation authorParticipation = MatchParticipation.builder()
                .match(match)
                .user(post.getAuthor())
                .status(ParticipationStatus.ATTENDED)
                .build();
        matchParticipationRepository.save(authorParticipation);

        for (RecruitmentApplication app : accepted) {
            MatchParticipation participation = MatchParticipation.builder()
                    .match(match)
                    .user(app.getApplicant())
                    .status(ParticipationStatus.ATTENDED)
                    .build();
            matchParticipationRepository.save(participation);
        }

        long acceptedCount = accepted.size();
        List<RecruitmentApplication> allApps = applicationRepository.findByRecruitmentId(recruitmentId);

        return toDetailResponse(post, acceptedCount, allApps.stream()
                .map(this::toApplicationResponse)
                .collect(Collectors.toList()));
    }

    @Override
    @Transactional
    public void cancel(UUID recruitmentId, Long userId) {
        RecruitmentPost post = findPost(recruitmentId);
        validateAuthor(post, userId);
        post.cancel();
    }

    private User findUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
    }

    private RecruitmentPost findPost(UUID id) {
        return recruitmentPostRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.RECRUITMENT_NOT_FOUND));
    }

    private void validateAuthor(RecruitmentPost post, Long userId) {
        if (!post.isAuthor(userId)) {
            throw new CustomException(ErrorCode.RECRUITMENT_NOT_AUTHOR);
        }
    }

    private RecruitmentListResponse toListResponse(RecruitmentPost post, long acceptedCount) {
        return RecruitmentListResponse.builder()
                .id(post.getId())
                .authorNickname(post.getAuthor().getNickname())
                .startAt(post.getStartAt())
                .endAt(post.getEndAt())
                .locationName(post.getLocation().getName())
                .baseMembersCount(post.getBaseMembersCount())
                .neededMembers(post.getNeededMembers())
                .acceptedCount(acceptedCount)
                .gameFormat(post.getGameFormat())
                .status(post.getStatus())
                .deadlineAt(post.getDeadlineAt())
                .createdAt(post.getCreatedAt())
                .isFull(acceptedCount >= post.getNeededMembers())
                .build();
    }

    private RecruitmentDetailResponse toDetailResponse(RecruitmentPost post, long acceptedCount,
                                                        List<ApplicationResponse> applications) {
        return RecruitmentDetailResponse.builder()
                .id(post.getId())
                .authorId(post.getAuthor().getUserId())
                .authorNickname(post.getAuthor().getNickname())
                .startAt(post.getStartAt())
                .endAt(post.getEndAt())
                .locationId(post.getLocation().getId())
                .locationName(post.getLocation().getName())
                .baseMembersCount(post.getBaseMembersCount())
                .neededMembers(post.getNeededMembers())
                .acceptedCount(acceptedCount)
                .gameFormat(post.getGameFormat())
                .status(post.getStatus())
                .deadlineAt(post.getDeadlineAt())
                .createdAt(post.getCreatedAt())
                .isFull(acceptedCount >= post.getNeededMembers())
                .applications(applications)
                .build();
    }

    private ApplicationResponse toApplicationResponse(RecruitmentApplication app) {
        User applicant = app.getApplicant();
        return ApplicationResponse.builder()
                .applicationId(app.getId())
                .applicantId(applicant.getUserId())
                .applicantNickname(applicant.getNickname())
                .applicantPosition(applicant.getPosition())
                .applicantExp(applicant.getExp())
                .applicantNoShowCount(applicant.getNoShowCount())
                .applicantParticipationCount(applicant.getParticipationCount())
                .status(app.getStatus())
                .message(app.getMessage())
                .createdAt(app.getCreatedAt())
                .build();
    }
}
