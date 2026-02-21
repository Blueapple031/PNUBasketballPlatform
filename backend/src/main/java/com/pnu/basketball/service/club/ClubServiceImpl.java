package com.pnu.basketball.service.club;

import com.pnu.basketball.domain.Club;
import com.pnu.basketball.domain.ClubMember;
import com.pnu.basketball.domain.ClubMemberRole;
import com.pnu.basketball.domain.ClubMemberStatus;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.club.ClubUpdateRequest;
import com.pnu.basketball.dto.request.club.TransferCaptainRequest;
import com.pnu.basketball.dto.response.club.ApplicationResponse;
import com.pnu.basketball.dto.response.club.ClubResponse;
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
    private final UserRepository userRepository;
    private final ClubMemberRepository clubMemberRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ClubResponse> searchClubs(String keyword) {
        return clubRepository.findByNameContaining(keyword).stream()
                .map(ClubResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ClubResponse updateClub(Long clubId, ClubUpdateRequest request, Long currentUserId) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        // 주장 권한 확인
        if (!club.getCaptain().getUserId().equals(currentUserId)) {
            throw new CustomException(ErrorCode.NOT_CLUB_CAPTAIN);
        }

        // 동아리 정보 수정
        if (request.getName() != null) {
            club.setName(request.getName());
        }
        if (request.getLogoUrl() != null) {
            club.setLogoUrl(request.getLogoUrl());
        }
        if (request.getDescription() != null) {
            club.setDescription(request.getDescription());
        }

        return ClubResponse.fromEntity(clubRepository.save(club));
    }

    @Override
    @Transactional(readOnly = true)
    public List<ClubResponse> getAllClubs() {
        return clubRepository.findAll().stream()
                .map(ClubResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void approveJoinRequest(Long clubId, Long userId, Long currentUserId) {
        updateApplicationStatus(clubId, userId, currentUserId, ClubMemberStatus.APPROVED);
    }

    @Override
    @Transactional
    public void rejectJoinRequest(Long clubId, Long userId, Long currentUserId) {
        updateApplicationStatus(clubId, userId, currentUserId, ClubMemberStatus.REJECTED);
    }

    private void updateApplicationStatus(Long clubId, Long userId, Long currentUserId, ClubMemberStatus status) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        if (!club.getCaptain().getUserId().equals(currentUserId)) {
            throw new CustomException(ErrorCode.NOT_CLUB_CAPTAIN);
        }

        User applicant = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        ClubMember clubMember = clubMemberRepository.findByClubAndUser(club, applicant)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MEMBER_NOT_FOUND));

        clubMember.setStatus(status);
        if (status == ClubMemberStatus.APPROVED) {
            clubMember.setRole(ClubMemberRole.MEMBER);
        }
        clubMemberRepository.save(clubMember);
    }

    @Override
    @Transactional
    public void transferCaptain(Long clubId, TransferCaptainRequest request, Long currentUserId) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        // 현재 주장 권한 확인
        if (!club.getCaptain().getUserId().equals(currentUserId)) {
            throw new CustomException(ErrorCode.NOT_CLUB_CAPTAIN);
        }

        User newCaptain = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // 위임받을 유저가 해당 동아리의 멤버인지 확인
        ClubMember newCaptainMember = clubMemberRepository.findByClubAndUser(club, newCaptain)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MEMBER_NOT_FOUND));

        if (newCaptainMember.getStatus() != ClubMemberStatus.APPROVED) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        // 기존 주장을 일반 멤버로 변경
        ClubMember oldCaptainMember = clubMemberRepository.findByClubAndUser(club, club.getCaptain())
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MEMBER_NOT_FOUND));
        oldCaptainMember.setRole(ClubMemberRole.MEMBER);

        // 새 주장으로 변경
        newCaptainMember.setRole(ClubMemberRole.CAPTAIN);
        club.setCaptain(newCaptain);

        clubMemberRepository.save(oldCaptainMember);
        clubMemberRepository.save(newCaptainMember);
        clubRepository.save(club);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ApplicationResponse> getApplications(Long clubId, Long currentUserId) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        // 주장 권한 확인
        if (!club.getCaptain().getUserId().equals(currentUserId)) {
            throw new CustomException(ErrorCode.NOT_CLUB_CAPTAIN);
        }

        // 대기 중인 신청 목록 조회
        List<ClubMember> pendingApplications = clubMemberRepository.findByClubAndStatus(club, ClubMemberStatus.PENDING);

        return pendingApplications.stream()
                .map(ApplicationResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void leaveClub(Long clubId, Long currentUserId) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        User user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        ClubMember clubMember = clubMemberRepository.findByClubAndUser(club, user)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MEMBER_NOT_FOUND));

        if (clubMember.getRole() == ClubMemberRole.CAPTAIN) {
            throw new CustomException(ErrorCode.CANNOT_REMOVE_CAPTAIN);
        }
        clubMemberRepository.delete(clubMember);
    }

    @Override
    @Transactional
    public void kickMember(Long clubId, Long userId, Long currentUserId) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        if (!club.getCaptain().getUserId().equals(currentUserId)) {
            throw new CustomException(ErrorCode.NOT_CLUB_CAPTAIN);
        }

        User targetUser = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        ClubMember clubMember = clubMemberRepository.findByClubAndUser(club, targetUser)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MEMBER_NOT_FOUND));

        if (clubMember.getRole() == ClubMemberRole.CAPTAIN) {
            throw new CustomException(ErrorCode.CANNOT_REMOVE_CAPTAIN);
        }
        clubMemberRepository.delete(clubMember);
    }
}
