package com.pnu.basketball.service.match;

import com.pnu.basketball.domain.Match;
import com.pnu.basketball.dto.response.MatchResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.MatchRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchServiceImpl implements MatchService {

    private final MatchRepository matchRepository;

    @Override
    @Transactional(readOnly = true)
    public MatchResponse getMatch(UUID matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new CustomException(ErrorCode.MATCH_NOT_FOUND));
        return toResponse(match);
    }

    @Override
    @Transactional(readOnly = true)
    public List<MatchResponse> getMyMatches(Long userId) {
        return matchRepository.findByParticipantUserId(userId).stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    private MatchResponse toResponse(Match match) {
        return MatchResponse.builder()
                .id(match.getId())
                .sourceType(match.getSourceType())
                .recruitmentId(match.getRecruitmentId())
                .locationName(match.getLocation().getName())
                .startAt(match.getStartAt())
                .endAt(match.getEndAt())
                .gameFormat(match.getGameFormat())
                .createdAt(match.getCreatedAt())
                .build();
    }
}
