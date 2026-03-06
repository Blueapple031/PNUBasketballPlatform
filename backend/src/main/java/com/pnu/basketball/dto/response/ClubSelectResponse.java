package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.ClubRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClubSelectResponse {
    private UUID clubId;
    private String clubName;
    private ClubRole role;
}
