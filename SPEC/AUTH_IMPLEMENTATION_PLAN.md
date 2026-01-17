# 🔐 인증 기능 구현 작업 계획서 (Authentication Implementation Plan)

> **딸바 (PNU Basketball Platform)** 자체 로그인 및 구글 로그인 기능 구현 계획서  
> **버전**: 1.0.0  
> **작성일**: 2026-01

---

## 📋 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [기술 스택 및 의존성](#기술-스택-및-의존성)
3. [데이터베이스 설계](#데이터베이스-설계)
4. [Backend 구현 계획](#backend-구현-계획)
5. [Frontend 구현 계획](#frontend-구현-계획)
6. [작업 일정](#작업-일정)
7. [테스트 계획](#테스트-계획)
8. [배포 및 운영](#배포-및-운영)

---

## 🎯 프로젝트 개요

### 목표
- 이메일/비밀번호 기반 자체 로그인 기능 구현
- Google OAuth2.0 기반 소셜 로그인 기능 구현
- JWT 기반 인증 시스템 구축
- 안전하고 확장 가능한 인증 아키텍처 설계

### 범위
- ✅ 회원가입 (이메일/비밀번호)
- ✅ 로그인 (이메일/비밀번호)
- ✅ 구글 로그인 (OAuth2.0)
- ✅ JWT 토큰 발급 및 갱신
- ✅ 로그아웃
- ✅ 사용자 정보 조회
- ❌ 비밀번호 재설정 (향후 구현)
- ❌ 이메일 인증 (향후 구현)

---

## 🛠️ 기술 스택 및 의존성

### Backend 의존성 추가

**`backend/build.gradle`에 추가할 의존성:**

```groovy
dependencies {
    // 기존 의존성...
    
    // OAuth2 Client (구글 로그인)
    implementation 'org.springframework.boot:spring-boot-starter-oauth2-client'
    
    // Google API Client (ID Token 검증)
    implementation 'com.google.api-client:google-api-client:2.2.0'
    
    // JWT (이미 포함되어 있음)
    // implementation 'io.jsonwebtoken:jjwt-api:0.12.3'
    
    // Spring Security (이미 포함되어 있음)
    // implementation 'org.springframework.boot:spring-boot-starter-security'
}
```

### Frontend 의존성 추가

**`frontend/pubspec.yaml`에 추가할 패키지:**

```yaml
dependencies:
  # 기존 패키지...
  
  # 구글 로그인
  google_sign_in: ^6.1.5
  
  # 보안 저장소 (토큰 저장)
  flutter_secure_storage: ^9.0.0
  
  # HTTP 클라이언트 (이미 포함)
  # http: ^1.1.0
  
  # JSON 직렬화
  json_annotation: ^4.8.1

dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

---

## 🗄️ 데이터베이스 설계

### User 테이블

```sql
CREATE TABLE IF NOT EXISTS users (
    user_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),  -- NULL 가능 (구글 로그인 사용자)
    nickname VARCHAR(50) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    profile_image_url VARCHAR(500),
    login_type VARCHAR(20) NOT NULL DEFAULT 'EMAIL',  -- EMAIL, GOOGLE
    google_id VARCHAR(255) UNIQUE,  -- 구글 사용자 ID
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_users_nickname ON users(nickname);

-- updated_at 자동 업데이트를 위한 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_at 트리거 생성
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### RefreshToken 테이블 (Redis 사용 권장)

**옵션 1: Redis 사용 (권장)**
- Key: `refresh_token:{userId}`
- Value: `{refreshToken}`
- TTL: 7일

**옵션 2: PostgreSQL 테이블 (대안)**

```sql
CREATE TABLE IF NOT EXISTS refresh_tokens (
    token_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
```

---

## 🔧 Backend 구현 계획

### 1단계: 프로젝트 설정 및 의존성 추가

#### 작업 내용
1. `build.gradle`에 OAuth2 Client 의존성 추가
2. `application.yml`에 구글 OAuth2 설정 추가
3. JWT 설정 값 추가

#### 파일 목록
- `backend/build.gradle` (수정)
- `backend/src/main/resources/application.yml` (수정)
- `backend/src/main/resources/application-dev.yml` (신규)

#### 설정 예시

**`application.yml`**:
```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: ${GOOGLE_CLIENT_ID}
            client-secret: ${GOOGLE_CLIENT_SECRET}
            scope:
              - openid
              - profile
              - email
        provider:
          google:
            issuer-uri: https://accounts.google.com

jwt:
  secret: ${JWT_SECRET:your-secret-key-change-in-production}
  access-token-expiration: 3600000  # 1시간 (밀리초)
  refresh-token-expiration: 604800000  # 7일 (밀리초)

google:
  oauth2:
    client-id: ${GOOGLE_CLIENT_ID}
```

---

### 2단계: 도메인 모델 생성

#### 작업 내용
1. `User` 엔티티 생성
2. `LoginType` Enum 생성
3. JPA Repository 생성

#### 파일 목록
- `backend/src/main/java/com/pnu/basketball/domain/User.java` (신규)
- `backend/src/main/java/com/pnu/basketball/domain/LoginType.java` (신규)
- `backend/src/main/java/com/pnu/basketball/repository/UserRepository.java` (신규)

#### 구현 예시

**`User.java`**:
```java
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
```

**`LoginType.java`**:
```java
package com.pnu.basketball.domain;

public enum LoginType {
    EMAIL,
    GOOGLE
}
```

**`UserRepository.java`**:
```java
package com.pnu.basketball.repository;

import com.pnu.basketball.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByGoogleId(String googleId);
    boolean existsByEmail(String email);
    boolean existsByNickname(String nickname);
}
```

---

### 3단계: DTO 생성

#### 작업 내용
1. 요청 DTO 생성
2. 응답 DTO 생성

#### 파일 목록
- `backend/src/main/java/com/pnu/basketball/dto/request/SignupRequest.java` (신규)
- `backend/src/main/java/com/pnu/basketball/dto/request/LoginRequest.java` (신규)
- `backend/src/main/java/com/pnu/basketball/dto/request/GoogleLoginRequest.java` (신규)
- `backend/src/main/java/com/pnu/basketball/dto/request/RefreshTokenRequest.java` (신규)
- `backend/src/main/java/com/pnu/basketball/dto/response/AuthResponse.java` (신규)
- `backend/src/main/java/com/pnu/basketball/dto/response/UserResponse.java` (신규)

#### 구현 예시

**`SignupRequest.java`**:
```java
package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class SignupRequest {
    
    @NotBlank(message = "이메일은 필수입니다.")
    @Email(message = "유효한 이메일 형식이 아닙니다.")
    private String email;
    
    @NotBlank(message = "비밀번호는 필수입니다.")
    @Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다.")
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$",
             message = "비밀번호는 영문, 숫자, 특수문자를 포함해야 합니다.")
    private String password;
    
    @NotBlank(message = "닉네임은 필수입니다.")
    @Size(min = 2, max = 20, message = "닉네임은 2-20자 사이여야 합니다.")
    private String nickname;
    
    @Pattern(regexp = "^010-\\d{4}-\\d{4}$", message = "전화번호 형식이 올바르지 않습니다.")
    private String phoneNumber;
}
```

**`AuthResponse.java`**:
```java
package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.LoginType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private Long expiresIn;
    private UserInfo user;
    
    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserInfo {
        private Long userId;
        private String email;
        private String nickname;
        private String profileImageUrl;
        private LoginType loginType;
        private Boolean isNewUser;  // 구글 로그인 시 사용
    }
}
```

---

### 4단계: 유틸리티 클래스 생성

#### 작업 내용
1. JWT 유틸리티 생성
2. 비밀번호 인코더 유틸리티 생성

#### 파일 목록
- `backend/src/main/java/com/pnu/basketball/util/JwtUtil.java` (신규)
- `backend/src/main/java/com/pnu/basketball/util/PasswordUtil.java` (신규)

#### 구현 예시

**`JwtUtil.java`** (핵심 로직):
```java
package com.pnu.basketball.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Component
public class JwtUtil {
    
    @Value("${jwt.secret}")
    private String secret;
    
    @Value("${jwt.access-token-expiration}")
    private Long accessTokenExpiration;
    
    @Value("${jwt.refresh-token-expiration}")
    private Long refreshTokenExpiration;
    
    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }
    
    public String generateAccessToken(Long userId, String email, String nickname, String loginType) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("email", email);
        claims.put("nickname", nickname);
        claims.put("loginType", loginType);
        
        return Jwts.builder()
                .claims(claims)
                .subject(String.valueOf(userId))
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + accessTokenExpiration))
                .signWith(getSigningKey())
                .compact();
    }
    
    public String generateRefreshToken(Long userId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("tokenType", "REFRESH");
        
        return Jwts.builder()
                .claims(claims)
                .subject(String.valueOf(userId))
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + refreshTokenExpiration))
                .signWith(getSigningKey())
                .compact();
    }
    
    public Claims extractClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
    
    public Long extractUserId(String token) {
        return Long.parseLong(extractClaims(token).getSubject());
    }
    
    public boolean isTokenExpired(String token) {
        return extractClaims(token).getExpiration().before(new Date());
    }
}
```

---

### 5단계: 서비스 계층 구현

#### 작업 내용
1. AuthService 구현
2. GoogleAuthService 구현 (구글 로그인 전용)

#### 파일 목록
- `backend/src/main/java/com/pnu/basketball/service/auth/AuthService.java` (신규)
- `backend/src/main/java/com/pnu/basketball/service/auth/AuthServiceImpl.java` (신규)
- `backend/src/main/java/com/pnu/basketball/service/auth/GoogleAuthService.java` (신규)
- `backend/src/main/java/com/pnu/basketball/service/auth/GoogleAuthServiceImpl.java` (신규)

#### 구현 예시

**`AuthService.java`** (인터페이스):
```java
package com.pnu.basketball.service.auth;

import com.pnu.basketball.dto.request.LoginRequest;
import com.pnu.basketball.dto.request.SignupRequest;
import com.pnu.basketball.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse signup(SignupRequest request);
    AuthResponse login(LoginRequest request);
    AuthResponse refreshToken(String refreshToken);
    void logout(Long userId, String refreshToken);
}
```

**`AuthServiceImpl.java`** (핵심 로직):
```java
package com.pnu.basketball.service.auth;

import com.pnu.basketball.domain.LoginType;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.LoginRequest;
import com.pnu.basketball.dto.request.SignupRequest;
import com.pnu.basketball.dto.response.AuthResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.UserRepository;
import com.pnu.basketball.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    
    @Override
    @Transactional
    public AuthResponse signup(SignupRequest request) {
        // 이메일 중복 확인
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new CustomException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }
        
        // 닉네임 중복 확인
        if (userRepository.existsByNickname(request.getNickname())) {
            throw new CustomException(ErrorCode.NICKNAME_ALREADY_EXISTS);
        }
        
        // 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(request.getPassword());
        
        // 사용자 생성
        User user = User.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .nickname(request.getNickname())
                .phoneNumber(request.getPhoneNumber())
                .loginType(LoginType.EMAIL)
                .build();
        
        user = userRepository.save(user);
        
        // 토큰 발급
        return generateAuthResponse(user, false);
    }
    
    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        
        // 비밀번호 확인
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_CREDENTIALS);
        }
        
        return generateAuthResponse(user, false);
    }
    
    @Override
    public AuthResponse refreshToken(String refreshToken) {
        // Refresh Token 검증
        Long userId = jwtUtil.extractUserId(refreshToken);
        
        // Redis에서 Refresh Token 확인 (또는 DB)
        // TODO: Redis 연동
        
        // 새로운 Access Token 발급
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        
        String newAccessToken = jwtUtil.generateAccessToken(
                user.getUserId(),
                user.getEmail(),
                user.getNickname(),
                user.getLoginType().name()
        );
        
        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .tokenType("Bearer")
                .expiresIn(3600L)
                .build();
    }
    
    @Override
    public void logout(Long userId, String refreshToken) {
        // Redis에서 Refresh Token 삭제
        // TODO: Redis 연동
    }
    
    private AuthResponse generateAuthResponse(User user, boolean isNewUser) {
        String accessToken = jwtUtil.generateAccessToken(
                user.getUserId(),
                user.getEmail(),
                user.getNickname(),
                user.getLoginType().name()
        );
        
        String refreshToken = jwtUtil.generateRefreshToken(user.getUserId());
        
        // Redis에 Refresh Token 저장
        // TODO: Redis 연동
        
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(3600L)
                .user(AuthResponse.UserInfo.builder()
                        .userId(user.getUserId())
                        .email(user.getEmail())
                        .nickname(user.getNickname())
                        .profileImageUrl(user.getProfileImageUrl())
                        .loginType(user.getLoginType())
                        .isNewUser(isNewUser)
                        .build())
                .build();
    }
}
```

**`GoogleAuthService.java`**:
```java
package com.pnu.basketball.service.auth;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.pnu.basketball.domain.LoginType;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.GoogleLoginRequest;
import com.pnu.basketball.dto.response.AuthResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.UserRepository;
import com.pnu.basketball.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;

@Service
@RequiredArgsConstructor
public class GoogleAuthServiceImpl implements GoogleAuthService {
    
    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    
    @Value("${google.oauth2.client-id}")
    private String googleClientId;
    
    @Override
    @Transactional
    public AuthResponse authenticate(GoogleLoginRequest request) {
        // Google ID Token 검증
        GoogleIdToken idToken = verifyGoogleToken(request.getIdToken());
        
        if (idToken == null) {
            throw new CustomException(ErrorCode.GOOGLE_TOKEN_INVALID);
        }
        
        GoogleIdToken.Payload payload = idToken.getPayload();
        String email = payload.getEmail();
        String name = (String) payload.get("name");
        String pictureUrl = (String) payload.get("picture");
        String googleId = payload.getSubject();
        
        // 기존 사용자 조회 또는 신규 생성
        User user = userRepository.findByGoogleId(googleId)
                .orElseGet(() -> {
                    // 이메일로도 조회 (기존 이메일 로그인 사용자가 구글 로그인 시도)
                    return userRepository.findByEmail(email)
                            .map(existingUser -> {
                                // 기존 사용자에 구글 정보 연결
                                existingUser = User.builder()
                                        .userId(existingUser.getUserId())
                                        .email(existingUser.getEmail())
                                        .password(existingUser.getPassword())
                                        .nickname(existingUser.getNickname())
                                        .phoneNumber(existingUser.getPhoneNumber())
                                        .profileImageUrl(pictureUrl)
                                        .loginType(LoginType.GOOGLE)
                                        .googleId(googleId)
                                        .build();
                                return userRepository.save(existingUser);
                            })
                            .orElseGet(() -> {
                                // 신규 사용자 생성
                                String nickname = generateNickname(name, email);
                                User newUser = User.builder()
                                        .email(email)
                                        .nickname(nickname)
                                        .profileImageUrl(pictureUrl)
                                        .loginType(LoginType.GOOGLE)
                                        .googleId(googleId)
                                        .build();
                                return userRepository.save(newUser);
                            });
                });
        
        boolean isNewUser = user.getGoogleId() == null || 
                           !userRepository.existsByGoogleId(googleId);
        
        return generateAuthResponse(user, isNewUser);
    }
    
    private GoogleIdToken verifyGoogleToken(String idTokenString) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    new GsonFactory())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();
            
            return verifier.verify(idTokenString);
        } catch (Exception e) {
            throw new CustomException(ErrorCode.GOOGLE_TOKEN_INVALID);
        }
    }
    
    private String generateNickname(String name, String email) {
        String baseNickname = name != null ? name : email.split("@")[0];
        String nickname = baseNickname;
        int suffix = 1;
        
        while (userRepository.existsByNickname(nickname)) {
            nickname = baseNickname + suffix;
            suffix++;
        }
        
        return nickname;
    }
    
    private AuthResponse generateAuthResponse(User user, boolean isNewUser) {
        // AuthServiceImpl의 generateAuthResponse와 동일한 로직
        // ...
    }
}
```

---

### 6단계: 컨트롤러 구현

#### 작업 내용
1. AuthController 구현

#### 파일 목록
- `backend/src/main/java/com/pnu/basketball/controller/auth/AuthController.java` (신규)

#### 구현 예시

**`AuthController.java`**:
```java
package com.pnu.basketball.controller.auth;

import com.pnu.basketball.dto.request.*;
import com.pnu.basketball.dto.response.AuthResponse;
import com.pnu.basketball.dto.response.UserResponse;
import com.pnu.basketball.service.auth.AuthService;
import com.pnu.basketball.service.auth.GoogleAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthService authService;
    private final GoogleAuthService googleAuthService;
    
    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@Valid @RequestBody SignupRequest request) {
        AuthResponse response = authService.signup(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        AuthResponse response = googleAuthService.authenticate(request);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody RefreshTokenRequest request) {
        authService.logout(userId, request.getRefreshToken());
        return ResponseEntity.ok().build();
    }
    
    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(@AuthenticationPrincipal Long userId) {
        // TODO: UserService에서 사용자 정보 조회
        return ResponseEntity.ok(null);
    }
    
    @GetMapping("/check-email")
    public ResponseEntity<Map<String, Object>> checkEmail(@RequestParam String email) {
        // TODO: 이메일 중복 확인 로직
        return ResponseEntity.ok(null);
    }
    
    @GetMapping("/check-nickname")
    public ResponseEntity<Map<String, Object>> checkNickname(@RequestParam String nickname) {
        // TODO: 닉네임 중복 확인 로직
        return ResponseEntity.ok(null);
    }
}
```

---

### 7단계: Spring Security 설정

#### 작업 내용
1. SecurityConfig 구현
2. JWT 필터 구현

#### 파일 목록
- `backend/src/main/java/com/pnu/basketball/config/SecurityConfig.java` (신규)
- `backend/src/main/java/com/pnu/basketball/config/JwtAuthenticationFilter.java` (신규)
- `backend/src/main/java/com/pnu/basketball/config/JwtAuthenticationEntryPoint.java` (신규)

---

## 📱 Frontend 구현 계획

### 1단계: 프로젝트 설정

#### 작업 내용
1. `pubspec.yaml`에 패키지 추가
2. `flutter pub get` 실행

---

### 2단계: 데이터 모델 생성

#### 파일 목록
- `frontend/lib/data/models/user_model.dart` (신규)
- `frontend/lib/data/models/auth_response_model.dart` (신규)

---

### 3단계: API 서비스 구현

#### 파일 목록
- `frontend/lib/data/services/api_service.dart` (수정)
- `frontend/lib/data/services/auth_service.dart` (신규)

---

### 4단계: Repository 구현

#### 파일 목록
- `frontend/lib/data/repositories/auth_repository.dart` (신규)

---

### 5단계: Provider 구현 (상태 관리)

#### 파일 목록
- `frontend/lib/presentation/providers/auth_provider.dart` (신규)

---

### 6단계: UI 구현

#### 파일 목록
- `frontend/lib/presentation/screens/auth/login_screen.dart` (신규)
- `frontend/lib/presentation/screens/auth/signup_screen.dart` (신규)
- `frontend/lib/presentation/widgets/auth/google_sign_in_button.dart` (신규)

---

## 📅 작업 일정

### Phase 1: Backend 기반 작업 (1주)
- [ ] Day 1-2: 프로젝트 설정 및 데이터베이스 설계
- [ ] Day 3-4: 도메인 모델 및 DTO 생성
- [ ] Day 5: 유틸리티 클래스 구현
- [ ] Day 6-7: 서비스 계층 구현

### Phase 2: Backend API 구현 (1주)
- [ ] Day 1-2: 컨트롤러 구현
- [ ] Day 3-4: Spring Security 설정
- [ ] Day 5: 예외 처리 및 에러 핸들링
- [ ] Day 6-7: 테스트 및 버그 수정

### Phase 3: Frontend 구현 (1주)
- [ ] Day 1-2: 데이터 모델 및 API 서비스
- [ ] Day 3-4: Repository 및 Provider 구현
- [ ] Day 5-6: UI 구현
- [ ] Day 7: 통합 테스트

### Phase 4: 통합 및 배포 (3일)
- [ ] Day 1: 통합 테스트
- [ ] Day 2: 버그 수정 및 최적화
- [ ] Day 3: 문서화 및 배포

**총 예상 기간**: 약 3주

---

## 🧪 테스트 계획

### Backend 테스트
1. **단위 테스트**
   - JwtUtil 테스트
   - AuthService 테스트
   - GoogleAuthService 테스트

2. **통합 테스트**
   - AuthController 테스트
   - 전체 인증 플로우 테스트

### Frontend 테스트
1. **위젯 테스트**
   - 로그인 화면 테스트
   - 회원가입 화면 테스트

2. **통합 테스트**
   - 로그인 플로우 테스트
   - 구글 로그인 플로우 테스트

---

## 🚀 배포 및 운영

### 환경 변수 설정
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `JWT_SECRET`
- `DATABASE_URL`
- `REDIS_URL`

### 보안 체크리스트
- [ ] HTTPS 적용
- [ ] JWT Secret 키 안전하게 관리
- [ ] Rate Limiting 적용
- [ ] CORS 설정 확인
- [ ] 로그 모니터링 설정

---

## 📝 참고 자료

- [Spring Security 공식 문서](https://spring.io/projects/spring-security)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [JWT.io](https://jwt.io/)
- [OAuth 2.0 공식 문서](https://oauth.net/2/)

---

**문서 작성일**: 2026년 1월  
**작성자**: 딸바 개발팀

