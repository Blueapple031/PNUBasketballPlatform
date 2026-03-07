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
public class CommentResponse {
    private UUID id;
    private Long authorId;
    private String authorName;
    private String authorProfileImageUrl;
    private String content;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
