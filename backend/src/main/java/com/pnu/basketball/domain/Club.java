package com.pnu.basketball.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "clubs")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Club {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false)
    private UUID id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(name = "logo_url", length = 500)
    private String logoUrl;

    @Column(name = "introduction", columnDefinition = "TEXT")
    private String introduction;

    @Column(name = "wins", nullable = false)
    @Builder.Default
    private int wins = 0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "captain_id", referencedColumnName = "user_id")
    private User captain;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public void updateInfo(String name, String logoUrl, String introduction) {
        if (name != null) this.name = name;
        if (logoUrl != null) this.logoUrl = logoUrl;
        if (introduction != null) this.introduction = introduction;
    }

    public void setCaptain(User captain) {
        this.captain = captain;
    }

    public void incrementWins() {
        this.wins++;
    }
}
