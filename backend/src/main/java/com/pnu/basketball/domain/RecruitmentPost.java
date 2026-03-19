package com.pnu.basketball.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcType;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.dialect.PostgreSQLEnumJdbcType;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "recruitment_posts")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class RecruitmentPost {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;

    @Column(name = "start_at", nullable = false)
    private LocalDateTime startAt;

    @Column(name = "end_at", nullable = false)
    private LocalDateTime endAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id", nullable = false)
    private ScheduleLocationEntity location;

    @Column(name = "base_members_count", nullable = false)
    private Integer baseMembersCount;

    @Column(name = "needed_members", nullable = false)
    private Integer neededMembers;

    @Enumerated(EnumType.STRING)
    @JdbcType(PostgreSQLEnumJdbcType.class)
    @Column(name = "game_format", nullable = false, columnDefinition = "recruitment_game_format")
    private RecruitmentGameFormat gameFormat;

    @Column(name = "deadline_at")
    private LocalDateTime deadlineAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private RecruitmentStatus status = RecruitmentStatus.OPEN;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    public void confirm() {
        this.status = RecruitmentStatus.CONFIRMED;
    }

    public void cancel() {
        this.status = RecruitmentStatus.CANCELLED;
    }

    public void close() {
        this.status = RecruitmentStatus.CLOSED;
    }

    public boolean isAuthor(Long userId) {
        return this.author.getUserId().equals(userId);
    }
}
