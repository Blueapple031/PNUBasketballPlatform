package com.pnu.basketball.dto.response;

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
public class PollResponse {
    private UUID id;
    private String question;
    private List<PollOptionResponse> options;
    private LocalDateTime expiresAt;
    private Integer totalVotes;
    private UUID myVoteOptionId;
}
