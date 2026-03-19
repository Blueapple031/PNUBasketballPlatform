package com.pnu.basketball.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "club_match_requests")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class ClubMatchRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "home_club_id", nullable = false)
    private Club homeClub;

    @Column(name = "start_at", nullable = false)
    private LocalDateTime startAt;

    @Column(name = "end_at", nullable = false)
    private LocalDateTime endAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id", nullable = false)
    private ScheduleLocationEntity location;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private ClubMatchStatus status = ClubMatchStatus.GATHERING;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "away_club_id")
    private Club awayClub;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public void ready() {
        this.status = ClubMatchStatus.READY;
    }

    public void matchWith(Club awayClub) {
        this.awayClub = awayClub;
        this.status = ClubMatchStatus.MATCHED;
    }

    public void confirm() {
        this.status = ClubMatchStatus.CONFIRMED;
    }

    public void done() {
        this.status = ClubMatchStatus.DONE;
    }

    public void cancel() {
        this.status = ClubMatchStatus.CANCELLED;
    }

    public boolean isHomeClub(UUID clubId) {
        return this.homeClub.getId().equals(clubId);
    }

    public boolean isAwayClub(UUID clubId) {
        return this.awayClub != null && this.awayClub.getId().equals(clubId);
    }

    public boolean isInvolvedClub(UUID clubId) {
        return isHomeClub(clubId) || isAwayClub(clubId);
    }
}
