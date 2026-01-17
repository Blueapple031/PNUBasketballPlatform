package com.pnu.basketball.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    private String password;  // 구글 로그인 사용자는 NULL
    
    @Column(nullable = false, unique = true, length = 50)
    private String nickname;
    
    @Column(name = "phone_number")
    private String phoneNumber;
    
    @Column(name = "profile_image_url", length = 500)
    private String profileImageUrl;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "login_type", nullable = false)
    @Builder.Default
    private LoginType loginType = LoginType.EMAIL;
    
    @Column(name = "google_id", unique = true)
    private String googleId;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}

