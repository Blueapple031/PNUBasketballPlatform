package com.pnu.basketball.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
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

    private String password;

    @Column(name = "real_name", nullable = false, length = 50)
    private String realName;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "phone_number_verified_at")
    private LocalDateTime phoneNumberVerifiedAt;

    @Column(name = "profile_image_url", length = 500)
    private String profileImageUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "login_type", nullable = false)
    @Builder.Default
    private LoginType loginType = LoginType.EMAIL;

    @Column(name = "google_id", unique = true)
    private String googleId;

    @Column(name = "kakao_id", unique = true)
    private String kakaoId;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "is_pnu_student", nullable = false)
    @Builder.Default
    private Boolean isPnuStudent = false;

    @Column(name = "is_admin", nullable = false)
    @Builder.Default
    private Boolean isAdmin = false;

    @Column(name = "department", length = 100)
    private String department;

    @Column(name = "student_id", length = 20)
    private String studentId;

    @Column(nullable = false)
    @Builder.Default
    private Integer wins = 0;

    @Column(nullable = false)
    @Builder.Default
    private Integer games = 0;

    @Column(name = "total_score", nullable = false)
    @Builder.Default
    private Integer totalScore = 0;

    @Column(name = "virtual_currency", nullable = false)
    @Builder.Default
    private Integer virtualCurrency = 0;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "fcm_token", length = 500)
    private String fcmToken;

    @Column(name = "fcm_token_updated_at")
    private LocalDateTime fcmTokenUpdatedAt;

    @Column(unique = true, length = 30)
    private String nickname;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private Position position;

    @Column(nullable = false)
    @Builder.Default
    private Integer exp = 0;

    @Column(name = "no_show_count", nullable = false)
    @Builder.Default
    private Integer noShowCount = 0;

    @Column(name = "participation_count", nullable = false)
    @Builder.Default
    private Integer participationCount = 0;

    public void updateProfile(String realName, String phoneNumber, String profileImageUrl,
                              String nickname, Position position) {
        if (realName != null) this.realName = realName;
        if (phoneNumber != null) this.phoneNumber = phoneNumber;
        if (profileImageUrl != null) this.profileImageUrl = profileImageUrl;
        if (nickname != null) this.nickname = nickname;
        if (position != null) this.position = position;
    }

    public void updatePassword(String newPassword) {
        this.password = newPassword;
    }

    public void completeProfile(String realName, LocalDate dateOfBirth, Boolean isPnuStudent,
                                String department, String studentId, String nickname, Position position) {
        if (realName != null) this.realName = realName;
        if (dateOfBirth != null) this.dateOfBirth = dateOfBirth;
        if (isPnuStudent != null) this.isPnuStudent = isPnuStudent;
        if (department != null) this.department = department;
        if (studentId != null) this.studentId = studentId;
        if (nickname != null) this.nickname = nickname;
        if (position != null) this.position = position;
    }

    public void verifyPhoneNumber() {
        this.phoneNumberVerifiedAt = LocalDateTime.now();
    }

    public void linkGoogle(String profileImageUrl, String googleId) {
        if (profileImageUrl != null) this.profileImageUrl = profileImageUrl;
        this.googleId = googleId;
        this.loginType = LoginType.GOOGLE;
    }

    public void linkKakao(String profileImageUrl, String kakaoId) {
        if (profileImageUrl != null) this.profileImageUrl = profileImageUrl;
        this.kakaoId = kakaoId;
        this.loginType = LoginType.KAKAO;
    }

    public void updateFcmToken(String fcmToken) {
        this.fcmToken = fcmToken;
        this.fcmTokenUpdatedAt = LocalDateTime.now();
    }

    public void clearFcmToken() {
        this.fcmToken = null;
        this.fcmTokenUpdatedAt = null;
    }

    public void addExp(int amount) {
        this.exp += amount;
    }

    public void incrementParticipationCount() {
        this.participationCount++;
    }

    public void incrementNoShowCount() {
        this.noShowCount++;
    }
}
