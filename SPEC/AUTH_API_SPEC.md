# 🔐 인증 API 명세서 (Authentication API Specification)

> **딸바 (PNU Basketball Platform)** 인증 관련 REST API 명세서  
> **버전**: 1.0.0  
> **최종 수정일**: 2026-01

---

## 📋 목차

1. [개요](#개요)
2. [공통 사항](#공통-사항)
3. [자체 로그인 API](#자체-로그인-api)
4. [구글 로그인 API](#구글-로그인-api)
5. [토큰 관리 API](#토큰-관리-api)
6. [에러 응답](#에러-응답)
7. [데이터 모델](#데이터-모델)

---

## 🎯 개요

### 인증 방식
- **자체 로그인**: 이메일/비밀번호 기반 JWT 인증
- **구글 로그인**: OAuth2.0 기반 소셜 로그인 (Google Sign-In)

### 보안 정책
- **JWT 토큰**: Access Token + Refresh Token 방식
- **토큰 만료 시간**:
  - Access Token: 1시간
  - Refresh Token: 7일
- **비밀번호 암호화**: BCrypt (Spring Security 기본)
- **토큰 저장**: Redis (Refresh Token)

---

## 📌 공통 사항

### Base URL
```
개발 환경: http://localhost:8080
운영 환경: https://api.basketball.pnu.ac.kr
```

### 공통 헤더
```http
Content-Type: application/json
Accept: application/json
```

### 인증 헤더 (보호된 리소스)
```http
Authorization: Bearer {access_token}
```

### 공통 응답 형식
모든 API는 다음 형식을 따릅니다:

**성공 응답 (200 OK)**
```json
{
  "success": true,
  "data": { ... },
  "message": "성공 메시지"
}
```

**에러 응답 (4xx, 5xx)**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": { ... }
  }
}
```

---

## 🔑 자체 로그인 API

### 1. 회원가입

**엔드포인트**: `POST /api/auth/signup`

**설명**: 이메일과 비밀번호로 새 계정을 생성합니다.

**인증 필요**: ❌

**요청 본문**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "nickname": "농구왕",
  "phoneNumber": "010-1234-5678"
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 | 제약 조건 |
|------|------|------|------|----------|
| `email` | string | ✅ | 사용자 이메일 | 이메일 형식, 중복 불가 |
| `password` | string | ✅ | 비밀번호 | 8자 이상, 영문/숫자/특수문자 포함 |
| `nickname` | string | ✅ | 닉네임 | 2-20자, 중복 불가 |
| `phoneNumber` | string | ❌ | 전화번호 | 010-XXXX-XXXX 형식 |

**성공 응답 (201 Created)**:
```json
{
  "success": true,
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "nickname": "농구왕",
    "createdAt": "2026-01-15T10:30:00"
  },
  "message": "회원가입이 완료되었습니다."
}
```

**에러 응답**:
- `400 Bad Request`: 유효하지 않은 입력값
- `409 Conflict`: 이메일 또는 닉네임 중복

---

### 2. 로그인

**엔드포인트**: `POST /api/auth/login`

**설명**: 이메일과 비밀번호로 로그인하고 JWT 토큰을 발급받습니다.

**인증 필요**: ❌

**요청 본문**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `email` | string | ✅ | 사용자 이메일 |
| `password` | string | ✅ | 비밀번호 |

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "userId": 1,
      "email": "user@example.com",
      "nickname": "농구왕",
      "profileImageUrl": null,
      "loginType": "EMAIL"
    }
  },
  "message": "로그인 성공"
}
```

**응답 필드**:
| 필드 | 타입 | 설명 |
|------|------|------|
| `accessToken` | string | JWT Access Token (1시간 유효) |
| `refreshToken` | string | JWT Refresh Token (7일 유효) |
| `tokenType` | string | 토큰 타입 (항상 "Bearer") |
| `expiresIn` | number | Access Token 만료 시간 (초) |
| `user` | object | 사용자 정보 |

**에러 응답**:
- `400 Bad Request`: 이메일 또는 비밀번호 형식 오류
- `401 Unauthorized`: 이메일 또는 비밀번호 불일치
- `404 Not Found`: 존재하지 않는 사용자

---

### 3. 이메일 중복 확인

**엔드포인트**: `GET /api/auth/check-email?email={email}`

**설명**: 회원가입 전 이메일 중복 여부를 확인합니다.

**인증 필요**: ❌

**쿼리 파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `email` | string | ✅ | 확인할 이메일 |

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "available": true,
    "email": "user@example.com"
  },
  "message": "사용 가능한 이메일입니다."
}
```

**에러 응답**:
- `400 Bad Request`: 유효하지 않은 이메일 형식
- `409 Conflict`: 이미 사용 중인 이메일

---

### 4. 닉네임 중복 확인

**엔드포인트**: `GET /api/auth/check-nickname?nickname={nickname}`

**설명**: 회원가입 전 닉네임 중복 여부를 확인합니다.

**인증 필요**: ❌

**쿼리 파라미터**:
| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `nickname` | string | ✅ | 확인할 닉네임 |

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "available": true,
    "nickname": "농구왕"
  },
  "message": "사용 가능한 닉네임입니다."
}
```

---

## 🌐 구글 로그인 API

### 1. 구글 로그인 (토큰 검증 및 사용자 생성/조회)

**엔드포인트**: `POST /api/auth/google`

**설명**: Google OAuth2.0 ID Token을 검증하고, 사용자가 없으면 자동 회원가입 후 JWT 토큰을 발급합니다.

**인증 필요**: ❌

**요청 본문**:
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij..."
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `idToken` | string | ✅ | Google OAuth2.0 ID Token |

**처리 흐름**:
1. Google ID Token 검증
2. Google 사용자 정보 추출 (이메일, 이름, 프로필 이미지)
3. DB에서 이메일로 사용자 조회
   - 존재하지 않으면: 자동 회원가입 (구글 로그인 타입으로 저장)
   - 존재하면: 기존 사용자 정보 반환
4. JWT 토큰 발급 및 반환

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "userId": 2,
      "email": "google.user@gmail.com",
      "nickname": "구글사용자",
      "profileImageUrl": "https://lh3.googleusercontent.com/...",
      "loginType": "GOOGLE",
      "isNewUser": true
    }
  },
  "message": "구글 로그인 성공"
}
```

**응답 필드**:
| 필드 | 타입 | 설명 |
|------|------|------|
| `isNewUser` | boolean | 신규 가입 여부 (true: 신규, false: 기존) |

**에러 응답**:
- `400 Bad Request`: 유효하지 않은 ID Token
- `401 Unauthorized`: Google 토큰 검증 실패
- `500 Internal Server Error`: Google API 통신 오류

---

### 2. 구글 로그인 URL 조회 (선택사항)

**엔드포인트**: `GET /api/auth/google/url`

**설명**: 프론트엔드에서 구글 로그인 URL을 가져옵니다. (서버 사이드 OAuth 흐름 사용 시)

**인증 필요**: ❌

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "authUrl": "https://accounts.google.com/o/oauth2/v2/auth?client_id=...&redirect_uri=...&response_type=code&scope=openid%20email%20profile"
  },
  "message": "구글 로그인 URL"
}
```

