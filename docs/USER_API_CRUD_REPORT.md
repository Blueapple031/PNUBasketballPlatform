# User API CRUD 생성 보고서

> **작성일**: 2026-02-12  
> **프로젝트**: PNUBasketballPlatform (딸바)  
> **작성자**: 개발팀

---

## 📋 목차

1. [개요](#개요)
2. [API 엔드포인트 목록](#api-엔드포인트-목록)
3. [CRUD 기능 상세](#crud-기능-상세)
4. [데이터 모델](#데이터-모델)
5. [보안 및 인증](#보안-및-인증)
6. [에러 처리](#에러-처리)
7. [구현 파일 구조](#구현-파일-구조)
8. [테스트 가이드](#테스트-가이드)

---

## 1. 개요

User API는 사용자 계정 관리 및 프로필 관리를 위한 RESTful API입니다.  
다음 CRUD 기능을 제공합니다:

- **Create**: 회원가입
- **Read**: 사용자 정보 조회
- **Update**: 프로필 수정, 비밀번호 변경
- **Delete**: 회원 탈퇴 (소프트 삭제)

### 기술 스택

- **Backend Framework**: Spring Boot 3.x
- **Language**: Java 17+
- **Database**: PostgreSQL
- **Cache**: Redis (Refresh Token 저장)
- **Security**: Spring Security + JWT
- **API Documentation**: Swagger/OpenAPI 3

---

## 2. API 엔드포인트 목록

### 2.1 인증 관련 엔드포인트 (`/api/auth`)

| Method | Endpoint | 설명 | 인증 필요 |
|--------|----------|------|----------|
| POST | `/api/auth/signup` | 회원가입 | ❌ |
| GET | `/api/auth/me` | 현재 사용자 정보 조회 | ✅ |
| GET | `/api/auth/check-email` | 이메일 중복 체크 | ❌ |
| GET | `/api/auth/check-nickname` | 닉네임 중복 체크 | ❌ |

### 2.2 사용자 관리 엔드포인트 (`/api/users`)

| Method | Endpoint | 설명 | 인증 필요 |
|--------|----------|------|----------|
| PUT | `/api/users/me` | 프로필 수정 | ✅ |
| PUT | `/api/users/me/password` | 비밀번호 변경 | ✅ |
| DELETE | `/api/users/me` | 회원 탈퇴 | ✅ |

---

## 3. CRUD 기능 상세

### 3.1 Create - 회원가입

**엔드포인트**: `POST /api/auth/signup`

**요청 본문** (`SignupRequest`):
```json
{
  "email": "user@example.com",
  "password": "Password123!",
  "nickname": "user123",
  "phoneNumber": "010-1234-5678"
}
```

**요청 검증**:
- `email`: 필수, 유효한 이메일 형식
- `password`: 필수, 8자 이상, 영문/숫자/특수문자 포함
- `nickname`: 필수, 2-20자 사이
- `phoneNumber`: 선택, 형식 `010-XXXX-XXXX`

**응답** (`AuthResponse`):
```json
{
  "success": true,
  "message": "회원가입이 완료되었습니다.",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "userId": 1,
      "email": "user@example.com",
      "nickname": "user123",
      "phoneNumber": "010-1234-5678",
      "profileImageUrl": null,
      "loginType": "EMAIL",
      "createdAt": "2026-02-12T10:00:00",
      "updatedAt": "2026-02-12T10:00:00"
    }
  }
}
```

**비즈니스 로직**:
1. 이메일 중복 체크
2. 닉네임 중복 체크
3. 비밀번호 암호화 (BCrypt)
4. 사용자 엔티티 생성 및 저장
5. JWT 토큰 발급 (Access Token, Refresh Token)
6. Refresh Token을 Redis에 저장

**에러 케이스**:
- `EMAIL_ALREADY_EXISTS`: 이미 사용 중인 이메일
- `NICKNAME_ALREADY_EXISTS`: 이미 사용 중인 닉네임
- `INVALID_INPUT`: 요청 데이터 검증 실패

---

### 3.2 Read - 사용자 정보 조회

**엔드포인트**: `GET /api/auth/me`

**인증**: Bearer Token 필요

**응답** (`UserResponse`):
```json
{
  "success": true,
  "message": "사용자 정보 조회 성공",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "nickname": "user123",
    "phoneNumber": "010-1234-5678",
    "profileImageUrl": "https://example.com/profile.jpg",
    "loginType": "EMAIL",
    "createdAt": "2026-02-12T10:00:00",
    "updatedAt": "2026-02-12T15:30:00"
  }
}
```

**비즈니스 로직**:
1. JWT 토큰에서 사용자 ID 추출
2. 데이터베이스에서 사용자 정보 조회
3. 사용자 정보 반환

**에러 케이스**:
- `USER_NOT_FOUND`: 사용자를 찾을 수 없음
- `UNAUTHORIZED`: 인증 토큰이 없거나 유효하지 않음

---

### 3.3 Update - 프로필 수정

**엔드포인트**: `PUT /api/users/me`

**인증**: Bearer Token 필요

**요청 본문** (`UpdateProfileRequest`):
```json
{
  "nickname": "newNickname",
  "phoneNumber": "010-9876-5432",
  "profileImageUrl": "https://example.com/new-profile.jpg"
}
```

**요청 검증**:
- `nickname`: 선택, 2-20자 사이 (변경 시 중복 체크)
- `phoneNumber`: 선택, 형식 `010-XXXX-XXXX`
- `profileImageUrl`: 선택, 최대 500자

**응답** (`UserResponse`):
```json
{
  "success": true,
  "message": "프로필이 성공적으로 수정되었습니다.",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "nickname": "newNickname",
    "phoneNumber": "010-9876-5432",
    "profileImageUrl": "https://example.com/new-profile.jpg",
    "loginType": "EMAIL",
    "createdAt": "2026-02-12T10:00:00",
    "updatedAt": "2026-02-12T16:00:00"
  }
}
```

**비즈니스 로직**:
1. 사용자 정보 조회
2. 닉네임 변경 시 중복 체크 (기존 닉네임과 다를 경우만)
3. 요청된 필드만 업데이트 (부분 업데이트 지원)
4. 업데이트된 사용자 정보 반환

**에러 케이스**:
- `USER_NOT_FOUND`: 사용자를 찾을 수 없음
- `NICKNAME_ALREADY_EXISTS`: 이미 사용 중인 닉네임
- `INVALID_INPUT`: 요청 데이터 검증 실패

---

### 3.4 Update - 비밀번호 변경

**엔드포인트**: `PUT /api/users/me/password`

**인증**: Bearer Token 필요

**요청 본문** (`UpdatePasswordRequest`):
```json
{
  "currentPassword": "OldPassword123!",
  "newPassword": "NewPassword456!"
}
```

**요청 검증**:
- `currentPassword`: 필수
- `newPassword`: 필수, 8자 이상, 영문/숫자/특수문자 포함

**응답**:
```json
{
  "success": true,
  "message": "비밀번호가 성공적으로 변경되었습니다.",
  "data": null
}
```

**비즈니스 로직**:
1. 사용자 정보 조회
2. 구글 로그인 사용자 확인 (구글 로그인 사용자는 비밀번호 변경 불가)
3. 현재 비밀번호 확인
4. 새 비밀번호 암호화 및 저장

**에러 케이스**:
- `USER_NOT_FOUND`: 사용자를 찾을 수 없음
- `SOCIAL_LOGIN_USER_ACCESS_DENIED`: 구글 로그인 사용자는 비밀번호 변경 불가
- `INVALID_CURRENT_PASSWORD`: 현재 비밀번호가 일치하지 않음
- `INVALID_INPUT`: 요청 데이터 검증 실패

---

### 3.5 Delete - 회원 탈퇴

**엔드포인트**: `DELETE /api/users/me`

**인증**: Bearer Token 필요

**응답**:
```json
{
  "success": true,
  "message": "회원 탈퇴가 성공적으로 처리되었습니다.",
  "data": null
}
```

**비즈니스 로직**:
1. 사용자 정보 조회
2. 소프트 삭제 처리 (`deletedAt` 필드에 현재 시간 저장)
3. Redis에 저장된 Refresh Token 삭제
4. 사용자 엔티티 저장

**에러 케이스**:
- `USER_NOT_FOUND`: 사용자를 찾을 수 없음

**참고**: 
- 하드 삭제가 아닌 소프트 삭제를 사용하여 데이터 무결성 유지
- 탈퇴 후에도 데이터는 보존되지만 로그인 불가능

---

### 3.6 추가 기능

#### 3.6.1 이메일 중복 체크

**엔드포인트**: `GET /api/auth/check-email?email=user@example.com`

**응답**:
```json
{
  "success": true,
  "message": "사용 가능한 이메일입니다.",
  "data": {
    "available": true,
    "email": "user@example.com"
  }
}
```

#### 3.6.2 닉네임 중복 체크

**엔드포인트**: `GET /api/auth/check-nickname?nickname=user123`

**응답**:
```json
{
  "success": true,
  "message": "사용 가능한 닉네임입니다.",
  "data": {
    "available": true,
    "nickname": "user123"
  }
}
```

---

## 4. 데이터 모델

### 4.1 User 엔티티

```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
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
    private LoginType loginType;  // EMAIL, GOOGLE
    
    @Column(name = "google_id", unique = true)
    private String googleId;
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;
    
    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;  // 소프트 삭제용
}
```

### 4.2 DTO 구조

#### Request DTOs
- `SignupRequest`: 회원가입 요청
- `UpdateProfileRequest`: 프로필 수정 요청
- `UpdatePasswordRequest`: 비밀번호 변경 요청

#### Response DTOs
- `UserResponse`: 사용자 정보 응답
- `AuthResponse`: 인증 응답 (토큰 + 사용자 정보)
- `ApiResponse<T>`: 공통 API 응답 래퍼

---

## 5. 보안 및 인증

### 5.1 인증 방식

- **JWT (JSON Web Token)** 기반 인증
- **Access Token**: 짧은 수명 (기본 1시간)
- **Refresh Token**: 긴 수명 (기본 7일), Redis에 저장

### 5.2 보안 기능

1. **비밀번호 암호화**: BCrypt 사용
2. **소셜 로그인 지원**: Google OAuth2
3. **소프트 삭제**: 데이터 무결성 유지
4. **토큰 무효화**: 로그아웃 및 탈퇴 시 Refresh Token 삭제

### 5.3 인증이 필요한 엔드포인트

모든 `/api/users/*` 엔드포인트와 `/api/auth/me` 엔드포인트는 Bearer Token 인증이 필요합니다.

---

## 6. 에러 처리

### 6.1 공통 에러 응답 형식

```json
{
  "success": false,
  "message": "에러 메시지",
  "data": null,
  "error": {
    "code": "ERROR_CODE",
    "details": "상세 에러 정보"
  }
}
```

### 6.2 주요 에러 코드

| 에러 코드 | HTTP Status | 설명 |
|----------|-------------|------|
| `USER_NOT_FOUND` | 404 | 사용자를 찾을 수 없음 |
| `EMAIL_ALREADY_EXISTS` | 409 | 이미 사용 중인 이메일 |
| `NICKNAME_ALREADY_EXISTS` | 409 | 이미 사용 중인 닉네임 |
| `INVALID_CURRENT_PASSWORD` | 400 | 현재 비밀번호가 일치하지 않음 |
| `SOCIAL_LOGIN_USER_ACCESS_DENIED` | 403 | 소셜 로그인 사용자는 해당 기능 사용 불가 |
| `INVALID_INPUT` | 400 | 요청 데이터 검증 실패 |
| `UNAUTHORIZED` | 401 | 인증 토큰이 없거나 유효하지 않음 |

---

## 7. 구현 파일 구조

```
backend/src/main/java/com/pnu/basketball/
├── controller/
│   └── auth/
│       ├── AuthController.java          # 인증 및 회원가입
│       └── UserController.java          # 사용자 관리 (프로필, 비밀번호, 탈퇴)
├── service/
│   ├── auth/
│   │   ├── AuthService.java
│   │   └── AuthServiceImpl.java
│   └── user/
│       ├── UserService.java
│       └── UserServiceImpl.java
├── domain/
│   └── User.java                        # User 엔티티
├── repository/
│   └── UserRepository.java              # JPA Repository
├── dto/
│   ├── request/
│   │   ├── SignupRequest.java
│   │   ├── UpdateProfileRequest.java
│   │   └── UpdatePasswordRequest.java
│   └── response/
│       ├── UserResponse.java
│       └── AuthResponse.java
└── exception/
    ├── CustomException.java
    ├── ErrorCode.java
    └── GlobalExceptionHandler.java
```

---

## 8. 테스트 가이드

### 8.1 회원가입 테스트

```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!@#",
    "nickname": "testuser",
    "phoneNumber": "010-1234-5678"
  }'
```

### 8.2 사용자 정보 조회 테스트

```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer {access_token}"
```

### 8.3 프로필 수정 테스트

```bash
curl -X PUT http://localhost:8080/api/users/me \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "nickname": "newnickname",
    "phoneNumber": "010-9876-5432"
  }'
```

### 8.4 비밀번호 변경 테스트

```bash
curl -X PUT http://localhost:8080/api/users/me/password \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "currentPassword": "OldPassword123!",
    "newPassword": "NewPassword456!"
  }'
```

### 8.5 회원 탈퇴 테스트

```bash
curl -X DELETE http://localhost:8080/api/users/me \
  -H "Authorization: Bearer {access_token}"
```

### 8.6 이메일 중복 체크 테스트

```bash
curl -X GET "http://localhost:8080/api/auth/check-email?email=test@example.com"
```

### 8.7 닉네임 중복 체크 테스트

```bash
curl -X GET "http://localhost:8080/api/auth/check-nickname?nickname=testuser"
```

---

## 9. API 문서

Swagger UI를 통해 API 문서를 확인할 수 있습니다:

- **URL**: `http://localhost:8080/swagger-ui.html`
- 모든 엔드포인트의 상세한 설명, 요청/응답 예시, 스키마 정보 제공

---

## 10. 향후 개선 사항

1. **프로필 이미지 업로드**: 현재는 URL만 받지만, 파일 업로드 기능 추가 예정
2. **사용자 검색**: 닉네임으로 사용자 검색 기능
3. **활동 내역**: 사용자 활동 로그 및 통계
4. **알림 설정**: 사용자별 알림 설정 관리
5. **차단 기능**: 다른 사용자 차단 기능

---

## 11. 참고 자료

- [Spring Boot 공식 문서](https://spring.io/projects/spring-boot)
- [Spring Security 공식 문서](https://spring.io/projects/spring-security)
- [JWT 공식 문서](https://jwt.io/)
- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)

---

**문서 버전**: 1.0  
**최종 수정일**: 2026-02-12
