# 백오피스 구현 계획서

> **넉터(NUKTU)** 관리자 백오피스 HTML/CSS/JS 구현 계획서
> **버전**: 1.0.0  
> **작성일**: 2026-03

---

## 목차

1. [개요](#1-개요)
2. [기술 스택 및 구조](#2-기술-스택-및-구조)
3. [디자인 시스템](#3-디자인-시스템)
4. [기능 명세](#4-기능-명세)
5. [백엔드 API 요구사항](#5-백엔드-api-요구사항)
6. [파일 구조](#6-파일-구조)
7. [구현 단계별 계획](#7-구현-단계별-계획)
8. [인증 및 보안](#8-인증-및-보안)

---

## 1. 개요

### 1.1 목적

- **플랫폼 관리자**가 넉터(NUKTU) 서비스를 운영·관리할 수 있는 웹 기반 백오피스 구축
- **순수 HTML/CSS/JS**로 구현하여 별도 프레임워크 없이 가볍고 빠른 관리 도구 제공

### 1.2 주요 기능

| 번호 | 기능 | 설명 |
|------|------|------|
| 1 | 전체 유저 목록 확인 | 전체 회원 조회, 검색, 필터링, 상세 정보 |
| 2 | 동아리 관리 | 동아리 생성, 동아리장 설정/수정, 멤버 관리 |
| 3 | 매칭 관리 | 매치 목록 조회, 상태 수정, 점수 수정 |
| 4 | 게시글/댓글 관리 | 게시글·댓글 조회, 수정, 삭제 |

### 1.3 대상 사용자

- 플랫폼 **관리자(Admin)** 전용
- 일반 사용자 접근 불가

---

## 2. 기술 스택 및 구조

| 구분 | 기술 |
|------|------|
| 프론트엔드 | HTML5, CSS3, Vanilla JavaScript |
| API 통신 | Fetch API |
| 스타일 | 제공된 CSS (사이드바, 테이블, 모달, 버튼 등) |
| 배포 | Spring Boot 백엔드 `static` 폴더 또는 별도 정적 서버 |

### 2.1 아키텍처

```
[사용자] → [백오피스 HTML/JS] → [Spring Boot REST API] → [PostgreSQL]
```

- 백오피스는 **SPA(단일 페이지)** 형태로 탭 전환 시 콘텐츠만 교체
- 모든 데이터는 백엔드 `GET/POST/PUT/DELETE` API를 통해 조회·수정

---

## 3. 디자인 시스템

### 3.1 레이아웃

- **사이드바**: `260px` 고정, 그라데이션 배경 (`#667eea` → `#764ba2`)
- **메인 콘텐츠**: `margin-left: 260px`, `padding: 40px`
- **반응형**: 768px 이하에서 사이드바 상단, 모바일 대응

### 3.2 색상 팔레트

| 용도 | 색상 | HEX |
|------|------|-----|
| Primary | 보라 | `#667eea` |
| Primary Hover | 진보라 | `#5568d3` |
| Gradient | 보라→자주 | `#667eea` → `#764ba2` |
| 배경 | 연회색 | `#f5f7fa` |
| 텍스트 | 진회색 | `#2d3748` |
| 보조 텍스트 | 회색 | `#4a5568`, `#718096` |

### 3.3 상태 배지

| 상태 | 클래스 | 배경 | 텍스트 |
|------|--------|------|--------|
| 대기 | `status-pending` | `#fef3c7` | `#92400e` |
| 승인 | `status-approved` | `#d1fae5` | `#065f46` |
| 연결 중 | `status-connecting` | `#dbeafe` | `#1e40af` |
| 연결됨 | `status-connected` | `#e0e7ff` | `#3730a3` |
| 블랙리스트 | `status-blacklisted` | `#fee2e2` | `#991b1b` |

### 3.4 컴포넌트

- **필터 섹션**: `filter-section`, `filter-group`, `filter-select`, `search-box`
- **테이블**: `table-section`, `member-table`, `thead`, `tbody`
- **모달**: `modal`, `modal-content`, `modal-header`, `modal-body`, `modal-footer`
- **페이지네이션**: `pagination`, `page-btn`, `page-number`

---

## 4. 기능 명세

### 4.1 대시보드

| 항목 | 내용 |
|------|------|
| 위치 | 메인 진입 후 첫 화면 |
| 표시 | 전체 유저 수, 동아리 수, 매치 수, 최근 게시글 수 |
| 차트 | (선택) 간단한 통계 카드 |

### 4.2 전체 유저 목록

| 항목 | 내용 |
|------|------|
| 테이블 컬럼 | 번호, 이메일, 본명, 학생 여부, 학과, 학번, 동아리, 가입일, 액션 |
| 필터 | 학생 여부, 동아리, 가입일 범위 |
| 검색 | 이메일, 본명, 학번 |
| 액션 | 상세 보기, 수정/삭제(선택) |
| 페이지네이션 | 10/20/50개 단위 |

### 4.3 동아리 관리

| 항목 | 내용 |
|------|------|
| 동아리 목록 | 이름, 로고, 동아리장, 멤버 수, 생성일 |
| 동아리 생성 | 이름, 로고 URL(선택) 입력 |
| 동아리장 설정 | 기존 멤버 중에서 동아리장 선택 |
| 동아리장 수정 | 동아리장 변경 시 `club_members.role`과 `clubs.captain_id` 동기화 |

### 4.4 매칭 관리

| 항목 | 내용 |
|------|------|
| 매치 목록 | 홈팀, 어웨이팀, 일시, 상태, 점수 |
| 필터 | 상태(SCHEDULED|READY|ONGOING|DONE|CANCELLED), 날짜 |
| 수정 | 상태 변경, 점수 변경 |
| 참가자 | 매치별 참가자 목록 확인 |

### 4.5 게시글/댓글 관리

| 항목 | 내용 |
|------|------|
| 게시글 목록 | 제목, 작성자, 작성일, 조회수, 댓글 수 |
| 삭제/수정 | 관리자 권한으로 수정·삭제 |
| 댓글 | 게시글별 댓글 목록, 삭제·수정 |

> **참고**: 현재 DB에 `posts`, `comments` 테이블이 없음. 백엔드·DB 스키마 확장 필요.

---

## 5. 백엔드 API 요구사항

### 5.1 기존 API 활용

| 기존 API | 용도 |
|----------|------|
| `GET /api/auth/me` | 관리자 로그인 확인 |
| `POST /api/auth/login` | 백오피스 로그인 |

### 5.2 신규 Admin API (필요)

#### 5.2.1 유저 관리

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/admin/users` | 전체 유저 목록 (페이지네이션, 필터, 검색) |
| GET | `/api/admin/users/{id}` | 유저 상세 |

**Query 예시**: `?page=1&size=20&isPnuStudent=true&clubId=xxx&search=홍길동`

#### 5.2.2 동아리 관리

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/admin/clubs` | 전체 동아리 목록 |
| POST | `/api/admin/clubs` | 동아리 생성 |
| PUT | `/api/admin/clubs/{id}` | 동아리 수정 |
| PUT | `/api/admin/clubs/{id}/captain` | 동아리장 설정/수정 |

**동아리 생성 요청 예시**:
```json
{
  "name": "PNU 농구동아리",
  "logoUrl": "https://..."
}
```

**동아리장 설정 요청 예시**:
```json
{
  "userId": 1
}
```

#### 5.2.3 매칭 관리

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/admin/matches` | 매치 목록 (페이지네이션, 필터) |
| GET | `/api/admin/matches/{id}` | 매치 상세 + 참가자 |
| PUT | `/api/admin/matches/{id}` | 매치 수정 (상태, 점수) |

**매치 수정 요청 예시**:
```json
{
  "state": "DONE",
  "homeScore": 85,
  "awayScore": 72
}
```

#### 5.2.4 게시글/댓글 관리 (DB 확장 후)

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/admin/posts` | 게시글 목록 |
| GET | `/api/admin/posts/{id}` | 게시글 상세 + 댓글 |
| PUT | `/api/admin/posts/{id}` | 게시글 수정 |
| DELETE | `/api/admin/posts/{id}` | 게시글 삭제 |
| PUT | `/api/admin/comments/{id}` | 댓글 수정 |
| DELETE | `/api/admin/comments/{id}` | 댓글 삭제 |

### 5.3 게시글/댓글 DB 스키마 (신규)

```sql
-- posts
CREATE TABLE posts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    club_id         UUID REFERENCES clubs(id) ON DELETE SET NULL,
    title           VARCHAR(200) NOT NULL,
    content         TEXT NOT NULL,
    view_count      INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- comments
CREATE TABLE comments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id         UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    content         TEXT NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

---

## 6. 파일 구조

```
backend/src/main/resources/static/
├── admin/
│   ├── index.html          # 메인 (로그인/대시보드)
│   ├── login.html          # 로그인 페이지 (선택)
│   ├── css/
│   │   └── admin.css       # 제공된 디자인 스타일
│   └── js/
│       ├── admin.js        # 공통 (API, 인증, 탭 전환)
│       ├── dashboard.js    # 대시보드
│       ├── users.js        # 유저 목록
│       ├── clubs.js        # 동아리 관리
│       ├── matches.js      # 매칭 관리
│       └── posts.js        # 게시글/댓글 관리
```

또는 `frontend` 폴더와 별도로:

```
backoffice/
├── index.html
├── css/
│   └── admin.css
└── js/
    ├── admin.js
    ├── dashboard.js
    ├── users.js
    ├── clubs.js
    ├── matches.js
    └── posts.js
```

---

## 7. 구현 단계별 계획

### Phase 1: 기반 구축 (1일)

| 작업 | 내용 |
|------|------|
| HTML/CSS | `index.html`, `admin.css` (제공된 스타일 적용) |
| 레이아웃 | 사이드바, 메인 콘텐츠, 탭 메뉴 |
| JS | `admin.js` - API base URL, 토큰 저장, 로그인 체크 |

### Phase 2: 유저 관리 (1~2일)

| 작업 | 내용 |
|------|------|
| 백엔드 | `GET /api/admin/users` API 구현 |
| 프론트 | 유저 목록 테이블, 필터, 검색, 페이지네이션 |
| 모달 | 유저 상세 보기, 수정(선택) |

### Phase 3: 동아리 관리 (1~2일)

| 작업 | 내용 |
|------|------|
| 백엔드 | `POST /api/admin/clubs`, `PUT /api/admin/clubs/{id}/captain` |
| 프론트 | 동아리 목록, 생성 폼, 동아리장 설정 모달 |

### Phase 4: 매칭 관리 (1~2일)

| 작업 | 내용 |
|------|------|
| 백엔드 | `GET /api/admin/matches`, `PUT /api/admin/matches/{id}` |
| 프론트 | 매치 목록, 필터, 수정 모달 |

### Phase 5: 게시글/댓글 관리 (2~3일)

| 작업 | 내용 |
|------|------|
| DB | `posts`, `comments` 테이블 생성 |
| 백엔드 | Admin CRUD API 구현 |
| 프론트 | 게시글 목록, 상세, 댓글 관리 |

### Phase 6: 대시보드 및 마무리 (1일)

| 작업 | 내용 |
|------|------|
| 대시보드 | 통계 카드, 최근 활동 |
| 보안 | Admin 권한 체크, `/api/admin/**` 경로 보호 |

**총 예상 기간**: 약 7~10일

---

## 8. 인증 및 보안

### 8.1 인증

- 백오피스: `POST /api/auth/login`으로 JWT 발급
- `localStorage`에 `accessToken` 저장
- API 호출 시 `Authorization: Bearer {token}` 헤더 포함

### 8.2 보안

- `users` 테이블에 `role` 컬럼 추가 (예: `USER`, `ADMIN`)
- `/api/admin/**` 경로는 `role === ADMIN`만 허용
- `SecurityConfig`에 Admin 경로 추가: `.requestMatchers("/api/admin/**").hasRole("ADMIN")`

### 8.3 CORS

- 백오피스 도메인을 `SecurityConfig`의 `allowedOrigins`에 추가

---

## 부록: 제공된 CSS 스타일 요약

- `*`, `body`: 전역 리셋, 배경색
- `.admin-container`, `.sidebar`, `.main-content`: 레이아웃
- `.nav-tab`, `.nav-tab.active`: 네비게이션
- `.filter-section`, `.filter-group`, `.search-box`: 필터
- `.table-section`, `.member-table`: 테이블
- `.status-badge`, `.status-*`: 상태 배지
- `.modal`, `.modal-content`: 모달
- `.pagination`, `.page-btn`, `.page-number`: 페이지네이션
- `.action-btn`, `.btn-primary`, `.btn-cancel`: 버튼
- `@media (max-width: 768px)`: 반응형

---

**문서 작성일**: 2026년 3월  
**작성자**: 넉터(NUKTU) 개발팀
