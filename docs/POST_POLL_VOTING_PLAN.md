# 📋 게시판 투표 기능 계획서 (1인 1표)

> **딸바 (PNU Basketball Platform)** 게시글 첨부 투표(설문) 기능 구현 계획서  
> **버전**: 1.0.0  
> **작성일**: 2026-03

---

## 📋 목차

1. [개요](#개요)
2. [데이터베이스 설계](#데이터베이스-설계)
3. [API 설계](#api-설계)
4. [Backend 구현 계획](#backend-구현-계획)
5. [Frontend 구현 계획](#frontend-구현-계획)
6. [관리자 페이지](#관리자-페이지)
7. [작업 일정](#작업-일정)

---

## 🎯 개요

### 배경 및 목적

- **투표(설문) 기능**: 게시글에 투표를 첨부하여 커뮤니티 의견 수렴 (예: 다음 모임 일정, MVP 선정 등)
- **1인 1표**: 한 사용자가 한 투표당 하나의 선택지만 선택 가능
- **게시글 연동**: 투표는 게시글에 종속 (1 post : 0~1 poll)

### 목표

1. **polls**, **poll_options**, **poll_votes** 테이블 추가
2. 게시글 작성/수정 시 투표 첨부 가능
3. 투표 참여 API (1인 1표, 중복 방지)
4. 투표 결과 조회 (본인 투표 여부 포함)

### 범위

| 항목 | 포함 | 비고 |
|------|------|------|
| polls 테이블 | ✅ | post_id, question, expires_at |
| poll_options 테이블 | ✅ | poll_id, option_text, sort_order |
| poll_votes 테이블 | ✅ | poll_id, option_id, user_id, UNIQUE(poll_id, user_id) |
| 투표 생성 | ✅ | 게시글 작성/수정 시 함께 생성 |
| 투표 참여 | ✅ | 1인 1표, 재투표 불가 |
| 투표 결과 조회 | ✅ | 옵션별 득표수, 본인 선택 여부 |
| 투표 수정 | ⚠️ | 작성 후 수정 시 기존 투표 유지 vs 새로 생성 (추후 결정) |
| 투표 만료 | ✅ | expires_at 기준, 만료 후 투표 불가 |

---

## 🗄️ 데이터베이스 설계

### 1. ERD

```
posts (기존)
├── id (PK)
└── ...

polls (신규)
├── id (PK, UUID)
├── post_id (FK → posts, UNIQUE)   -- 1 post : 1 poll
├── question (VARCHAR 500)         -- 투표 질문
├── expires_at (TIMESTAMP)         -- 만료일 (NULL = 무기한)
└── created_at

poll_options (신규)
├── id (PK, UUID)
├── poll_id (FK → polls)
├── option_text (VARCHAR 200)      -- 선택지 텍스트
├── sort_order (INT)               -- 표시 순서
└── created_at

poll_votes (신규)
├── id (PK, UUID)
├── poll_id (FK → polls)
├── option_id (FK → poll_options)
├── user_id (FK → users)
├── created_at
└── UNIQUE(poll_id, user_id)       -- 1인 1표
```

### 2. 스키마 DDL

```sql
-- ============================================================
-- polls (투표)
-- ============================================================
CREATE TABLE polls (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id         UUID NOT NULL UNIQUE REFERENCES posts(id) ON DELETE CASCADE,
    question        VARCHAR(500) NOT NULL,
    expires_at      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_polls_post_id ON polls(post_id);

-- ============================================================
-- poll_options (투표 선택지)
-- ============================================================
CREATE TABLE poll_options (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    poll_id         UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
    option_text     VARCHAR(200) NOT NULL,
    sort_order      INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_poll_options_poll_id ON poll_options(poll_id);

-- ============================================================
-- poll_votes (투표 참여 - 1인 1표)
-- ============================================================
CREATE TABLE poll_votes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    poll_id         UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
    option_id       UUID NOT NULL REFERENCES poll_options(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_poll_votes_user UNIQUE (poll_id, user_id)
);

CREATE INDEX idx_poll_votes_poll_id ON poll_votes(poll_id);
CREATE INDEX idx_poll_votes_user_id ON poll_votes(user_id);
```

### 3. 제약 조건

| 제약 | 설명 |
|------|------|
| `polls.post_id UNIQUE` | 1 게시글당 1개 투표만 |
| `uq_poll_votes_user` | 1인 1표 (poll_id + user_id 중복 불가) |
| `expires_at` | NULL이면 무기한, 값 있으면 해당 시각 이후 투표 불가 |

---

## 🔧 API 설계

### 1. 게시글 작성 시 투표 포함 (확장)

**엔드포인트**: `POST /api/posts` (기존 확장)

**요청 본문 (확장)**:
```json
{
  "title": "다음 모임 일정 투표",
  "content": "다음 주 모임 날짜를 선택해주세요.",
  "poll": {
    "question": "다음 모임 날짜는?",
    "options": ["토요일 오후", "일요일 오전", "일요일 오후"],
    "expiresAt": "2026-03-15T23:59:59"
  }
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `poll` | object | ❌ | 투표 첨부 시 포함 |
| `poll.question` | string | ✅* | 투표 질문 (500자 이내) |
| `poll.options` | string[] | ✅* | 선택지 목록 (2~10개) |
| `poll.expiresAt` | string | ❌ | 만료일시 (ISO 8601) |

### 2. 투표하기

**엔드포인트**: `POST /api/posts/{postId}/polls/vote`

**인증 필요**: ✅

**요청 본문**:
```json
{
  "optionId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**성공 응답 (200 OK)**:
```json
{
  "success": true,
  "data": {
    "pollId": "...",
    "optionId": "...",
    "message": "투표가 반영되었습니다."
  },
  "message": "투표가 반영되었습니다."
}
```

**에러**:
- `400`: 이미 투표함, 만료된 투표, 잘못된 optionId
- `404`: 게시글/투표 없음

### 3. 게시글 상세 조회 (투표 포함)

**엔드포인트**: `GET /api/posts/{postId}` (기존 확장)

**응답 확장**:
```json
{
  "id": "...",
  "title": "...",
  "content": "...",
  "poll": {
    "id": "...",
    "question": "다음 모임 날짜는?",
    "options": [
      { "id": "...", "text": "토요일 오후", "voteCount": 5 },
      { "id": "...", "text": "일요일 오전", "voteCount": 3 },
      { "id": "...", "text": "일요일 오후", "voteCount": 2 }
    ],
    "expiresAt": "2026-03-15T23:59:59",
    "totalVotes": 10,
    "myVoteOptionId": "..."  // 본인 투표한 optionId (없으면 null)
  }
}
```

### 4. 투표 결과만 조회 (선택)

**엔드포인트**: `GET /api/posts/{postId}/polls`

- 게시글 상세에 포함되므로 별도 API는 선택사항

---

## 🔧 Backend 구현 계획

### 1단계: DB 마이그레이션

| 파일 | 내용 |
|------|------|
| `docs/database/schema.sql` | polls, poll_options, poll_votes 추가 |
| `docs/database/migrations/add_polls.sql` | 기존 DB 마이그레이션용 |

### 2단계: 도메인 모델

| 파일 | 작업 |
|------|------|
| `Poll.java` | 신규 - id, post, question, expiresAt |
| `PollOption.java` | 신규 - id, poll, optionText, sortOrder |
| `PollVote.java` | 신규 - id, poll, option, user |

### 3단계: Repository

| 파일 | 작업 |
|------|------|
| `PollRepository.java` | findByPostId, existsByPostId |
| `PollOptionRepository.java` | findByPollIdOrderBySortOrder |
| `PollVoteRepository.java` | findByPollId, existsByPollIdAndUserId |

### 4단계: DTO

| 파일 | 작업 |
|------|------|
| `CreatePostRequest` | poll 필드 추가 (PollCreateRequest) |
| `PollResponse` | id, question, options, expiresAt, totalVotes, myVoteOptionId |
| `PollOptionResponse` | id, text, voteCount |
| `VoteRequest` | optionId |

### 5단계: Service

| 파일 | 작업 |
|------|------|
| `PostServiceImpl.createPost()` | poll 있으면 Poll, PollOption 생성 |
| `PollService` (신규) | vote(), getPollByPostId() |
| `PostServiceImpl.getPost()` | poll 포함하여 반환 |

### 6단계: Controller

| 파일 | 작업 |
|------|------|
| `PostController` | POST /posts/{postId}/polls/vote 추가 |

---

## 📱 Frontend 구현 계획

### 1단계: 모델

| 파일 | 작업 |
|------|------|
| `post_model.dart` | PostDetailModel에 poll 필드 추가 |
| `PollModel`, `PollOptionModel` | 신규 |

### 2단계: API

| 파일 | 작업 |
|------|------|
| `post_service.dart` | votePoll() 메서드 추가 |
| `post_repository.dart` | votePoll() 추가 |
| `community_provider.dart` | votePoll() 추가 |

### 3단계: UI

| 화면 | 작업 |
|------|------|
| `post_create_screen.dart` | 투표 첨부 섹션 (질문, 선택지 2~10개, 만료일) |
| `post_detail_screen.dart` | 투표 영역 표시, 선택 버튼, 결과(득표수), 본인 투표 표시 |

### 4단계: UX

- 투표 만료 시: 선택 비활성화, "투표가 종료되었습니다" 표시
- 이미 투표한 경우: 선택 비활성화, "OOO에 투표하셨습니다" 표시
- 투표 없는 게시글: 기존과 동일

---

## 🖥️ 관리자 페이지

| 기능 | 설명 |
|------|------|
| 게시글 상세 | 투표 포함 조회 |
| 투표 결과 확인 | 옵션별 득표수 확인 |
| 투표 수정 | (선택) 작성 후 수정 시 기존 투표 데이터 처리 정책 필요 |

---

## 📅 작업 일정

### Phase 1: DB 및 도메인 (0.5일)

| 작업 |
|------|
| schema.sql 확장, 마이그레이션 SQL 작성 |
| Poll, PollOption, PollVote 엔티티 생성 |
| Repository 생성 |

### Phase 2: Backend API (1~1.5일)

| 작업 |
|------|
| CreatePostRequest 확장, PollService 구현 |
| POST /polls/vote, PostDetailResponse에 poll 포함 |
| 단위 테스트 |

### Phase 3: Frontend (1~1.5일)

| 작업 |
|------|
| 모델, API, Provider 확장 |
| 글쓰기 화면 투표 섹션 |
| 상세 화면 투표 UI |

### Phase 4: 관리자 (0.5일)

| 작업 |
|------|
| 게시글 상세 모달에 투표 결과 표시 |

**총 예상 기간**: 약 3~4일

---

## 📝 참고 사항

- **재투표**: 1인 1표 제약으로 재투표 불가. 필요 시 `poll_votes` 삭제 후 재생성 로직 추가 검토.
- **투표 수정**: 게시글 수정 시 기존 투표가 있으면 수정 불가 또는 "새 투표로 교체" 정책 결정 필요.
- **선택지 개수**: 2~10개 권장 (DB 제약은 VARCHAR 200으로 각 옵션 텍스트 길이 제한).
- **만료 처리**: `expires_at`이 있고 `now() > expires_at`이면 투표 불가.

---

**문서 작성일**: 2026년 3월  
**작성자**: 딸바 개발팀
