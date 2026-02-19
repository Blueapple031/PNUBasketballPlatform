package com.pnu.basketball.service.club;

import com.pnu.basketball.dto.request.club.ClubCreateRequest;
import com.pnu.basketball.dto.request.club.ClubUpdateRequest;
import com.pnu.basketball.dto.request.club.TransferCaptainRequest;
import com.pnu.basketball.dto.request.club.UpdateApplicationRequest;
import com.pnu.basketball.dto.response.club.ApplicationResponse;
import com.pnu.basketball.dto.response.club.ClubResponse;

import java.util.List;

public interface ClubService {
    // 1. 동아리 생성
    ClubResponse createClub(ClubCreateRequest request, Long currentUserId);
    
    // 2. 동아리 검색
    List<ClubResponse> searchClubs(String keyword);
    
    // 3. 동아리 수정
    ClubResponse updateClub(Long clubId, ClubUpdateRequest request, Long currentUserId);
    
    // 4. 동아리 목록 조회
    List<ClubResponse> getAllClubs();
    
    // 5. 가입 승인/거절
    void handleApplication(Long clubId, Long userId, UpdateApplicationRequest request, Long currentUserId);
    
    // 6. 주장 위임
    void transferCaptain(Long clubId, TransferCaptainRequest request, Long currentUserId);
    
    // 7. 신청 현황 확인
    List<ApplicationResponse> getApplications(Long clubId, Long currentUserId);
    
    // 8. 멤버 탈퇴/추방
    void removeMember(Long clubId, Long userId, Long currentUserId);
}
