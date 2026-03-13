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
public class ClubListResponse {
    private UUID clubId;
    private String name;
    private String logoUrl;
    private String introduction;
    private long memberCount;
    private String captainName;
    private String captainProfileImageUrl;
    /** 내 동아리 조회 시에만 설정. 현재 사용자가 동아리장인지 여부 */
    private Boolean isCaptain;
    /** 동아리전 승리 수 (club_matches 기준) */
    private int wins;
    /** 전체 동아리 순위 (승리 수 기준, 1부터 시작) */
    private int rank;
}
