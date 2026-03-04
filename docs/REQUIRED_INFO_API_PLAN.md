# 📋 필수정보입력 API 구현 계획서

> **딸바 (PNU Basketball Platform)** 기본 로그인 및 구글 로그인 후 필수정보입력 API 구현 계획서  
> **버전**: 1.0.0  
> **작성일**: 2026-03

---

## 📋 목차

1. [개요](#개요)
2. [필수정보 정의](#필수정보-정의)
3. [API 설계](#api-설계)
4. [Backend 구현 계획](#backend-구현-계획)
5. [Frontend 구현 계획](#frontend-구현-계획)
6. [인증 플로우 통합](#인증-플로우-통합)
7. [작업 일정](#작업-일정)
8. [테스트 계획](#테스트-계획)

---

## 🎯 개요

### 배경 및 목적

- **기본 로그인(이메일/비밀번호)**: 회원가입 시 닉네임·전화번호를 입력하지만, 전화번호는 선택사항이라 미입력 가능
- **구글 로그인**: 신규 사용자는 이메일·닉네임(자동생성)·프로필 이미지만 저장되고, **전화번호가 누락**됨
- **농구 매칭 서비스 특성**: 번개 매칭 시 팀원 연락이 필요하므로 **전화번호**를 필수로 요구

본 계획서는 로그인(기본/구글) 직후 **필수정보 미입력 사용자**를 식별하고, **필수정보 입력 API**를 통해 정보를 수집·저장하는 기능을 구현하기 위한 것이다.

### 목표

1. 로그인 응답에 **필수정보 입력 필요 여부** 플래그 포함
2. **필수정보 입력 여부 조회 API** 제공
3. **필수정보 제출 API** 제공 (닉네임 수정, 전화번호 입력 등)
4. 프론트엔드에서 로그인 후 필수정보 미입력 시 **필수정보 입력 화면**으로 유도

### 범위

| 항목 | 포함 | 비고 |
|------|------|------|
| 필수정보 입력 여부 조회 API | ✅ | `GET /api/auth/required-info/status` |
| 필수정보 제출 API | ✅ | `POST /api/auth/required-info` |
| AuthResponse에 `needsRequiredInfo` 추가 | ✅ | 로그인/구글 로그인 응답 |
| 필수정보 입력 화면 (Flutter) | ✅ | 로그인 후 분기 |
| 기존 `PUT /api/users/me` 활용 | ✅ | 중복 최소화 |

---

## 📌 필수정보 정의

### 필수정보 항목

| 항목 | 필수 여부 | 설명 | 제약 조건 |
|------|----------|------|------------|
| `nickname` | ✅ | 닉네임 | 2~20자, 중복 불가 (이미 User에 있음) |
| `phoneNumber` | ✅ | 전화번호 | `010-XXXX-XXXX` 형식 |

- **닉네임**: 구글 로그인 시 자동생성되므로, 사용자가 원하면 수정 가능. 자체 로그인은 회원가입 시 이미 입력됨.
- **전화번호**: 매칭 시 연락용으로 **반드시 필요**. 자체/구글 모두 미입력 가능하므로, 필수정보 입력 단계에서 수집.

### 필수정보 완료 조건

```
필수정보 완료 = (nickname != null && nickname.length >= 2) 
            && (phoneNumber != null && phoneNumber.matches("010-\\d{4}-\\d{4}"))
```

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
    "missingFields": ["phoneNumber"],
    "user": {
      "userId": 1,
      "email": "user@example.com",
      "nickname": "농구왕",
      "phoneNumber": null,
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
| `missingFields` | string[] | 미입력 필드 목록 (예: `["phoneNumber"]`, `["nickname","phoneNumber"]`) |
| `user` | object | 현재 사용자 정보 (일부) |

**에러 응답**:
- `401 Unauthorized`: 유효하지 않은 Access Token

---

### 2. 필수정보 제출

**엔드포인트**: `POST /api/auth/required-info`

**설명**: 필수정보(닉네임, 전화번호)를 입력·수정한다. 기존 `PUT /api/users/me`와 유사하나, **필수정보 미완료 사용자 전용**으로 설계하여 로그인 직후 플로우에 최적화한다.

**인증 필요**: ✅ (Access Token)

**요청 본문**:
```json
{
  "nickname": "농구왕",
  "phoneNumber": "010-1234-5678"
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 | 제약 조건 |
|------|------|------|------|----------|
| `nickname` | string | ❌* | 닉네임 | 2~20자, 중복 불가 (*필수정보 미완료 시 필수) |
| `phoneNumber` | string | ❌* | 전화번호 | `010-XXXX-XXXX` (*필수정보 미완료 시 필수) |

- 최소 1개 이상 필드 필요
- `completed`가 되려면 `nickname`과 `phoneNumber` 모두 유효해야 함

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
- `409 Conflict`: 닉네임 중복

---

### 3. AuthResponse 확장 (로그인/구글 로그인 응답)

기존 `AuthResponse`의 `UserInfo`에 다음 필드를 추가한다.

| 필드 | 타입 | 설명 |
|------|------|------|
| `needsRequiredInfo` | boolean | 필수정보 입력이 필요한지 여부 |

**수정된 AuthResponse.UserInfo 예시**:
```json
{
  "userId": 1,
  "email": "user@example.com",
  "nickname": "구글사용자",
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

#### 수정 파일

| 파일 | 수정 내용 |
|------|----------|
| `AuthResponse.UserInfo` | `needsRequiredInfo` 필드 추가 |

#### DTO 예시

**`RequiredInfoRequest.java`**:
```java
@Getter
@NoArgsConstructor
public class RequiredInfoRequest {
    @Size(min = 2, max = 20, message = "닉네임은 2-20자 사이여야 합니다.")
    private String nickname;
    
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

#### `isRequiredInfoCompleted` 로직

```java
public boolean isRequiredInfoCompleted(User user) {
    if (user.getNickname() == null || user.getNickname().length() < 2) {
        return false;
    }
    if (user.getPhoneNumber() == null || !user.getPhoneNumber().matches("^010-\\d{4}-\\d{4}$")) {
        return false;
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
```

---

### 4단계: AuthResponse 수정

`AuthResponse.UserInfo`에 `needsRequiredInfo` 추가:

```java
public static class UserInfo {
    private Long userId;
    private String email;
    private String nickname;
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
| `auth_service.dart` | `getRequiredInfoStatus()`, `submitRequiredInfo()` 메서드 추가 |

### 2단계: Repository 확장

| 파일 | 작업 |
|------|------|
| `auth_repository.dart` | `getRequiredInfoStatus()`, `submitRequiredInfo()` 래핑 |

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
| `required_info_screen.dart` | 신규 생성 - 닉네임, 전화번호 입력 폼 |
| `required_info_provider.dart` | (선택) 상태 관리 |

- 닉네임: 중복 확인 버튼 (기존 `checkNickname` API 활용)
- 전화번호: `010-XXXX-XXXX` 형식 검증
- 제출 시 `POST /api/auth/required-info` 호출 후 메인 화면으로 이동

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

## 📅 작업 일정

### Phase 1: Backend (2~3일)

| 일차 | 작업 |
|------|------|
| 1 | DTO 생성, `RequiredInfoService` 인터페이스/구현체 |
| 2 | `AuthController` 엔드포인트 추가, `AuthResponse` 수정 |
| 3 | `AuthServiceImpl`, `GoogleAuthServiceImpl`에 `needsRequiredInfo` 반영, 단위 테스트 |

### Phase 2: Frontend (2~3일)

| 일차 | 작업 |
|------|------|
| 1 | `auth_service`, `auth_repository`, `auth_response_model` 수정 |
| 2 | `RequiredInfoScreen` UI 구현, 로그인 후 분기 로직 |
| 3 | 통합 테스트, 에러 처리 및 UX 개선 |

### Phase 3: 문서화 및 검수 (1일)

| 작업 |
|------|
| AUTH_API_SPEC.md에 필수정보 API 명세 추가 |
| 회귀 테스트 |

**총 예상 기간**: 약 1주

---

## 🧪 테스트 계획

### Backend

1. **단위 테스트**
   - `RequiredInfoServiceImpl.isRequiredInfoCompleted()`: nickname/phoneNumber 조합별 검증
   - `RequiredInfoServiceImpl.submit()`: 닉네임 중복, 전화번호 형식 검증

2. **통합 테스트**
   - `GET /api/auth/required-info/status`: 인증 사용자 조회
   - `POST /api/auth/required-info`: 정상 제출, 유효성 실패, 닉네임 중복

3. **인증 플로우**
   - 로그인/구글 로그인 응답에 `needsRequiredInfo` 포함 여부 확인

### Frontend

1. **위젯 테스트**
   - `RequiredInfoScreen`: 폼 검증, 제출 시 API 호출

2. **플로우 테스트**
   - 로그인 → needsRequiredInfo true → RequiredInfoScreen → 제출 → MainScreen
   - 로그인 → needsRequiredInfo false → MainScreen

---

## 📝 참고 사항

- 기존 `PUT /api/users/me`는 프로필 수정용으로 유지. 필수정보 입력은 `POST /api/auth/required-info` 전용.
- `needsRequiredInfo`는 로그인 시점의 스냅샷이므로, 앱 재시작 시 `GET /api/auth/required-info/status`로 최신 상태 확인 권장.
- 전화번호 형식은 `010-XXXX-XXXX`로 고정. 향후 다른 형식 지원 시 정규식 확장 가능.

---

**문서 작성일**: 2026년 3월  
**작성자**: 딸바 개발팀
