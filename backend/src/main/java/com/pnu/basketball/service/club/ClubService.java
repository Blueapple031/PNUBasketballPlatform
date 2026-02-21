package com.pnu.basketball.service.club;

import com.pnu.basketball.dto.request.club.ClubUpdateRequest;
import com.pnu.basketball.dto.request.club.TransferCaptainRequest;
import com.pnu.basketball.dto.response.club.ApplicationResponse;
import com.pnu.basketball.dto.response.club.ClubResponse;

import java.util.List;

public interface ClubService {
    // 1. 동아리 검색
    List<ClubResponse> searchClubs(String keyword);
    
    // 2. 동아리 수정
    ClubResponse updateClub(Long clubId, ClubUpdateRequest request, Long currentUserId);
    
    // 3. 동아리 목록 조회
    List<ClubResponse> getAllClubs();
    
    // 4. 가입 승인
    void approveJoinRequest(Long clubId, Long userId, Long currentUserId);

    // 5. 가입 거절
    void rejectJoinRequest(Long clubId, Long userId, Long currentUserId);
    
    // 6. 주장 위임
    void transferCaptain(Long clubId, TransferCaptainRequest request, Long currentUserId);
    
    // 7. 신청 현황 확인
    List<ApplicationResponse> getApplications(Long clubId, Long currentUserId);
    
    // 8. 동아리 탈퇴 (본인)
    void leaveClub(Long clubId, Long currentUserId);

    // 9. 멤버 추방 (주장)
    void kickMember(Long clubId, Long userId, Long currentUserId);
}
