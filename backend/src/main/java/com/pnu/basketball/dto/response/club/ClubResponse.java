package com.pnu.basketball.dto.response.club;

import com.pnu.basketball.domain.Club;
import com.pnu.basketball.dto.response.UserResponse;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class ClubResponse {
    private Long id;
    private String name;
    private UserResponse captain;
    private String logoUrl;
    private String description;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static ClubResponse fromEntity(Club club) {
        return ClubResponse.builder()
                .id(club.getId())
                .name(club.getName())
                .captain(club.getCaptain() != null ? UserResponse.fromEntity(club.getCaptain()) : null)
                .logoUrl(club.getLogoUrl())
                .description(club.getDescription())
                .createdAt(club.getCreatedAt())
                .updatedAt(club.getUpdatedAt())
                .build();
    }
}

