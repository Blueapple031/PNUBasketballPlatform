package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.Position;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReviewFormResponse {
    private UUID matchId;
    private LocalDateTime startAt;
    private LocalDateTime endAt;
    private String locationName;
    private boolean alreadySubmitted;
    private List<ParticipantInfo> participants;

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ParticipantInfo {
        private Long userId;
        private String nickname;
        private Position position;
        private Integer exp;
    }
}