**참고**: Flutter에서는 `google_sign_in` 패키지를 사용하여 클라이언트 사이드에서 직접 처리하는 것을 권장합니다.

---

## 🔄 토큰 관리 API

### 1. 토큰 갱신 (Refresh Token)

**엔드포인트**: `POST /api/auth/refresh`

**설명**: Refresh Token을 사용하여 새로운 Access Token을 발급받습니다.

**인증 필요**: ❌ (Refresh Token 필요)

**요청 본문**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `refreshToken` | string | ✅ | Refresh Token |

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600
  },
  "message": "토큰 갱신 성공"
}
```

**에러 응답**:
- `400 Bad Request`: Refresh Token 누락
- `401 Unauthorized`: 유효하지 않거나 만료된 Refresh Token

---

### 2. 로그아웃

**엔드포인트**: `POST /api/auth/logout`

**설명**: Refresh Token을 무효화하고 로그아웃합니다.

**인증 필요**: ✅ (Access Token 필요)

**요청 본문**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": null,
  "message": "로그아웃되었습니다."
}
```

**에러 응답**:
- `401 Unauthorized`: 유효하지 않은 Access Token

---

### 3. 현재 사용자 정보 조회

**엔드포인트**: `GET /api/auth/me`

**설명**: 현재 로그인한 사용자의 정보를 조회합니다.

