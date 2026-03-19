package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.ClubMatchStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClubMatchRequestResponse {
    private UUID id;
    private UUID homeClubId;
    private String homeClubName;
    private UUID awayClubId;
    private String awayClubName;
    private LocalDateTime startAt;
    private LocalDateTime endAt;
    private String locationName;
    private ClubMatchStatus status;
    private Long homeAttendanceCount;
    private Long awayAttendanceCount;
    private LocalDateTime createdAt;
}
