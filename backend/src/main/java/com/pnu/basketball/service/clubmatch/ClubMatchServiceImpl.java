package com.pnu.basketball.service.clubmatch;

import com.pnu.basketball.domain.*;
import com.pnu.basketball.dto.request.ClubMatchCreateRequest;
import com.pnu.basketball.dto.request.ClubMatchResultRequest;
import com.pnu.basketball.dto.response.ClubMatchRequestResponse;
import com.pnu.basketball.dto.response.ClubMatchResultResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClubMatchServiceImpl implements ClubMatchService {

    private static final int MIN_ATTENDANCE = 5;

    private final ClubMatchRequestRepository requestRepository;
    private final ClubMatchAttendanceRepository attendanceRepository;
    private final ClubMatchResultRepository resultRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final ClubRepository clubRepository;
    private final UserRepository userRepository;
    private final ScheduleLocationRepository locationRepository;
    private final MatchRepository matchRepository;
    private final MatchParticipationRepository matchParticipationRepository;
    private final ScheduleRepository scheduleRepository;

    @Override
    @Transactional
    public ClubMatchRequestResponse createRequest(Long userId, ClubMatchCreateRequest request) {
        ClubMember member = getClubMember(userId);
        if (member.getRole() != ClubRole.PRESIDENT) {
            throw new CustomException(ErrorCode.CLUB_MATCH_NOT_CAPTAIN);
        }

        ScheduleLocationEntity location = locationRepository.findById(request.getLocationId())
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_LOCATION_NOT_FOUND));

        ClubMatchRequest matchRequest = ClubMatchRequest.builder()
                .homeClub(member.getClub())
                .startAt(request.getStartAt())
                .endAt(request.getEndAt())
                .location(location)
                .build();
        requestRepository.save(matchRequest);

        return toResponse(matchRequest);
    }

    @Override
    @Transactional
    public void attend(UUID requestId, Long userId) {
        ClubMatchRequest request = findRequest(requestId);
        ClubMember member = getClubMember(userId);
        UUID clubId = member.getClub().getId();

        if (!request.isHomeClub(clubId) && !request.isAwayClub(clubId)) {
            throw new CustomException(ErrorCode.CLUB_MATCH_NOT_INVOLVED);
        }

        if (attendanceRepository.existsByRequestIdAndClubIdAndUserUserId(requestId, clubId, userId)) {
            throw new CustomException(ErrorCode.CLUB_MATCH_ALREADY_ATTENDED);
        }

        ClubMatchAttendance attendance = ClubMatchAttendance.builder()
                .request(request)
                .club(member.getClub())
                .user(member.getUser())
                .build();
        attendanceRepository.save(attendance);

        long homeCount = attendanceRepository.countByRequestIdAndClubId(requestId, request.getHomeClub().getId());
        if (request.getStatus() == ClubMatchStatus.GATHERING && homeCount >= MIN_ATTENDANCE) {
            request.ready();
        }

        if (request.getStatus() == ClubMatchStatus.MATCHED && request.getAwayClub() != null) {
            long awayCount = attendanceRepository.countByRequestIdAndClubId(requestId, request.getAwayClub().getId());
            if (homeCount >= MIN_ATTENDANCE && awayCount >= MIN_ATTENDANCE) {
                request.confirm();
                createMatchAndSchedule(request);
            }
        }
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ClubMatchRequestResponse> getRequests(Pageable pageable) {
        return requestRepository.findByStatusInOrderByCreatedAtDesc(
                List.of(ClubMatchStatus.GATHERING, ClubMatchStatus.READY, ClubMatchStatus.MATCHED,
                        ClubMatchStatus.CONFIRMED, ClubMatchStatus.DONE),
                pageable).map(this::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public ClubMatchRequestResponse getRequestDetail(UUID requestId) {
        return toResponse(findRequest(requestId));
    }

    @Override
    @Transactional
    public ClubMatchRequestResponse matchOpponent(UUID requestId, UUID awayClubId, Long userId) {
        ClubMatchRequest request = findRequest(requestId);

        ClubMember member = getClubMember(userId);
        if (member.getRole() != ClubRole.PRESIDENT || !request.isHomeClub(member.getClub().getId())) {
            throw new CustomException(ErrorCode.CLUB_MATCH_NOT_CAPTAIN);
        }

        if (request.getStatus() != ClubMatchStatus.READY) {
            throw new CustomException(ErrorCode.CLUB_MATCH_NOT_READY);
        }
        if (request.getHomeClub().getId().equals(awayClubId)) {
            throw new CustomException(ErrorCode.CLUB_MATCH_SAME_CLUB);
        }

        Club awayClub = clubRepository.findById(awayClubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        request.matchWith(awayClub);
        return toResponse(request);
    }

    @Override
    @Transactional
    public ClubMatchRequestResponse confirmMatch(UUID requestId, Long userId) {
        ClubMatchRequest request = findRequest(requestId);

        if (request.getStatus() != ClubMatchStatus.MATCHED) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "MATCHED 상태에서만 확정할 수 있습니다.");
        }

        long homeCount = attendanceRepository.countByRequestIdAndClubId(requestId, request.getHomeClub().getId());
        long awayCount = attendanceRepository.countByRequestIdAndClubId(requestId, request.getAwayClub().getId());
        if (homeCount < MIN_ATTENDANCE || awayCount < MIN_ATTENDANCE) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "양팀 모두 5명 이상 참가해야 확정할 수 있습니다.");
        }

        request.confirm();
        createMatchAndSchedule(request);
        return toResponse(request);
    }

    @Override
    @Transactional
    public ClubMatchResultResponse submitResult(UUID requestId, Long userId, ClubMatchResultRequest resultReq) {
        ClubMatchRequest request = findRequest(requestId);

        if (request.getStatus() != ClubMatchStatus.CONFIRMED && request.getStatus() != ClubMatchStatus.DONE) {
            throw new CustomException(ErrorCode.CLUB_MATCH_NOT_DONE);
        }

        if (resultRepository.findByRequestId(requestId).isPresent()) {
            throw new CustomException(ErrorCode.CLUB_MATCH_RESULT_EXISTS);
        }

        ClubMember member = getClubMember(userId);
        if (member.getRole() != ClubRole.PRESIDENT || !request.isHomeClub(member.getClub().getId())) {
            throw new CustomException(ErrorCode.CLUB_MATCH_NOT_CAPTAIN);
        }

        request.done();

        ClubMatchResult result = ClubMatchResult.builder()
                .request(request)
                .homeScore(resultReq.getHomeScore())
                .awayScore(resultReq.getAwayScore())
                .homeApproved(true)
                .build();
        resultRepository.save(result);

        return toResultResponse(result, request);
    }

    @Override
    @Transactional
    public ClubMatchResultResponse approveResult(UUID requestId, Long userId) {
        ClubMatchRequest request = findRequest(requestId);
        ClubMatchResult result = resultRepository.findByRequestId(requestId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MATCH_RESULT_NOT_FOUND));

        ClubMember member = getClubMember(userId);
        if (member.getRole() != ClubRole.PRESIDENT) {
            throw new CustomException(ErrorCode.CLUB_MATCH_NOT_CAPTAIN);
        }

        UUID clubId = member.getClub().getId();
        if (request.isHomeClub(clubId)) {
            result.approveHome();
        } else if (request.isAwayClub(clubId)) {
            result.approveAway();
        } else {
            throw new CustomException(ErrorCode.CLUB_MATCH_NOT_INVOLVED);
        }

        return toResultResponse(result, request);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ClubMatchResultResponse> getPendingAdminApproval() {
        return resultRepository.findPendingAdminApproval().stream()
                .map(r -> toResultResponse(r, r.getRequest()))
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ClubMatchResultResponse adminConfirm(UUID requestId) {
        ClubMatchResult result = resultRepository.findByRequestId(requestId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MATCH_RESULT_NOT_FOUND));

        if (!result.isBothApproved()) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "양팀 대표 승인이 완료되지 않았습니다.");
        }

        result.approveAdmin();

        ClubMatchRequest request = result.getRequest();
        Club homeClub = request.getHomeClub();
        Club awayClub = request.getAwayClub();

        if (result.getHomeScore() > result.getAwayScore()) {
            homeClub.incrementWins();
        } else if (result.getAwayScore() > result.getHomeScore()) {
            awayClub.incrementWins();
        }

        return toResultResponse(result, request);
    }

    private void createMatchAndSchedule(ClubMatchRequest request) {
        Match match = Match.builder()
                .sourceType(MatchSourceType.CLUB_MATCH)
                .clubMatchRequestId(request.getId())
                .location(request.getLocation())
                .startAt(request.getStartAt())
                .endAt(request.getEndAt())
                .build();
        matchRepository.save(match);

        String title = "동아리전: " + request.getHomeClub().getName()
                + " vs " + (request.getAwayClub() != null ? request.getAwayClub().getName() : "TBD");

        Schedule schedule = Schedule.builder()
                .location(request.getLocation())
                .scheduleDate(request.getStartAt().toLocalDate())
                .startTime(request.getStartAt().toLocalTime())
                .endTime(request.getEndAt().toLocalTime())
                .status(ScheduleStatus.SCHEDULED)
                .scheduleType("MATCH")
                .title(title)
                .matchId(match.getId())
                .build();
        scheduleRepository.save(schedule);

        List<ClubMatchAttendance> homeAttendances = attendanceRepository
                .findByRequestIdAndClubId(request.getId(), request.getHomeClub().getId());
        List<ClubMatchAttendance> awayAttendances = request.getAwayClub() != null
                ? attendanceRepository.findByRequestIdAndClubId(request.getId(), request.getAwayClub().getId())
                : List.of();

        for (ClubMatchAttendance att : homeAttendances) {
            matchParticipationRepository.save(MatchParticipation.builder()
                    .match(match).user(att.getUser()).status(ParticipationStatus.ATTENDED).build());
        }
        for (ClubMatchAttendance att : awayAttendances) {
            matchParticipationRepository.save(MatchParticipation.builder()
                    .match(match).user(att.getUser()).status(ParticipationStatus.ATTENDED).build());
        }
    }

    private ClubMatchRequest findRequest(UUID id) {
        return requestRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MATCH_REQUEST_NOT_FOUND));
    }

    private ClubMember getClubMember(Long userId) {
        return clubMemberRepository.findByUserUserId(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MATCH_NOT_CLUB_MEMBER));
    }

    private ClubMatchRequestResponse toResponse(ClubMatchRequest req) {
        long homeCount = attendanceRepository.countByRequestIdAndClubId(req.getId(), req.getHomeClub().getId());
        long awayCount = req.getAwayClub() != null
                ? attendanceRepository.countByRequestIdAndClubId(req.getId(), req.getAwayClub().getId()) : 0;

        return ClubMatchRequestResponse.builder()
                .id(req.getId())
                .homeClubId(req.getHomeClub().getId())
                .homeClubName(req.getHomeClub().getName())
                .awayClubId(req.getAwayClub() != null ? req.getAwayClub().getId() : null)
                .awayClubName(req.getAwayClub() != null ? req.getAwayClub().getName() : null)
                .startAt(req.getStartAt())
                .endAt(req.getEndAt())
                .locationName(req.getLocation().getName())
                .status(req.getStatus())
                .homeAttendanceCount(homeCount)
                .awayAttendanceCount(awayCount)
                .createdAt(req.getCreatedAt())
                .build();
    }

    private ClubMatchResultResponse toResultResponse(ClubMatchResult result, ClubMatchRequest request) {
        return ClubMatchResultResponse.builder()
                .id(result.getId())
                .requestId(request.getId())
                .homeClubName(request.getHomeClub().getName())
                .awayClubName(request.getAwayClub() != null ? request.getAwayClub().getName() : null)
                .homeScore(result.getHomeScore())
                .awayScore(result.getAwayScore())
                .homeApproved(result.getHomeApproved())
                .awayApproved(result.getAwayApproved())
                .adminApproved(result.getAdminApproved())
                .build();
    }
}
