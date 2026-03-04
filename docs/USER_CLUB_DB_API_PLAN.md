# 📋 회원가입 확장 및 동아리 역할 DB/API 계획서

> **딸바 (PNU Basketball Platform)** 생년월일·학생 구분·학과·학번 추가 및 동아리 역할(동아리장/동아리원/OB/매니저) 구현 계획서  
> **버전**: 1.0.0  
> **작성일**: 2026-03

---

## 📋 목차

1. [개요](#개요)
2. [데이터베이스 설계](#데이터베이스-설계)
3. [API 설계](#api-설계)
4. [회원가입·로그인 플로우](#회원가입로그인-플로우)
5. [Backend 구현 계획](#backend-구현-계획)
6. [Frontend 구현 계획](#frontend-구현-계획)
7. [작업 일정](#작업-일정)
8. [테스트 계획](#테스트-계획)

---

## 🎯 개요

### 배경 및 목적

- **동아리 역할**: 기존 `club_members`에는 역할 정보가 없음. 동아리장·동아리원·OB·매니저 구분 필요.
- **회원가입 확장**: 부산대학교 학생 여부에 따라 동아리 선택 여부가 달라짐. 학생은 학과·학번, 생년월일 등 추가 정보 수집 필요.
- **본명 필수**: 닉네임 대신 **본명(실명)**을 반드시 입력하도록 변경. 동아리/매칭 서비스 특성상 실명 확인 필요.
- **플로우 분기**: 학생 → 회원가입 후 **최초 동아리 선택 화면**으로 이동. 외부인 → 동아리 선택 없음.

### 목표

1. **users** 테이블에 생년월일, 학생 여부, 학과, 학번 컬럼 추가
2. **club_members** 테이블에 역할(role) 컬럼 추가 (동아리장, 동아리원, OB, 매니저)
3. **회원가입 API** 확장 (SignupRequest, AuthResponse)
4. **동아리 선택 API** 제공 (학생 전용)
5. 회원가입/로그인 응답에 **동아리 선택 필요 여부** 플래그 포함

### 범위

| 항목 | 포함 | 비고 |
|------|------|------|
| users 테이블 확장 | ✅ | real_name(본명), date_of_birth, is_pnu_student, department, student_id |
| club_members 역할 | ✅ | role ENUM (PRESIDENT, MEMBER, OB, MANAGER) |
| SignupRequest 확장 | ✅ | 본명(필수), 생년월일, 학생 여부, 학과, 학번 |
| 동아리 선택 API | ✅ | 학생 전용 |
| AuthResponse 확장 | ✅ | needsClubSelection 플래그 |
| 구글 로그인 시 동아리 선택 | ✅ | 신규 학생 사용자 동일 적용 |

---

## 🗄️ 데이터베이스 설계

### 1. users 테이블 확장

**스키마**: `docs/database/schema.sql` (통합 스키마에 포함)

```sql
-- 본명(실명) 필수 - nickname 컬럼을 real_name으로 전환
-- 1) nickname → real_name 컬럼명 변경
ALTER TABLE users RENAME COLUMN nickname TO real_name;
-- 2) UNIQUE 제거 (본명은 동명이인 허용)
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_nickname_key;
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_real_name_key;
-- 3) 코멘트
COMMENT ON COLUMN users.real_name IS '본명(실명), 필수 입력';

-- 생년월일 (YYYY-MM-DD)
ALTER TABLE users ADD COLUMN IF NOT EXISTS date_of_birth DATE;
COMMENT ON COLUMN users.date_of_birth IS '생년월일';

-- 부산대학교 학생 여부
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_pnu_student BOOLEAN NOT NULL DEFAULT false;
COMMENT ON COLUMN users.is_pnu_student IS '부산대학교 재학생 여부 (true: 학생, false: 외부인/OB)';

-- 학과 (학생인 경우)
ALTER TABLE users ADD COLUMN IF NOT EXISTS department VARCHAR(100);
COMMENT ON COLUMN users.department IS '학과 (학생인 경우)';

-- 학번 (학생인 경우)
ALTER TABLE users ADD COLUMN IF NOT EXISTS student_id VARCHAR(20);
COMMENT ON COLUMN users.student_id IS '학번 (학생인 경우)';

-- 학번 유니크 (동일 학번 중복 방지, 학생만 해당)
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_student_id_unique 
    ON users(student_id) WHERE student_id IS NOT NULL AND student_id != '';
```

**제약 조건**:
- `is_pnu_student = true` 이면 `department`, `student_id` 입력 가능 (선택)
- `is_pnu_student = false` 이면 `department`, `student_id`는 null

---

### 2. club_members 역할 추가

**동아리 역할 정의**:

| 역할 | 영문 | 설명 |
|------|------|------|
| 동아리장 | PRESIDENT | 동아리 대표, 운영 권한 |
| 동아리원 | MEMBER | 일반 재학생 멤버 |
| OB | OB | 졸업생/휴학생 등 |
| 매니저 | MANAGER | 행정·운영 보조 |

**스키마**: `docs/database/schema.sql` (통합 스키마에 포함)

```sql
-- club_role ENUM 타입 생성
DO $$ BEGIN
    CREATE TYPE club_role AS ENUM ('PRESIDENT', 'MEMBER', 'OB', 'MANAGER');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- club_members에 role 컬럼 추가
ALTER TABLE club_members ADD COLUMN IF NOT EXISTS role club_role NOT NULL DEFAULT 'MEMBER';
COMMENT ON COLUMN club_members.role IS '동아리 내 역할 (PRESIDENT: 동아리장, MEMBER: 동아리원, OB: 졸업생, MANAGER: 매니저)';

-- 동아리당 동아리장 1명 제약 (선택사항)
-- CREATE UNIQUE INDEX idx_club_members_one_president_per_club 
--     ON club_members(club_id) WHERE role = 'PRESIDENT';
```

**clubs.captain_id와의 관계**:
- `clubs.captain_id` = 해당 동아리에서 `role = 'PRESIDENT'`인 `club_members.user_id`
- 동아리장 변경 시 `club_members.role`과 `clubs.captain_id` 동기화 필요

---

### 3. ERD 요약

```
users
├── user_id (PK)
├── email, password, real_name(본명), phone_number, ...
├── date_of_birth          -- 신규
├── is_pnu_student        -- 신규
├── department            -- 신규 (학생)
├── student_id            -- 신규 (학생)
└── ...

club_members
├── id (PK)
├── user_id (FK → users)
├── club_id (FK → clubs)
├── role                  -- 신규 (PRESIDENT, MEMBER, OB, MANAGER)
└── joined_at

clubs
├── id (PK)
├── name, logo_url
├── captain_id (FK → users)  -- role=PRESIDENT인 멤버
└── ...
```

---

## 🔧 API 설계

### 1. 회원가입 API 확장

**엔드포인트**: `POST /api/auth/signup` (기존 확장)

**요청 본문 (확장)**:
```json
{
  "email": "student@pusan.ac.kr",
  "password": "SecurePassword123!",
  "realName": "홍길동",
  "phoneNumber": "010-1234-5678",
  "dateOfBirth": "2000-05-15",
  "isPnuStudent": true,
  "department": "컴퓨터공학과",
  "studentId": "202012345"
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 | 제약 조건 |
|------|------|------|------|----------|
| `realName` | string | ✅ | **본명(실명)** | 2~50자, 필수, 동명이인 허용 |
| `dateOfBirth` | string | ✅ | 생년월일 | `YYYY-MM-DD` 형식 |
| `isPnuStudent` | boolean | ✅ | 부산대학교 학생 여부 | - |
| `department` | string | ❌* | 학과 | 학생인 경우 입력 가능, 100자 이내 |
| `studentId` | string | ❌* | 학번 | 학생인 경우 입력 가능, 20자 이내, 중복 불가 |

- **기존 `nickname` 필드 제거** → `realName`(본명)으로 대체

- `isPnuStudent = true` 일 때 `department`, `studentId` 선택 입력
- `isPnuStudent = false` 일 때 `department`, `studentId`는 무시 (null 저장)

**성공 응답 (201 Created) - 확장**:
```json
{
  "success": true,
  "data": {
    "accessToken": "...",
    "refreshToken": "...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "userId": 1,
      "email": "student@pusan.ac.kr",
      "realName": "홍길동",
      "profileImageUrl": null,
      "loginType": "EMAIL",
      "isNewUser": false,
      "needsRequiredInfo": false,
      "needsClubSelection": true
    }
  },
  "message": "회원가입이 완료되었습니다."
}
```

**응답 필드 (추가)**:
| 필드 | 타입 | 설명 |
|------|------|------|
| `needsClubSelection` | boolean | 동아리 선택 화면으로 이동 필요 여부 (학생 && 동아리 미선택 시 true) |

---

### 2. 구글 로그인 시 추가 정보 입력

구글 로그인 신규 사용자는 이메일·프로필만 있으므로, **본명·추가 정보 입력 API**가 필요하다.

**엔드포인트**: `POST /api/auth/complete-profile` (신규)

**설명**: 구글 로그인 신규 사용자가 생년월일·학생 여부·학과·학번 등을 입력한다. 기존 `required-info`와 통합하거나 별도 API로 분리 가능.

**통합 방안**: `POST /api/auth/required-info`에 `dateOfBirth`, `isPnuStudent`, `department`, `studentId` 필드 추가하여 한 번에 수집.

**별도 API 방안** (본 계획서 권장):
- `required-info`: 본명, 전화번호(휴대전화 인증)
- `complete-profile`: 생년월일, isPnuStudent, department, studentId

**요청 본문**:
```json
{
  "realName": "홍길동",
  "dateOfBirth": "2000-05-15",
  "isPnuStudent": true,
  "department": "컴퓨터공학과",
  "studentId": "202012345"
}
```

**성공 응답**:
```json
{
  "success": true,
  "data": {
    "needsClubSelection": true
  },
  "message": "추가 정보가 저장되었습니다."
}
```

- `needsClubSelection = true` → 동아리 선택 화면으로 이동

---

### 3. 동아리 선택 API

**엔드포인트**: `POST /api/clubs/select`

**설명**: 학생 사용자가 동아리를 선택하여 가입한다. 1 user : 1 club 제약 유지. 동아리 내 역할(동아리원/매니저/OB)을 지정할 수 있다. **동아리장(PRESIDENT)은 백오피스에서만 지정 가능.**

**인증 필요**: ✅ (Access Token)

**요청 본문**:
```json
{
  "clubId": "550e8400-e29b-41d4-a716-446655440000",
  "role": "MEMBER"
}
```

**요청 필드**:
| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `clubId` | UUID | ✅ | 가입할 동아리 ID |
| `role` | string | ❌ | 동아리 내 역할. `MEMBER`(동아리원), `MANAGER`(매니저), `OB`(졸업생) 중 선택. 미지정 시 `MEMBER`. **`PRESIDENT`(동아리장)는 백오피스에서만 지정 가능** |

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "clubId": "550e8400-e29b-41d4-a716-446655440000",
    "clubName": "PNU 농구동아리",
    "role": "MEMBER"
  },
  "message": "동아리에 가입되었습니다."
}
```

**에러 응답**:
- `400 Bad Request`: 이미 동아리에 가입된 사용자, `role`이 `PRESIDENT`인 경우
- `403 Forbidden`: 학생이 아닌 사용자 (외부인)
- `404 Not Found`: 존재하지 않는 동아리

---

### 4. 동아리 목록 조회 (선택 화면용)

**엔드포인트**: `GET /api/clubs`

**설명**: 동아리 선택 화면에서 가입 가능한 동아리 목록을 조회한다.

**인증 필요**: ✅ (Access Token)

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": [
    {
      "clubId": "550e8400-e29b-41d4-a716-446655440000",
      "name": "PNU 농구동아리",
      "logoUrl": "https://...",
      "memberCount": 25
    }
  ],
  "message": "동아리 목록 조회 성공"
}
```

---

### 5. 동아리 선택 필요 여부 조회

**엔드포인트**: `GET /api/auth/club-selection/status`

**설명**: 현재 사용자가 동아리 선택이 필요한지 확인한다.

**인증 필요**: ✅ (Access Token)

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "needsClubSelection": true,
    "isPnuStudent": true,
    "currentClub": null
  },
  "message": "동아리 선택 상태 조회 성공"
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `needsClubSelection` | boolean | 동아리 선택 필요 여부 |
| `isPnuStudent` | boolean | 학생 여부 |
| `currentClub` | object \| null | 현재 가입된 동아리 (있으면 null 아님) |

---

### 6. AuthResponse 확장 (로그인/구글 로그인)

**UserInfo에 추가**:
| 필드 | 타입 | 설명 |
|------|------|------|
| `needsClubSelection` | boolean | 동아리 선택 화면으로 이동 필요 여부 |

**조건**:
- `needsClubSelection = true` ⇔ `isPnuStudent = true` && `club_members`에 해당 user 없음

---

## 🔄 회원가입·로그인 플로우

### 자체 회원가입 플로우

```
1. 회원가입 화면: email, password, realName(본명), phoneNumber, dateOfBirth, isPnuStudent, [department], [studentId]
2. POST /api/auth/signup
3. 응답: AuthResponse { user: { needsRequiredInfo, needsClubSelection } }
4. needsRequiredInfo == true  → 필수정보 입력 화면 (휴대전화 인증 등)
5. needsClubSelection == true → 동아리 선택 화면 (학생만)
6. 동아리 선택 → POST /api/clubs/select
7. 메인 화면
```

### 구글 로그인 플로우 (신규 사용자)

```
1. POST /api/auth/google
2. 응답: AuthResponse { user: { isNewUser: true, needsRequiredInfo, needsClubSelection } }
3. (필수정보 미완료 시) 필수정보 입력 화면 → complete-profile (생년월일, 학생 여부, 학과, 학번)
4. needsClubSelection == true → 동아리 선택 화면
5. 동아리 선택 → POST /api/clubs/select
6. 메인 화면
```

### 외부인 (isPnuStudent = false)

- `needsClubSelection = false` → 동아리 선택 화면 건너뜀
- 동아리 선택 API 호출 시 403 Forbidden

---

## 🔧 Backend 구현 계획

### 1단계: DB 마이그레이션

| 파일 | 내용 |
|------|------|
| `schema.sql` | 통합 스키마 (users, clubs, club_members 등) |

### 2단계: 도메인 모델

| 파일 | 작업 |
|------|------|
| `User.java` | nickname → realName 변경, dateOfBirth, isPnuStudent, department, studentId 필드 추가 |
| `ClubMember.java` | role 필드 추가 (ClubRole enum) |
| `ClubRole.java` | 신규 enum (PRESIDENT, MEMBER, OB, MANAGER) |

### 3단계: DTO

| 파일 | 작업 |
|------|------|
| `SignupRequest.java` | nickname → realName 변경, dateOfBirth, isPnuStudent, department, studentId 추가 |
| `AuthResponse.UserInfo` | needsClubSelection 추가 |
| `CompleteProfileRequest.java` | 신규 (구글 로그인 추가 정보) |
| `ClubSelectRequest.java` | 신규 |
| `ClubListResponse.java` | 신규 (동아리 목록) |
| `ClubSelectionStatusResponse.java` | 신규 |

### 4단계: 서비스

| 파일 | 작업 |
|------|------|
| `AuthServiceImpl.signup()` | 새 필드 저장, needsClubSelection 계산 |
| `GoogleAuthServiceImpl` | needsClubSelection 반영 |
| `UserService` | completeProfile() 메서드 추가 |
| `ClubService` | selectClub(), getClubs(), getClubSelectionStatus() 추가 |

### 5단계: 컨트롤러

| 파일 | 작업 |
|------|------|
| `AuthController` | complete-profile 엔드포인트 (또는 required-info 통합) |
| `ClubController` | GET /clubs, POST /clubs/select, GET /auth/club-selection/status |

### 6단계: 검증 로직

- `isPnuStudent = false` 일 때 `department`, `studentId` null 처리
- `studentId` 중복 체크 (학생만)
- 동아리 선택 시 `isPnuStudent` 체크
- 동아리 중복 가입 방지 (1 user : 1 club)

---

## 📱 Frontend 구현 계획

### 1단계: 회원가입 화면 확장

| 항목 | 작업 |
|------|------|
| `signup_screen.dart` | realName(본명) 필수, dateOfBirth, isPnuStudent, department, studentId 입력 필드 추가 |
| 조건부 UI | isPnuStudent 선택 시 학과·학번 필드 표시 |

### 2단계: 구글 로그인 후 추가 정보 화면

| 항목 | 작업 |
|------|------|
| `complete_profile_screen.dart` | 신규 - 본명, 생년월일, 학생 여부, 학과, 학번 |
| 분기 | 구글 신규 + needsClubSelection → complete_profile → club_selection |

### 3단계: 동아리 선택 화면

| 항목 | 작업 |
|------|------|
| `club_selection_screen.dart` | 신규 - 동아리 목록, 역할 선택(동아리원/매니저/OB), 선택 버튼 |
| API | GET /api/clubs, POST /api/clubs/select (role 포함) |

### 4단계: 플로우 통합

| 항목 | 작업 |
|------|------|
| `auth_provider` | needsClubSelection 확인, 화면 분기 |
| `login_screen`, `signup` | 성공 시 needsClubSelection → ClubSelectionScreen |

---

## 📅 작업 일정

### Phase 1: DB 및 도메인 (1일)

| 작업 |
|------|
| V4 마이그레이션 작성 및 적용 |
| User, ClubMember, ClubRole 엔티티 수정 |

### Phase 2: Backend API (2~3일)

| 일차 | 작업 |
|------|------|
| 1 | SignupRequest 확장, AuthServiceImpl 수정, CompleteProfile API |
| 2 | ClubService (select, list, status), ClubController |
| 3 | 단위/통합 테스트 |

### Phase 3: Frontend (2~3일)

| 일차 | 작업 |
|------|------|
| 1 | 회원가입 화면 확장, complete_profile 화면 |
| 2 | 동아리 선택 화면, 플로우 분기 |
| 3 | 통합 테스트 |

**총 예상 기간**: 약 1주

---

## 🧪 테스트 계획

### Backend

1. **단위 테스트**
   - SignupRequest 유효성 (학생/외부인, 학번 중복)
   - ClubService.selectClub(): 학생만 허용, 중복 가입 방지

2. **통합 테스트**
   - POST /api/auth/signup: 학생/외부인 각각, needsClubSelection 반환 확인
   - POST /api/clubs/select: 정상, 외부인 403, 중복 400
   - GET /api/auth/club-selection/status

### Frontend

1. **플로우 테스트**
   - 학생 회원가입 → 동아리 선택 → 메인
   - 외부인 회원가입 → 동아리 선택 건너뜀 → 메인
   - 구글 신규 학생 → complete_profile → 동아리 선택 → 메인

---

## 📝 참고 사항

- **본명(real_name)**: 닉네임 대신 본명 필수. 동명이인 허용으로 UNIQUE 제거. JWT 등에서 `nickname` 대신 `realName` 사용.
- **clubs.captain_id**: 동아리장 지정 시 `club_members.role = 'PRESIDENT'`와 동기화 필요. 별도 API `PUT /api/clubs/{id}/captain` 등으로 관리.
- **학번 검증**: 부산대 학번 형식 검증은 선택사항. 초기에는 자유 형식, 추후 정규식 추가 가능.
- **동아리 생성**: 동아리 생성 API는 별도. 관리자 또는 동아리장이 생성하는 흐름으로 확장 가능.

---

**문서 작성일**: 2026년 3월  
**작성자**: 딸바 개발팀
