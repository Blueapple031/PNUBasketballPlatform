package com.pnu.basketball.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "club_match_results")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class ClubMatchResult {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "request_id", nullable = false, unique = true)
    private ClubMatchRequest request;

    @Column(name = "home_score", nullable = false)
    private Integer homeScore;

    @Column(name = "away_score", nullable = false)
    private Integer awayScore;

    @Column(name = "home_approved", nullable = false)
    @Builder.Default
    private Boolean homeApproved = false;

    @Column(name = "away_approved", nullable = false)
    @Builder.Default
    private Boolean awayApproved = false;

    @Column(name = "admin_approved", nullable = false)
    @Builder.Default
    private Boolean adminApproved = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public void approveHome() {
        this.homeApproved = true;
    }

    public void approveAway() {
        this.awayApproved = true;
    }

    public void approveAdmin() {
        this.adminApproved = true;
    }

    public boolean isBothApproved() {
        return Boolean.TRUE.equals(homeApproved) && Boolean.TRUE.equals(awayApproved);
    }

    public boolean isFullyApproved() {
        return isBothApproved() && Boolean.TRUE.equals(adminApproved);
    }
}