**인증 필요**: ✅ (Access Token 필요)

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "nickname": "농구왕",
    "phoneNumber": "010-1234-5678",
    "profileImageUrl": null,
    "loginType": "EMAIL",
    "createdAt": "2026-01-15T10:30:00",
    "updatedAt": "2026-01-15T10:30:00"
  },
  "message": "사용자 정보 조회 성공"
}
```

**에러 응답**:
- `401 Unauthorized`: 유효하지 않은 Access Token

---

## ⚠️ 에러 응답

### 에러 코드 목록

| HTTP 상태 코드 | 에러 코드 | 설명 |
|---------------|----------|------|
| 400 | `INVALID_INPUT` | 유효하지 않은 입력값 |
| 400 | `INVALID_EMAIL_FORMAT` | 이메일 형식 오류 |
| 400 | `INVALID_PASSWORD_FORMAT` | 비밀번호 형식 오류 |
| 400 | `INVALID_TOKEN` | 유효하지 않은 토큰 |
| 401 | `UNAUTHORIZED` | 인증 실패 |
| 401 | `INVALID_CREDENTIALS` | 이메일 또는 비밀번호 불일치 |
| 401 | `TOKEN_EXPIRED` | 토큰 만료 |
| 401 | `GOOGLE_TOKEN_INVALID` | 구글 토큰 검증 실패 |
| 404 | `USER_NOT_FOUND` | 사용자를 찾을 수 없음 |
| 409 | `EMAIL_ALREADY_EXISTS` | 이미 존재하는 이메일 |
| 409 | `NICKNAME_ALREADY_EXISTS` | 이미 존재하는 닉네임 |
| 500 | `INTERNAL_SERVER_ERROR` | 서버 내부 오류 |
| 500 | `GOOGLE_API_ERROR` | 구글 API 통신 오류 |

### 에러 응답 예시

```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "이메일 또는 비밀번호가 일치하지 않습니다.",
    "details": {
      "field": "password",
      "reason": "비밀번호가 일치하지 않습니다."
    }
  }
}
```

---

## 📊 데이터 모델

### User Entity

```json
{
  "userId": 1,
  "email": "user@example.com",
  "password": "$2a$10$...",  // 암호화된 비밀번호 (자체 로그인만)
  "nickname": "농구왕",
  "phoneNumber": "010-1234-5678",
  "profileImageUrl": "https://...",
  "loginType": "EMAIL",  // EMAIL, GOOGLE
  "googleId": null,  // 구글 로그인 시 Google User ID
  "createdAt": "2026-01-15T10:30:00",
  "updatedAt": "2026-01-15T10:30:00"
}
```

### JWT Token Payload (Access Token)

```json
{
  "sub": "1",  // userId
  "email": "user@example.com",
  "nickname": "농구왕",
  "loginType": "EMAIL",
  "iat": 1705296000,  // 발급 시간
  "exp": 1705299600   // 만료 시간
}
```

### JWT Token Payload (Refresh Token)

```json
{
  "sub": "1",  // userId
  "tokenType": "REFRESH",
  "iat": 1705296000,
  "exp": 1705900800  // 7일 후
}
```

---

## 🔒 보안 고려사항

### 1. 비밀번호 정책
- 최소 8자 이상
- 영문 대소문자, 숫자, 특수문자 중 2가지 이상 포함
- 일반적인 비밀번호 (123456, password 등) 차단

### 2. 토큰 보안
- Access Token은 클라이언트 메모리에만 저장 (Flutter: `flutter_secure_storage`)
- Refresh Token은 서버(Redis)에 저장하여 탈취 시 무효화 가능
- HTTPS 통신 필수 (운영 환경)

### 3. Rate Limiting
- 로그인 시도: IP당 5회/분
- 회원가입: IP당 3회/시간
- 토큰 갱신: 사용자당 10회/시간

### 4. CORS 설정
- 개발 환경: `http://localhost:*` 허용
- 운영 환경: 특정 도메인만 허용

---

## 📝 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| 1.0.0 | 2026-01 | 초기 API 명세서 작성 | 팀 |

---

**문서 작성일**: 2026년 1월  
**최종 수정일**: 2026년 1월  
**작성자**: 딸바 개발팀

