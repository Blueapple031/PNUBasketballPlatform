package com.pnu.basketball.service.club;

import com.pnu.basketball.dto.request.ClubSelectRequest;
import com.pnu.basketball.dto.response.ClubListResponse;
import com.pnu.basketball.dto.response.ClubSelectResponse;
import com.pnu.basketball.dto.response.ClubSelectionStatusResponse;

import java.util.List;

public interface ClubService {
    List<ClubListResponse> getClubs();
    ClubSelectResponse selectClub(Long userId, ClubSelectRequest request);
    ClubSelectionStatusResponse getClubSelectionStatus(Long userId);
    ClubListResponse getMyClub(Long userId);
}
