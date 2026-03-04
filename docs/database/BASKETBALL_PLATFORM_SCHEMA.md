# 대학 농구 동아리 매칭 플랫폼 - 확장 가능한 관계형 DB 스키마 설계

> **작성일**: 2026-02-19  
> **DBMS**: PostgreSQL  
> **규칙**: 3NF 정규화, UUID PK, Junction Table 사용, 배열/리스트 컬럼 금지

---

## 목차

1. [ER 다이어그램 설명](#1-er-다이어그램-설명)
2. [ENUM 정의](#2-enum-정의)
3. [CREATE TABLE 문](#3-create-table-문)
4. [인덱스 제안](#4-인덱스-제안)
5. [미래 확장성](#5-미래-확장성)

---

## 1. ER 다이어그램 설명

### 1.1 매치 유형

| 유형 | 설명 | 특징 |
|------|------|------|
| **정식 매치 (FORMAL)** | 동아리 vs 동아리 | home_club, away_club 필수, 동아리원만 참가 |
| **빠른 매치 (QUICK)** | 픽업 게임 | 클럽 없음, 아무나 참가, 팀은 매칭 시 배정 |

### 1.2 엔티티 관계 개요

```
┌─────────────┐         ┌──────────────────┐         ┌─────────────┐
│   users     │────────<│   club_members   │>────────│   clubs     │
│             │   1:N   │  (junction)      │   N:1   │             │
│ - id (PK)   │         │ - user_id (FK)   │         │ - id (PK)   │
│ - email     │         │ - club_id (FK)   │         │ - name      │
│ - auth_type │         │ - joined_at      │         │ - captain_id │
│ - wins      │         └──────────────────┘         │ - logo_url  │
│ - games     │                        │              └──────┬──────┘
│ - total_scr │                        │                     │
│ - currency  │                        │  1:N (정식만)       │ 1:N
└──────┬──────┘                        │                     │
       │                               │              ┌──────▼──────┐
       │         ┌─────────────────────┴─────────────│   matches   │
       │         │                                   │             │
       │    N:1  │                                   │ match_type  │
       │         │                                   │ (FORMAL/QUICK)
       └────────>│  match_participants (junction)   │ home_club?  │
            N:1  │                                   │ away_club?  │
                 │  - match_id (FK)                   │ created_by  │
                 │  - user_id (FK)                   │ (빠른매치)  │
                 │  - club_id? (정식만)               │ location    │
                 │  - team_side (HOME/AWAY)          │ max_players │
                 │  - points_scored                  └─────────────┘
                 └───────────────────────────────────
```

### 1.3 엔티티 상세

| 엔티티 | 설명 | 주요 관계 |
|--------|------|----------|
| **users** | 플랫폼 사용자 (선수, 회원) | club_members 통해 1개 클럽 소속 (선택) |
| **clubs** | 농구 동아리/팀 | captain이 users 참조, members는 club_members 통해 |
| **club_members** | 사용자-클럽 소속 (Junction) | 1 user 1 club (UNIQUE 제약) |
| **matches** | 경기 (정식/빠른) | match_type으로 구분, 정식 시 home/away_club, 빠른 시 created_by |
| **match_participants** | 경기별 참가자 | match + user + team_side, club_id는 정식 매치만 |

### 1.4 순환 참조 해결

- `clubs.captain_id` → `users`: 주장은 반드시 club_members에 등록된 회원
- `users`는 `club_members`를 통해서만 클럽과 연결 (club_id 없음)
- 주장 지정 시: `club_members`에 해당 user가 있어야 함

---

## 2. ENUM 정의

```sql
-- 인증 타입
CREATE TYPE auth_type AS ENUM ('LOCAL', 'KAKAO', 'GOOGLE');

-- 매치 유형
CREATE TYPE match_type AS ENUM ('FORMAL', 'QUICK');

-- 팀 구분 (HOME/AWAY)
CREATE TYPE team_side AS ENUM ('HOME', 'AWAY');

-- 경기 상태
CREATE TYPE match_state AS ENUM (
    'SCHEDULED',   -- 예정됨
    'READY',       -- 준비됨 (시작 직전)
    'ONGOING',     -- 진행 중
    'DONE',        -- 종료됨
    'CANCELLED'    -- 취소됨
);
```

---

## 3. CREATE TABLE 문

```sql
-- ============================================================
-- 확장: uuid-ossp (UUID 생성용)
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. users 테이블
-- ============================================================
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email           VARCHAR(255) NOT NULL,
    password        VARCHAR(255),                    -- NULL: OAuth 전용
    nickname        VARCHAR(50) NOT NULL,
    phone_number    VARCHAR(20),
    profile_image_url VARCHAR(500),
    auth_type       auth_type NOT NULL DEFAULT 'LOCAL',
    google_id       VARCHAR(255) UNIQUE,
    kakao_id        VARCHAR(255) UNIQUE,
    -- 성과 통계 (match_participants 기반 집계, 앱 업데이트)
    wins            INTEGER NOT NULL DEFAULT 0,
    games           INTEGER NOT NULL DEFAULT 0,
    total_score     INTEGER NOT NULL DEFAULT 0,
    -- 가상 화폐
    virtual_currency INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at   TIMESTAMP,
    deleted_at      TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_email_active ON users(email) WHERE deleted_at IS NULL;
CREATE UNIQUE INDEX idx_users_nickname_active ON users(nickname) WHERE deleted_at IS NULL;

-- ============================================================
-- 2. clubs 테이블
-- ============================================================
CREATE TABLE clubs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL,
    logo_url        VARCHAR(500),
    captain_id      UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 3. club_members (Junction: User ↔ Club, 1:1 소속)
-- ============================================================
CREATE TABLE club_members (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    club_id         UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    joined_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_club_members_user UNIQUE (user_id)  -- 1 user = 1 club
);

-- ============================================================
-- 4. matches 테이블 (정식 매치 + 빠른 매치)
-- ============================================================
CREATE TABLE matches (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_type          match_type NOT NULL,           -- FORMAL | QUICK
    home_club_id        UUID REFERENCES clubs(id) ON DELETE CASCADE,  -- 정식만
    away_club_id        UUID REFERENCES clubs(id) ON DELETE CASCADE,  -- 정식만
    created_by          BIGINT REFERENCES users(user_id) ON DELETE SET NULL,  -- 빠른 매치 생성자
    scheduled_at        TIMESTAMP NOT NULL,
    location            VARCHAR(255),                  -- 빠른 매치: "OO대 실내체육관"
    max_players_per_team INTEGER DEFAULT 5,           -- 빠른 매치: 팀당 인원 (5v5)
    state               match_state NOT NULL DEFAULT 'SCHEDULED',
    home_score          INTEGER,
    away_score          INTEGER,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_formal_clubs CHECK (
        match_type != 'FORMAL' OR (home_club_id IS NOT NULL AND away_club_id IS NOT NULL AND home_club_id != away_club_id)
    ),
    CONSTRAINT chk_quick_no_clubs CHECK (
        match_type != 'QUICK' OR (home_club_id IS NULL AND away_club_id IS NULL)
    )
);

-- ============================================================
-- 5. match_participants (Junction: Match ↔ User, 경기별 득점)
-- ============================================================
CREATE TABLE match_participants (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id        UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    club_id         UUID REFERENCES clubs(id) ON DELETE CASCADE,  -- 정식 매치만
    team_side       team_side NOT NULL,                -- HOME | AWAY
    points_scored   INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_match_participant UNIQUE (match_id, user_id),
    CONSTRAINT chk_points_non_negative CHECK (points_scored >= 0)
);

-- ============================================================
-- updated_at 자동 갱신 트리거
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_users_updated_at
    BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER tr_clubs_updated_at
    BEFORE UPDATE ON clubs FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
CREATE TRIGGER tr_matches_updated_at
    BEFORE UPDATE ON matches FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- ============================================================
-- 테이블/컬럼 코멘트
-- ============================================================
COMMENT ON TABLE users IS '플랫폼 사용자 (선수)';
COMMENT ON COLUMN users.wins IS '참가 경기 중 승리 횟수 (집계)';
COMMENT ON COLUMN users.games IS '총 참가 경기 수 (집계)';
COMMENT ON COLUMN users.total_score IS '총 득점 (집계)';
COMMENT ON COLUMN users.virtual_currency IS '가상 화폐 잔액';

COMMENT ON TABLE clubs IS '농구 동아리/팀';
COMMENT ON COLUMN clubs.captain_id IS '주장 (users.id)';

COMMENT ON TABLE club_members IS '사용자-클럽 소속 (1 user : 1 club)';
COMMENT ON TABLE matches IS '경기 (정식: 동아리 vs 동아리, 빠른: 픽업 게임)';
COMMENT ON COLUMN matches.match_type IS 'FORMAL=정식 매치, QUICK=빠른 매치';
COMMENT ON COLUMN matches.created_by IS '빠른 매치 생성자 (users.user_id)';
COMMENT ON TABLE match_participants IS '경기별 참가자 및 개인 득점';
COMMENT ON COLUMN match_participants.team_side IS 'HOME/AWAY 팀 구분';
```

---

## 4. 인덱스 제안

```sql
-- ============================================================
-- users
-- ============================================================
CREATE INDEX idx_users_auth_type ON users(auth_type);
CREATE INDEX idx_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;
CREATE INDEX idx_users_kakao_id ON users(kakao_id) WHERE kakao_id IS NOT NULL;
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NULL;

-- 랭킹/통계 조회용 (wins, total_score 등)
CREATE INDEX idx_users_wins_desc ON users(wins DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_total_score_desc ON users(total_score DESC) WHERE deleted_at IS NULL;

-- ============================================================
-- clubs
-- ============================================================
CREATE INDEX idx_clubs_captain_id ON clubs(captain_id);
CREATE INDEX idx_clubs_name ON clubs(name);

-- ============================================================
-- club_members
-- ============================================================
CREATE INDEX idx_club_members_user_id ON club_members(user_id);
CREATE INDEX idx_club_members_club_id ON club_members(club_id);
-- 복합: 특정 클럽 회원 목록
CREATE INDEX idx_club_members_club_user ON club_members(club_id, user_id);

-- ============================================================
-- matches
-- ============================================================
CREATE INDEX idx_matches_home_club ON matches(home_club_id);
CREATE INDEX idx_matches_away_club ON matches(away_club_id);
CREATE INDEX idx_matches_scheduled_at ON matches(scheduled_at);
CREATE INDEX idx_matches_state ON matches(state);
-- 복합: 클럽별 경기 목록 + 날짜
CREATE INDEX idx_matches_clubs_scheduled ON matches(home_club_id, scheduled_at);
CREATE INDEX idx_matches_clubs_scheduled_away ON matches(away_club_id, scheduled_at);
-- 상태별 경기 조회
CREATE INDEX idx_matches_state_scheduled ON matches(state, scheduled_at);

-- ============================================================
-- match_participants
-- ============================================================
CREATE INDEX idx_match_participants_match_id ON match_participants(match_id);
CREATE INDEX idx_match_participants_user_id ON match_participants(user_id);
CREATE INDEX idx_match_participants_club_id ON match_participants(club_id);
-- 복합: 경기별 참가자, 사용자별 경기 이력
CREATE INDEX idx_match_participants_match_user ON match_participants(match_id, user_id);
CREATE INDEX idx_match_participants_user_match ON match_participants(user_id, match_id);
```

---

## 5. 미래 확장성

### 5.1 심판 배정 (Referee Assignment)

```sql
-- 심판 테이블 (users와 별도 또는 users 역할 확장)
CREATE TABLE referees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    certification_level VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 경기-심판 배정 (Junction)
CREATE TABLE match_referees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    referee_id UUID NOT NULL REFERENCES referees(id) ON DELETE CASCADE,
    role VARCHAR(50),  -- 'MAIN', 'ASSISTANT', etc.
    CONSTRAINT uq_match_referee UNIQUE (match_id, referee_id)
);
```

### 5.2 클럽 랭킹

- `clubs`에 `rank`, `rank_updated_at` 추가 또는 별도 `club_rankings` 테이블
- Materialized View로 주기적 집계:

```sql
CREATE MATERIALIZED VIEW club_rankings AS
SELECT
    c.id,
    c.name,
    COUNT(DISTINCT m.id) FILTER (WHERE m.state = 'DONE' AND (
        (m.home_club_id = c.id AND m.home_score > m.away_score) OR
        (m.away_club_id = c.id AND m.away_score > m.home_score)
    )) AS wins,
    COUNT(DISTINCT m.id) FILTER (WHERE m.state = 'DONE') AS total_matches,
    RANK() OVER (ORDER BY wins DESC NULLS LAST) AS rank
FROM clubs c
LEFT JOIN matches m ON m.home_club_id = c.id OR m.away_club_id = c.id
GROUP BY c.id, c.name;
```

### 5.3 경기 라이프사이클 확장

- `match_state`에 `POSTPONED`, `RESCHEDULED` 등 추가 가능
- `match_events` 테이블로 상태 변경 이력 추적:

```sql
CREATE TABLE match_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    event_type VARCHAR(50),  -- 'STATE_CHANGE', 'SCORE_UPDATE', etc.
    payload JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### 5.4 사용자 통계 동기화

- `users.wins`, `users.games`, `users.total_score`는 `match_participants` + `matches` 기반 집계
- 동기화 방법:
  1. **트리거**: `matches.state` → `DONE` 시 관련 `match_participants`의 `user_id`에 대해 `users` 집계 업데이트
  2. **배치 Job**: 주기적으로 `match_participants` + `matches`에서 집계 후 `users` 업데이트
  3. **읽기 시 계산**: 랭킹/통계 API에서 JOIN으로 실시간 집계 (데이터 많으면 Materialized View 권장)

### 5.5 기타 확장 포인트

| 영역 | 확장 방향 |
|------|----------|
| **경기장** | `venues` 테이블, `matches.venue_id` FK |
| **시즌/리그** | `seasons`, `leagues` 테이블, `matches.season_id` |
| **팀 로스터** | `club_members`에 `jersey_number`, `position` 등 추가 |
| **경기 상세** | `match_quarters` (쿼터별 점수), `match_plays` (플레이 단위) |
| **가상 화폐** | `currency_transactions` (충전/사용 내역) |

---

## 부록: 기존 스키마 마이그레이션 참고

현재 `users` 테이블이 `BIGSERIAL` + `login_type`(EMAIL, GOOGLE)을 사용 중이라면,  
신규 스키마는 별도 마이그레이션 스크립트로 적용하고, 기존 데이터 이전 시 `auth_type` 매핑(`EMAIL`→`LOCAL`)을 적용하는 것을 권장합니다.

---

## 부록: 구현 스키마

| 파일 | 설명 |
|------|------|
| `schema.sql` | 통합 스키마 (users, clubs, club_members, matches, match_participants) |

**실행**: `psql -d basketball_db -f docs/database/schema.sql`

**JPA 엔티티**: `Club`, `ClubMember`, `Match`, `MatchParticipant`, `MatchState`, `ClubRole` (domain 패키지)
