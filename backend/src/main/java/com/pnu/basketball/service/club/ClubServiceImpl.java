package com.pnu.basketball.service.club;

import com.pnu.basketball.domain.Club;
import com.pnu.basketball.domain.ClubMember;
import com.pnu.basketball.domain.ClubRole;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.ClubSelectRequest;
import com.pnu.basketball.dto.response.ClubListResponse;
import com.pnu.basketball.dto.response.ClubSelectResponse;
import com.pnu.basketball.dto.response.ClubSelectionStatusResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.ClubMemberRepository;
import com.pnu.basketball.repository.ClubRepository;
import com.pnu.basketball.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClubServiceImpl implements ClubService {

    private final ClubRepository clubRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ClubListResponse> getClubs() {
        return clubRepository.findAll().stream()
                .map(club -> toClubListResponse(club))
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ClubSelectResponse selectClub(Long userId, ClubSelectRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (!Boolean.TRUE.equals(user.getIsPnuStudent())) {
            throw new CustomException(ErrorCode.NOT_PNU_STUDENT);
        }

        if (clubMemberRepository.existsByUserUserId(userId)) {
            throw new CustomException(ErrorCode.ALREADY_IN_CLUB);
        }

        Club club = clubRepository.findById(request.getClubId())
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        ClubRole role = request.getRole();
        if (role == null) {
            role = ClubRole.MEMBER;
        }
        if (role == ClubRole.PRESIDENT) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "동아리장은 백오피스에서 지정됩니다.");
        }

        ClubMember member = ClubMember.builder()
                .user(user)
                .club(club)
                .role(role)
                .build();
        clubMemberRepository.save(member);

        return ClubSelectResponse.builder()
                .clubId(club.getId())
                .clubName(club.getName())
                .role(role)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public ClubSelectionStatusResponse getClubSelectionStatus(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        boolean hasClub = clubMemberRepository.existsByUserUserId(userId);
        boolean needsClubSelection = Boolean.TRUE.equals(user.getIsPnuStudent()) && !hasClub;

        ClubSelectionStatusResponse.ClubSummary currentClub = null;
        if (hasClub) {
            ClubMember member = clubMemberRepository.findByUserUserId(userId).orElseThrow();
            currentClub = ClubSelectionStatusResponse.ClubSummary.builder()
                    .clubId(member.getClub().getId())
                    .name(member.getClub().getName())
                    .build();
        }

        return ClubSelectionStatusResponse.builder()
                .needsClubSelection(needsClubSelection)
                .isPnuStudent(user.getIsPnuStudent())
                .currentClub(currentClub)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public ClubListResponse getMyClub(Long userId) {
        ClubMember member = clubMemberRepository.findByUserUserId(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));
        Club club = member.getClub();
        return toClubListResponse(club);
    }

    private ClubListResponse toClubListResponse(Club club) {
        String captainName = null;
        String captainProfileImageUrl = null;
        if (club.getCaptain() != null) {
            captainName = club.getCaptain().getRealName();
            captainProfileImageUrl = club.getCaptain().getProfileImageUrl();
        }
        return ClubListResponse.builder()
                .clubId(club.getId())
                .name(club.getName())
                .logoUrl(club.getLogoUrl())
                .introduction(club.getIntroduction())
                .memberCount(clubMemberRepository.countByClub_Id(club.getId()))
                .captainName(captainName)
                .captainProfileImageUrl(captainProfileImageUrl)
                .build();
    }
}
