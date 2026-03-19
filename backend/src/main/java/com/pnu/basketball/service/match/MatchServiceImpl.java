package com.pnu.basketball.service.match;

import com.pnu.basketball.domain.*;
import com.pnu.basketball.dto.response.MatchResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.*;
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
    private final RecruitmentPostRepository recruitmentPostRepository;
    private final ClubMatchRequestRepository clubMatchRequestRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final MatchParticipationRepository participationRepository;
    private final UserRepository userRepository;

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

    @Override
    @Transactional
    public void completeMatch(UUID matchId, Long userId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new CustomException(ErrorCode.MATCH_NOT_FOUND));

        boolean authorized = false;

        if (match.getSourceType() == MatchSourceType.RECRUITMENT && match.getRecruitmentId() != null) {
            RecruitmentPost post = recruitmentPostRepository.findById(match.getRecruitmentId()).orElse(null);
            if (post != null && post.isAuthor(userId)) {
                authorized = true;
            }
        } else if (match.getSourceType() == MatchSourceType.CLUB_MATCH && match.getClubMatchRequestId() != null) {
            ClubMatchRequest request = clubMatchRequestRepository.findById(match.getClubMatchRequestId()).orElse(null);
            if (request != null) {
                ClubMember member = clubMemberRepository.findByUserUserId(userId).orElse(null);
                if (member != null && member.getRole() == ClubRole.PRESIDENT && request.isInvolvedClub(member.getClub().getId())) {
                    authorized = true;
                }
            }
        }

        User user = userRepository.findById(userId).orElse(null);
        if (user != null && Boolean.TRUE.equals(user.getIsAdmin())) {
            authorized = true;
        }

        if (!authorized) {
            throw new CustomException(ErrorCode.MATCH_COMPLETE_UNAUTHORIZED);
        }

        List<MatchParticipation> participations = participationRepository.findByMatchId(matchId);
        for (MatchParticipation p : participations) {
            if (p.getStatus() == ParticipationStatus.ATTENDED) {
                p.getUser().incrementParticipationCount();
                p.getUser().addExp(match.getSourceType() == MatchSourceType.CLUB_MATCH ? 30 : 10);
            }
        }
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
