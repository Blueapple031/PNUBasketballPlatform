package com.pnu.basketball.service.club;

import com.pnu.basketball.dto.request.ClubSelectRequest;
import com.pnu.basketball.dto.request.ClubUpdateIntroductionRequest;
import com.pnu.basketball.dto.response.ClubListResponse;
import com.pnu.basketball.dto.response.ClubMemberResponse;
import com.pnu.basketball.dto.response.ClubSelectResponse;
import com.pnu.basketball.dto.response.ClubSelectionStatusResponse;

import java.util.List;
import java.util.UUID;

public interface ClubService {
    List<ClubListResponse> getClubs();
    ClubSelectResponse selectClub(Long userId, ClubSelectRequest request);
    ClubSelectionStatusResponse getClubSelectionStatus(Long userId);
    ClubListResponse getMyClub(Long userId);
    List<ClubMemberResponse> getClubMembers(UUID clubId);
    ClubListResponse updateMyClubIntroduction(Long userId, ClubUpdateIntroductionRequest request);
}
