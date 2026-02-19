package com.pnu.basketball.dto.response.club;

import com.pnu.basketball.domain.ClubMember;
import com.pnu.basketball.domain.ClubMemberStatus;
import com.pnu.basketball.dto.response.UserResponse;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class ApplicationResponse {
    private Long applicationId;
    private UserResponse user;
    private ClubMemberStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public static ApplicationResponse fromEntity(ClubMember clubMember) {
        return ApplicationResponse.builder()
                .applicationId(clubMember.getId())
                .user(UserResponse.fromEntity(clubMember.getUser()))
                .status(clubMember.getStatus())
                .createdAt(clubMember.getCreatedAt())
                .updatedAt(clubMember.getUpdatedAt())
                .build();
    }
}

