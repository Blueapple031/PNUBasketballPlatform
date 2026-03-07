package com.pnu.basketball.service.admin;

import com.pnu.basketball.domain.*;
import com.pnu.basketball.dto.request.AdminCreateClubRequest;
import com.pnu.basketball.dto.request.AdminSetCaptainRequest;
import com.pnu.basketball.dto.request.AdminUpdateMatchRequest;
import com.pnu.basketball.dto.response.*;
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
public class AdminServiceImpl implements AdminService {

    private final UserRepository userRepository;
    private final ClubRepository clubRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final MatchRepository matchRepository;

    @Override
    @Transactional(readOnly = true)
    public AdminStatsResponse getStats() {
        long userCount = userRepository.count();
        long clubCount = clubRepository.count();
        long matchCount = matchRepository.count();
        return AdminStatsResponse.builder()
                .userCount(userCount)
                .clubCount(clubCount)
                .matchCount(matchCount)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AdminUserListResponse> getUsers(Boolean isPnuStudent, String search, Pageable pageable) {
        String searchTrimmed = (search != null && !search.trim().isEmpty()) ? search.trim() : null;
        return userRepository.findAllForAdmin(isPnuStudent, searchTrimmed, pageable)
                .map(this::toAdminUserListResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public AdminUserDetailResponse getUserDetail(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        String clubName = clubMemberRepository.findByUserUserId(userId)
                .map(cm -> cm.getClub().getName())
                .orElse(null);
        return AdminUserDetailResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .realName(user.getRealName())
                .phoneNumber(user.getPhoneNumber())
                .dateOfBirth(user.getDateOfBirth())
                .isPnuStudent(user.getIsPnuStudent())
                .department(user.getDepartment())
                .studentId(user.getStudentId())
                .clubName(clubName)
                .wins(user.getWins())
                .games(user.getGames())
                .totalScore(user.getTotalScore())
                .createdAt(user.getCreatedAt())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AdminClubListResponse> getClubs(Pageable pageable) {
        return clubRepository.findAll(pageable)
                .map(this::toAdminClubListResponse);
    }

    @Override
    @Transactional
    public AdminClubListResponse createClub(AdminCreateClubRequest request) {
        Club club = Club.builder()
                .name(request.getName())
                .logoUrl(request.getLogoUrl())
                .introduction(request.getIntroduction())
                .build();
        club = clubRepository.save(club);
        return toAdminClubListResponse(club);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AdminUserListResponse> getClubMembers(UUID clubId) {
        return clubMemberRepository.findByClub_Id(clubId).stream()
                .map(cm -> toAdminUserListResponse(cm.getUser()))
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void setCaptain(UUID clubId, AdminSetCaptainRequest request) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));
        User newCaptain = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        ClubMember newCaptainMember = clubMemberRepository.findByClub_Id(clubId).stream()
                .filter(cm -> cm.getUser().getUserId().equals(request.getUserId()))
                .findFirst()
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT, "해당 동아리 멤버가 아닙니다."));

        clubMemberRepository.findByClub_Id(clubId).forEach(cm -> {
            if (cm.getRole() == ClubRole.PRESIDENT) {
                cm.setRole(ClubRole.MEMBER);
                clubMemberRepository.save(cm);
            }
        });

        newCaptainMember.setRole(ClubRole.PRESIDENT);
        clubMemberRepository.save(newCaptainMember);

        club.setCaptain(newCaptain);
        clubRepository.save(club);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AdminMatchListResponse> getMatches(MatchState state, Pageable pageable) {
        Page<Match> matches = state != null
                ? matchRepository.findByStateOrderByScheduledAtDesc(state, pageable)
                : matchRepository.findAllByOrderByScheduledAtDesc(pageable);
        return matches.map(this::toAdminMatchListResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public AdminMatchListResponse getMatchDetail(UUID matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT, "매치를 찾을 수 없습니다."));
        return toAdminMatchListResponse(match);
    }

    @Override
    @Transactional
    public AdminMatchListResponse updateMatch(UUID matchId, AdminUpdateMatchRequest request) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT, "매치를 찾을 수 없습니다."));
        if (request.getState() != null) {
            match.updateState(request.getState());
        }
        if (request.getHomeScore() != null || request.getAwayScore() != null) {
            match.updateScore(
                    request.getHomeScore() != null ? request.getHomeScore() : match.getHomeScore(),
                    request.getAwayScore() != null ? request.getAwayScore() : match.getAwayScore()
            );
        }
        match = matchRepository.save(match);
        return toAdminMatchListResponse(match);
    }

    private AdminUserListResponse toAdminUserListResponse(User user) {
        String clubName = clubMemberRepository.findByUserUserId(user.getUserId())
                .map(cm -> cm.getClub().getName())
                .orElse(null);
        return AdminUserListResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .realName(user.getRealName())
                .isPnuStudent(user.getIsPnuStudent())
                .department(user.getDepartment())
                .studentId(user.getStudentId())
                .clubName(clubName)
                .createdAt(user.getCreatedAt())
                .build();
    }

    private AdminClubListResponse toAdminClubListResponse(Club club) {
        String captainName = club.getCaptain() != null ? club.getCaptain().getRealName() : null;
        Long captainId = club.getCaptain() != null ? club.getCaptain().getUserId() : null;
        long memberCount = clubMemberRepository.countByClub_Id(club.getId());
        return AdminClubListResponse.builder()
                .clubId(club.getId())
                .name(club.getName())
                .logoUrl(club.getLogoUrl())
                .introduction(club.getIntroduction())
                .captainName(captainName)
                .captainId(captainId)
                .memberCount(memberCount)
                .build();
    }

    private AdminMatchListResponse toAdminMatchListResponse(Match match) {
        String homeName = match.getHomeClub() != null ? match.getHomeClub().getName() : "-";
        String awayName = match.getAwayClub() != null ? match.getAwayClub().getName() : "-";
        return AdminMatchListResponse.builder()
                .matchId(match.getId())
                .homeClubName(homeName)
                .awayClubName(awayName)
                .scheduledAt(match.getScheduledAt())
                .state(match.getState())
                .homeScore(match.getHomeScore())
                .awayScore(match.getAwayScore())
                .build();
    }
}
