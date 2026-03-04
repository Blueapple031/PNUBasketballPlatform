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
public class ClubSelectionStatusResponse {
    private boolean needsClubSelection;
    private Boolean isPnuStudent;
    private ClubSummary currentClub;

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ClubSummary {
        private UUID clubId;
        private String name;
    }
}
