package com.pnu.basketball.dto.response;

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
public class PostListResponse {
    private UUID id;
    private String title;
    private String authorName;
    private String authorProfileImageUrl;
    private Integer viewCount;
    private Integer commentCount;
    private Boolean isPinned;
    private LocalDateTime createdAt;
}
