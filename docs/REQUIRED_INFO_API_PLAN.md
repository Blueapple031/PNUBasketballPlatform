# 📋 필수정보입력 API 구현 계획서

> **넉터(NUKTU)** 기본 로그인 및 구글 로그인 후 필수정보입력 API 구현 계획서
> **버전**: 1.0.0  
> **작성일**: 2026-03

---

## 📋 목차

1. [개요](#개요)
2. [필수정보 정의](#필수정보-정의)
3. [휴대전화 인증](#휴대전화-인증)
4. [API 설계](#api-설계)
5. [Backend 구현 계획](#backend-구현-계획)
6. [Frontend 구현 계획](#frontend-구현-계획)
7. [인증 플로우 통합](#인증-플로우-통합)
8. [향후 개선: 알림 기능](#향후-개선-알림-기능)
9. [작업 일정](#작업-일정)
10. [테스트 계획](#테스트-계획)

---

## 🎯 개요

### 배경 및 목적

- **기본 로그인(이메일/비밀번호)**: 회원가입 시 본명·전화번호를 입력하지만, 전화번호는 선택사항이라 미입력 가능
- **구글 로그인**: 신규 사용자는 이메일·프로필 이미지만 저장되고, **본명·전화번호가 누락**됨
- **농구 매칭 서비스 특성**: 번개 매칭 시 팀원 연락이 필요하므로 **전화번호**를 필수로 요구

본 계획서는 로그인(기본/구글) 직후 **필수정보 미입력 사용자**를 식별하고, **필수정보 입력 API**를 통해 정보를 수집·저장하는 기능을 구현하기 위한 것이다.

### 목표

1. 로그인 응답에 **필수정보 입력 필요 여부** 플래그 포함
2. **필수정보 입력 여부 조회 API** 제공
3. **필수정보 제출 API** 제공 (본명, 전화번호 입력 등)
4. **휴대전화 인증 API** 제공 (SMS 인증번호 발송/검증)
5. 프론트엔드에서 로그인 후 필수정보 미입력 시 **필수정보 입력 화면**으로 유도
6. 향후 **알림 기능** 구현을 위한 기반 마련 (인증된 전화번호, FCM 토큰 설계)


### 범위

| 항목 | 포함 | 비고 |
|------|------|------|
| 필수정보 입력 여부 조회 API | ✅ | `GET /api/auth/required-info/status` |
| 필수정보 제출 API | ✅ | `POST /api/auth/required-info` |
| **휴대전화 인증 API** | ✅ | SMS 인증번호 발송/검증 |
| AuthResponse에 `needsRequiredInfo` 추가 | ✅ | 로그인/구글 로그인 응답 |
| 필수정보 입력 화면 (Flutter) | ✅ | 로그인 후 분기 |
| 기존 `PUT /api/users/me` 활용 | ✅ | 중복 최소화 |
| **알림 기능** | 📅 | 향후 구현 (본 계획서에 설계 포함) |

---

## 📌 필수정보 정의

### 필수정보 항목

| 항목 | 필수 여부 | 설명 | 제약 조건 |
|------|----------|------|------------|
| `realName` | ✅ | 본명(실명) | 2~50자, 필수 (동명이인 허용) |
| `phoneNumber` | ✅ | 전화번호 | `010-XXXX-XXXX` 형식 |
| `phoneNumberVerified` | ✅ | 휴대전화 인증 완료 여부 | SMS 인증번호 검증 통과 시 true |

- **본명(실명)**: 구글 로그인 시 미입력. 자체 로그인은 회원가입 시 이미 입력됨. 필수정보 입력 단계에서 수집.
- **전화번호**: 매칭 시 연락용으로 **반드시 필요**. 자체/구글 모두 미입력 가능하므로, 필수정보 입력 단계에서 수집.
- **휴대전화 인증**: 전화번호 입력 후 SMS 인증번호로 본인 확인. 인증 완료된 번호만 저장.

### 필수정보 완료 조건

```
필수정보 완료 = (realName != null && realName.length >= 2) 
            && (phoneNumber != null && phoneNumber.matches("010-\\d{4}-\\d{4}"))
            && phoneNumberVerified == true
```

---

## 📱 휴대전화 인증

### 개요

전화번호 입력 시 **SMS 인증번호**를 통해 본인 소유 번호임을 확인한다. 인증 완료된 번호만 저장하여, 스팸·허위 번호 등록을 방지하고 향후 **알림 발송**의 신뢰도를 높인다.

### 인증 플로우

```
1. 사용자가 전화번호 입력 (010-XXXX-XXXX)
2. POST /api/auth/phone/send-code → SMS 인증번호 발송
3. 사용자가 인증번호 입력 (6자리)
4. POST /api/auth/phone/verify-code → 인증번호 검증
5. 검증 성공 시 → POST /api/auth/required-info에 phoneNumber + phoneVerified=true 포함하여 제출
```

### 필수 구현 사항

| 항목 | 설명 |
|------|------|
| SMS 발송 API | CoolSMS, NHN Cloud, AWS SNS 등 외부 연동 |
| 인증번호 | 6자리 숫자, 5분 유효 |
| Redis/메모리 저장 | `phone_verify:{phoneNumber}` → `{code, expiresAt}` |
| 재발송 제한 | 동일 번호 1분당 1회 |

### User 엔티티 확장

- `phone_number_verified_at` (TIMESTAMP, nullable): 인증 완료 시각. null이면 미인증.

---

## 🔧 API 설계

### 1. 필수정보 입력 필요 여부 조회

**엔드포인트**: `GET /api/auth/required-info/status`

**설명**: 현재 로그인한 사용자의 필수정보 입력 완료 여부를 반환한다.

**인증 필요**: ✅ (Access Token)

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "completed": false,
    "missingFields": ["phoneNumberVerified"],
    "user": {
      "userId": 1,
      "email": "user@example.com",
      "realName": "홍길동",
      "phoneNumber": null,
      "phoneNumberVerified": false,
      "profileImageUrl": null,
      "loginType": "GOOGLE"
    }
  },
  "message": "필수정보 입력 상태 조회 성공"
}
```

**응답 필드**:
| 필드 | 타입 | 설명 |
|------|------|------|
| `completed` | boolean | 필수정보 입력 완료 여부 |
| `missingFields` | string[] | 미완료 항목 (예: `["phoneNumberVerified"]`, `["realName","phoneNumberVerified"]`) |
| `user` | object | 현재 사용자 정보 (일부), `phoneNumberVerified` 포함 |

**에러 응답**:
- `401 Unauthorized`: 유효하지 않은 Access Token

---

### 2. 필수정보 제출

**엔드포인트**: `POST /api/auth/required-info`

**설명**: 필수정보(본명, 전화번호)를 입력·수정한다. **전화번호는 반드시 휴대전화 인증 완료 후** 제출해야 한다. (인증 플로우: `send-code` → `verify-code` → 본 API)

**인증 필요**: ✅ (Access Token)

**요청 본문**:
```json
{
  "realName": "홍길동",
  "phoneNumber": "010-1234-5678"
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 | 제약 조건 |
|------|------|------|------|----------|
| `realName` | string | ❌* | 본명(실명) | 2~50자, 필수 (*필수정보 미완료 시 필수) |
| `phoneNumber` | string | ❌* | 전화번호 | `010-XXXX-XXXX` (*필수정보 미완료 시 필수, **휴대전화 인증 완료 필수**) |

- 최소 1개 이상 필드 필요
- `completed`가 되려면 `realName`과 `phoneNumber`(인증 완료) 모두 유효해야 함
- `phoneNumber` 제출 시, 해당 번호가 `verify-code` API로 최근(예: 10분 이내) 인증되었어야 함

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "realName": "홍길동",
    "phoneNumber": "010-1234-5678",
    "profileImageUrl": null,
    "loginType": "GOOGLE",
    "requiredInfoCompleted": true
  },
  "message": "필수정보가 성공적으로 저장되었습니다."
}
```

**응답 필드**:
| 필드 | 타입 | 설명 |
|------|------|------|
| `requiredInfoCompleted` | boolean | 이번 요청으로 필수정보가 완료되었는지 여부 |

**에러 응답**:
- `400 Bad Request`: 유효하지 않은 입력값
- `401 Unauthorized`: 유효하지 않은 Access Token
- `409 Conflict`: (본명은 중복 허용으로 해당 없음, 기타 충돌 시)

---

### 3. 휴대전화 인증번호 발송

**엔드포인트**: `POST /api/auth/phone/send-code`

**설명**: 입력된 전화번호로 SMS 인증번호를 발송한다.

**인증 필요**: ✅ (Access Token)

**요청 본문**:
```json
{
  "phoneNumber": "010-1234-5678"
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `phoneNumber` | string | ✅ | `010-XXXX-XXXX` 형식 |

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "expiresIn": 300
  },
  "message": "인증번호가 발송되었습니다."
}
```

**응답 필드**:
| 필드 | 타입 | 설명 |
|------|------|------|
| `expiresIn` | number | 인증번호 유효 시간(초), 기본 300(5분) |

**에러 응답**:
- `400 Bad Request`: 유효하지 않은 전화번호 형식
- `429 Too Many Requests`: 재발송 제한 (1분당 1회)

---

### 4. 휴대전화 인증번호 검증

**엔드포인트**: `POST /api/auth/phone/verify-code`

**설명**: 입력된 인증번호를 검증한다. 검증 성공 시 해당 세션에서 `phoneVerified` 상태가 true로 설정되며, 이후 `POST /api/auth/required-info` 제출 시 전화번호가 인증됨으로 저장된다.

**인증 필요**: ✅ (Access Token)

**요청 본문**:
```json
{
  "phoneNumber": "010-1234-5678",
  "code": "123456"
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `phoneNumber` | string | ✅ | 발송 시 사용한 전화번호 |
| `code` | string | ✅ | 6자리 인증번호 |

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "verified": true,
    "phoneNumber": "010-1234-5678"
  },
  "message": "휴대전화 인증이 완료되었습니다."
}
```

**에러 응답**:
- `400 Bad Request`: 유효하지 않은 인증번호
- `401 Unauthorized`: 인증번호 불일치 또는 만료

---

### 5. AuthResponse 확장 (로그인/구글 로그인 응답)

기존 `AuthResponse`의 `UserInfo`에 다음 필드를 추가한다.

| 필드 | 타입 | 설명 |
|------|------|------|
| `needsRequiredInfo` | boolean | 필수정보 입력이 필요한지 여부 |

**수정된 AuthResponse.UserInfo 예시**:
```json
{
  "userId": 1,
  "email": "user@example.com",
  "realName": "구글사용자",
  "profileImageUrl": "https://...",
  "loginType": "GOOGLE",
  "isNewUser": true,
  "needsRequiredInfo": true
}
```

- `needsRequiredInfo == true` → 로그인 직후 필수정보 입력 화면으로 이동
- `needsRequiredInfo == false` → 메인 화면으로 이동

---

## 🔧 Backend 구현 계획

### 1단계: DTO 생성

#### 신규 파일

| 파일 | 설명 |
|------|------|
| `RequiredInfoStatusResponse.java` | `GET /api/auth/required-info/status` 응답 DTO |
| `RequiredInfoRequest.java` | `POST /api/auth/required-info` 요청 DTO |
| `RequiredInfoResponse.java` | `POST /api/auth/required-info` 응답 DTO |
| `PhoneSendCodeRequest.java` | `POST /api/auth/phone/send-code` 요청 DTO |
| `PhoneVerifyCodeRequest.java` | `POST /api/auth/phone/verify-code` 요청 DTO |
| `PhoneVerifyResponse.java` | `POST /api/auth/phone/verify-code` 응답 DTO |

#### 수정 파일

| 파일 | 수정 내용 |
|------|----------|
| `AuthResponse.UserInfo` | `needsRequiredInfo` 필드 추가 |
| `User.java` | `phoneNumberVerifiedAt` 필드 추가 |
| `UserResponse.java` | `phoneNumberVerified` 필드 추가 |

#### DTO 예시

**`RequiredInfoRequest.java`**:
```java
@Getter
@NoArgsConstructor
public class RequiredInfoRequest {
    @Size(min = 2, max = 50, message = "본명은 2-50자 사이여야 합니다.")
    private String realName;
    
    @Pattern(regexp = "^010-\\d{4}-\\d{4}$", message = "전화번호 형식이 올바르지 않습니다.")
    private String phoneNumber;
}
```

**`RequiredInfoStatusResponse.java`**:
```java
@Getter
@Builder
public class RequiredInfoStatusResponse {
    private boolean completed;
    private List<String> missingFields;
    private UserResponse user;
}
```

---

### 2단계: 서비스 계층

#### 신규/수정 파일

| 파일 | 작업 |
|------|------|
| `RequiredInfoService.java` | 인터페이스 신규 |
| `RequiredInfoServiceImpl.java` | 구현체 신규 |
| `PhoneVerificationService.java` | 인터페이스 신규 |
| `PhoneVerificationServiceImpl.java` | 구현체 신규 (SMS API 연동, Redis) |
| `AuthServiceImpl.java` | `generateAuthResponse`에서 `needsRequiredInfo` 계산 후 설정 |
| `GoogleAuthServiceImpl.java` | 동일 |

#### RequiredInfoService 인터페이스

```java
public interface RequiredInfoService {
    RequiredInfoStatusResponse getStatus(Long userId);
    RequiredInfoResponse submit(Long userId, RequiredInfoRequest request);
    boolean isRequiredInfoCompleted(User user);
}
```

**submit() 로직**:
- `realName`: 2~50자 검증 (필수)
- `phoneNumber` 제출 시: `PhoneVerificationService.isVerified(userId, phoneNumber)`로 Redis에서 인증 여부 확인
- 미인증 시 `CustomException(ErrorCode.PHONE_NOT_VERIFIED)` 발생

#### `isRequiredInfoCompleted` 로직

```java
public boolean isRequiredInfoCompleted(User user) {
    if (user.getRealName() == null || user.getRealName().length() < 2) {
        return false;
    }
    if (user.getPhoneNumber() == null || !user.getPhoneNumber().matches("^010-\\d{4}-\\d{4}$")) {
        return false;
    }
    if (user.getPhoneNumberVerifiedAt() == null) {
        return false;  // 휴대전화 인증 미완료
    }
    return true;
}
```

---

### 3단계: 컨트롤러

#### AuthController에 엔드포인트 추가

```java
@GetMapping("/required-info/status")
public ResponseEntity<ApiResponse<RequiredInfoStatusResponse>> getRequiredInfoStatus(
        @AuthenticationPrincipal Long userId) {
    RequiredInfoStatusResponse response = requiredInfoService.getStatus(userId);
    return ResponseEntity.ok(ApiResponse.success(response, "필수정보 입력 상태 조회 성공"));
}

@PostMapping("/required-info")
public ResponseEntity<ApiResponse<RequiredInfoResponse>> submitRequiredInfo(
        @AuthenticationPrincipal Long userId,
        @Valid @RequestBody RequiredInfoRequest request) {
    RequiredInfoResponse response = requiredInfoService.submit(userId, request);
    return ResponseEntity.ok(ApiResponse.success(response, "필수정보가 성공적으로 저장되었습니다."));
}

// 휴대전화 인증
@PostMapping("/phone/send-code")
public ResponseEntity<ApiResponse<PhoneSendCodeResponse>> sendPhoneVerificationCode(
        @AuthenticationPrincipal Long userId,
        @Valid @RequestBody PhoneSendCodeRequest request) {
    PhoneSendCodeResponse response = phoneVerificationService.sendCode(userId, request.getPhoneNumber());
    return ResponseEntity.ok(ApiResponse.success(response, "인증번호가 발송되었습니다."));
}

@PostMapping("/phone/verify-code")
public ResponseEntity<ApiResponse<PhoneVerifyResponse>> verifyPhoneCode(
        @AuthenticationPrincipal Long userId,
        @Valid @RequestBody PhoneVerifyCodeRequest request) {
    PhoneVerifyResponse response = phoneVerificationService.verifyCode(userId, request.getPhoneNumber(), request.getCode());
    return ResponseEntity.ok(ApiResponse.success(response, "휴대전화 인증이 완료되었습니다."));
}
```

#### PhoneVerificationService (신규)

| 파일 | 작업 |
|------|------|
| `PhoneVerificationService.java` | 인터페이스 신규 |
| `PhoneVerificationServiceImpl.java` | 구현체 신규 (SMS 연동, Redis 저장) |

---

### 4단계: DB 마이그레이션

**`V3__add_phone_verified_at.sql`** (신규):
```sql
ALTER TABLE users ADD COLUMN phone_number_verified_at TIMESTAMP NULL;
COMMENT ON COLUMN users.phone_number_verified_at IS '휴대전화 인증 완료 시각';
```

### 5단계: AuthResponse 수정

`AuthResponse.UserInfo`에 `needsRequiredInfo` 추가:

```java
public static class UserInfo {
    private Long userId;
    private String email;
    private String realName;
    private String profileImageUrl;
    private LoginType loginType;
    private Boolean isNewUser;
    private Boolean needsRequiredInfo;  // 추가
}
```

`AuthServiceImpl`, `GoogleAuthServiceImpl`의 `generateAuthResponse` 호출 시 `RequiredInfoService.isRequiredInfoCompleted(user)` 결과를 `needsRequiredInfo`에 설정.

---

## 📱 Frontend 구현 계획

### 1단계: API 서비스 확장

| 파일 | 작업 |
|------|------|
| `auth_service.dart` | `getRequiredInfoStatus()`, `submitRequiredInfo()`, `sendPhoneCode()`, `verifyPhoneCode()` 메서드 추가 |

### 2단계: Repository 확장

| 파일 | 작업 |
|------|------|
| `auth_repository.dart` | `getRequiredInfoStatus()`, `submitRequiredInfo()`, `sendPhoneCode()`, `verifyPhoneCode()` 래핑 |

### 3단계: 모델 확장

| 파일 | 작업 |
|------|------|
| `auth_response_model.dart` | `UserInfo`에 `needsRequiredInfo` 필드 추가 |

### 4단계: 로그인 후 분기 로직

| 파일 | 작업 |
|------|------|
| `auth_provider.dart` | 로그인 성공 시 `needsRequiredInfo` 확인 |
| `login_screen.dart` | 로그인/구글 로그인 성공 시 `needsRequiredInfo`에 따라 화면 분기 |

**분기 흐름**:
```
로그인/구글 로그인 성공
    → needsRequiredInfo == true  → RequiredInfoScreen(필수정보 입력 화면)
    → needsRequiredInfo == false → MainScreen(메인 화면)
```

### 5단계: 필수정보 입력 화면

| 파일 | 작업 |
|------|------|
| `required_info_screen.dart` | 신규 생성 - 본명, 전화번호 입력 + 휴대전화 인증 UI |
| `required_info_provider.dart` | (선택) 상태 관리 |

**입력 흐름**:
1. 본명: 실명 입력 (2~50자)
2. 전화번호: `010-XXXX-XXXX` 형식 입력
3. "인증번호 받기" → `sendPhoneCode()` 호출
4. 6자리 인증번호 입력
5. "인증하기" → `verifyPhoneCode()` 호출
6. 인증 성공 시 "완료" 버튼 활성화
7. "완료" → `submitRequiredInfo()` 호출 후 메인 화면으로 이동

---

## 🔄 인증 플로우 통합

### 기본 로그인 플로우

```
1. POST /api/auth/login
2. 응답: AuthResponse { user: { needsRequiredInfo: true/false } }
3. needsRequiredInfo == true  → RequiredInfoScreen
4. needsRequiredInfo == false → MainScreen
5. (필수정보 화면) POST /api/auth/required-info → MainScreen
```

### 구글 로그인 플로우

```
1. POST /api/auth/google
2. 응답: AuthResponse { user: { isNewUser, needsRequiredInfo } }
3. needsRequiredInfo == true  → RequiredInfoScreen
4. needsRequiredInfo == false → MainScreen
5. (필수정보 화면) POST /api/auth/required-info → MainScreen
```

### 앱 재시작 시

```
1. Access Token 유효 시 → GET /api/auth/required-info/status
2. completed == false → RequiredInfoScreen
3. completed == true  → MainScreen
```

---

## 🔔 향후 개선: 알림 기능

### 개요

휴대전화 인증을 통해 수집한 전화번호와 FCM(Firebase Cloud Messaging) 토큰을 활용하여, **매칭 알림**, **채팅 알림**, **이벤트 알림** 등을 푸시로 발송하는 기능을 향후 구현할 예정이다.

### 예상 기능

| 기능 | 설명 | 우선순위 |
|------|------|----------|
| FCM 토큰 등록 | 앱 설치/로그인 시 디바이스 FCM 토큰 저장 | 높음 |
| 매칭 알림 | 번개 매칭 참여/승인 시 푸시 알림 | 높음 |
| 채팅 알림 | 새 메시지 수신 시 푸시 알림 | 중간 |
| SMS 알림 (선택) | 휴대전화 인증된 번호로 중요 알림 SMS 발송 | 낮음 |

### 예상 데이터 구조

**User 엔티티 확장**:
- `fcm_token` (VARCHAR, nullable): FCM 디바이스 토큰
- `fcm_token_updated_at` (TIMESTAMP, nullable): 토큰 최종 갱신 시각

**알림 설정 테이블 (선택)**:
- `notification_settings`: 사용자별 알림 on/off (매칭, 채팅, 이벤트 등)

### 예상 API (향후)

| API | 설명 |
|-----|------|
| `PUT /api/users/me/fcm-token` | FCM 토큰 등록/갱신 |
| `GET /api/users/me/notification-settings` | 알림 설정 조회 |
| `PUT /api/users/me/notification-settings` | 알림 설정 수정 |

### 의존성

- **Firebase Cloud Messaging** (Flutter: `firebase_messaging`)
- **백엔드**: FCM Admin SDK 또는 HTTP API로 푸시 발송
- 휴대전화 인증 완료 사용자만 SMS 알림 대상 (선택)

---

## 📅 작업 일정

### Phase 1: Backend - 필수정보 (2~3일)

| 일차 | 작업 |
|------|------|
| 1 | DTO 생성, `RequiredInfoService` 인터페이스/구현체, DB 마이그레이션 |
| 2 | `AuthController` 엔드포인트 추가, `AuthResponse` 수정 |
| 3 | `AuthServiceImpl`, `GoogleAuthServiceImpl`에 `needsRequiredInfo` 반영, 단위 테스트 |

### Phase 2: Backend - 휴대전화 인증 (2~3일)

| 일차 | 작업 |
|------|------|
| 1 | `PhoneVerificationService` 구현, SMS API 연동 (CoolSMS/NHN/AWS SNS 등), Redis 저장 |
| 2 | `send-code`, `verify-code` API 구현, `RequiredInfoService`에 인증 검증 로직 |
| 3 | 단위/통합 테스트, 에러 처리 |

### Phase 3: Frontend (2~3일)

| 일차 | 작업 |
|------|------|
| 1 | `auth_service`, `auth_repository`, `auth_response_model` 수정 |
| 2 | `RequiredInfoScreen` UI 구현 (본명 + 휴대전화 인증 플로우), 로그인 후 분기 로직 |
| 3 | 통합 테스트, 에러 처리 및 UX 개선 |

### Phase 4: 문서화 및 검수 (1일)

| 작업 |
|------|
| AUTH_API_SPEC.md에 필수정보·휴대전화 인증 API 명세 추가 |
| 회귀 테스트 |

**총 예상 기간**: 약 1.5~2주 (휴대전화 인증 포함)

---

## 🧪 테스트 계획

### Backend

1. **단위 테스트**
   - `RequiredInfoServiceImpl.isRequiredInfoCompleted()`: realName/phoneNumber/phoneVerified 조합별 검증
   - `RequiredInfoServiceImpl.submit()`: 전화번호 형식, 미인증 번호 제출 시 거부
   - `PhoneVerificationServiceImpl`: 인증번호 생성, Redis 저장/조회, 만료 검증

2. **통합 테스트**
   - `GET /api/auth/required-info/status`: 인증 사용자 조회
   - `POST /api/auth/required-info`: 정상 제출, 유효성 실패, 미인증 전화번호 제출 시 400
   - `POST /api/auth/phone/send-code`: 정상 발송, 재발송 제한(429)
   - `POST /api/auth/phone/verify-code`: 정상 검증, 잘못된 코드, 만료된 코드

3. **인증 플로우**
   - 로그인/구글 로그인 응답에 `needsRequiredInfo` 포함 여부 확인

### Frontend

1. **위젯 테스트**
   - `RequiredInfoScreen`: 폼 검증, 인증번호 발송/검증 플로우, 제출 시 API 호출

2. **플로우 테스트**
   - 로그인 → needsRequiredInfo true → RequiredInfoScreen → 휴대전화 인증 → 제출 → MainScreen
   - 로그인 → needsRequiredInfo false → MainScreen

---

## 📝 참고 사항

- 기존 `PUT /api/users/me`는 프로필 수정용으로 유지. 필수정보 입력은 `POST /api/auth/required-info` 전용.
- `needsRequiredInfo`는 로그인 시점의 스냅샷이므로, 앱 재시작 시 `GET /api/auth/required-info/status`로 최신 상태 확인 권장.
- 전화번호 형식은 `010-XXXX-XXXX`로 고정. 향후 다른 형식 지원 시 정규식 확장 가능.
- **휴대전화 인증**: `verify-code` 성공 시 Redis에 `phone_verified:{userId}` = `{phoneNumber}` 저장 (TTL 10분). `required-info` 제출 시 해당 키가 존재하고 번호가 일치할 때만 전화번호 저장 및 `phone_number_verified_at` 설정.
- **SMS 발송**: CoolSMS, NHN Cloud, AWS SNS 등 외부 서비스 연동 필요. 개발/테스트 시 목업 또는 실제 발송 비용 고려.

---

**문서 작성일**: 2026년 3월  
**작성자**: 넉터(NUKTU) 개발팀
