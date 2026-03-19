package com.pnu.basketball.service.match;

import com.pnu.basketball.dto.response.MatchResponse;

import java.util.List;
import java.util.UUID;

public interface MatchService {

    MatchResponse getMatch(UUID matchId);

    List<MatchResponse> getMyMatches(Long userId);

    void completeMatch(UUID matchId, Long userId);
}
