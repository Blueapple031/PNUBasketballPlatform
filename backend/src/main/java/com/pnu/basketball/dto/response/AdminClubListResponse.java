package com.pnu.basketball.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminClubListResponse {
    private UUID clubId;
    private String name;
    private String logoUrl;
    private String introduction;
    private String captainName;
    private Long captainId;
    private long memberCount;
}
