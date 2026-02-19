package com.pnu.basketball.service.club;

import com.pnu.basketball.domain.Club;
import com.pnu.basketball.domain.ClubMember;
import com.pnu.basketball.domain.ClubMemberRole;
import com.pnu.basketball.domain.ClubMemberStatus;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.club.ClubCreateRequest;
import com.pnu.basketball.dto.request.club.ClubUpdateRequest;
import com.pnu.basketball.dto.request.club.TransferCaptainRequest;
import com.pnu.basketball.dto.request.club.UpdateApplicationRequest;
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
    @Transactional
    public ClubResponse createClub(ClubCreateRequest request, Long currentUserId) {
        User captain = userRepository.findById(currentUserId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // Club 생성
        Club club = Club.builder()
                .name(request.getName())
                .logoUrl(request.getLogoUrl())
                .captain(captain)
                .build();

        Club savedClub = clubRepository.save(club);

        // 생성자를 주장(CAPTAIN)으로 멤버 리스트에 추가
        ClubMember clubMember = ClubMember.builder()
                .club(savedClub)
                .user(captain)
                .role(ClubMemberRole.CAPTAIN)
                .status(ClubMemberStatus.APPROVED) // 주장은 자동 승인
                .build();

        clubMemberRepository.save(clubMember);

        return ClubResponse.fromEntity(savedClub);
    }

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
    public void handleApplication(Long clubId, Long userId, UpdateApplicationRequest request, Long currentUserId) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        // 주장 권한 확인
        if (!club.getCaptain().getUserId().equals(currentUserId)) {
            throw new CustomException(ErrorCode.NOT_CLUB_CAPTAIN);
        }

        User applicant = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        ClubMember clubMember = clubMemberRepository.findByClubAndUser(club, applicant)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MEMBER_NOT_FOUND));

        // 상태 업데이트
        clubMember.setStatus(request.getStatus());
        
        // 승인된 경우 멤버로 추가
        if (request.getStatus() == ClubMemberStatus.APPROVED) {
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
    public void removeMember(Long clubId, Long userId, Long currentUserId) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));

        User targetUser = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        ClubMember clubMember = clubMemberRepository.findByClubAndUser(club, targetUser)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_MEMBER_NOT_FOUND));

        // 자진 탈퇴: 본인인 경우
        if (userId.equals(currentUserId)) {
            // 주장은 탈퇴할 수 없음
            if (clubMember.getRole() == ClubMemberRole.CAPTAIN) {
                throw new CustomException(ErrorCode.CANNOT_REMOVE_CAPTAIN);
            }
            clubMemberRepository.delete(clubMember);
            return;
        }

        // 강제 추방: 주장인 경우
        if (!club.getCaptain().getUserId().equals(currentUserId)) {
            throw new CustomException(ErrorCode.NOT_CLUB_CAPTAIN);
        }

        // 주장은 추방할 수 없음
        if (clubMember.getRole() == ClubMemberRole.CAPTAIN) {
            throw new CustomException(ErrorCode.CANNOT_REMOVE_CAPTAIN);
        }

        clubMemberRepository.delete(clubMember);
    }
}
