-- PostgreSQL Database Schema for 딸바 (PNU Basketball Platform)
-- 통합 스키마 (2026-03)
--
-- 실행: psql -U postgres -d ddalba_DB -f schema.sql
-- (docs/database/ 디렉터리에서 실행하거나, 프로젝트 루트에서 docs/database/schema.sql 지정)
--
-- 스키마는 schemas/ 폴더에 도메인별로 분리되어 있습니다:
--   00_common.sql  - 확장, ENUM
--   01_users.sql   - 회원
--   02_clubs.sql   - 동아리, 동아리 멤버
--   03_matches.sql - 매치, 매치 참가자
--   04_posts.sql   - 게시글, 댓글

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUM
-- ============================================================
CREATE TYPE match_state AS ENUM ('SCHEDULED', 'PENDING', 'CONFIRMED', 'READY', 'ONGOING', 'DONE', 'CANCELLED');
CREATE TYPE club_role AS ENUM ('PRESIDENT', 'MEMBER', 'OB', 'MANAGER');
CREATE TYPE game_format AS ENUM ('THREE_VS_THREE', 'FOUR_VS_FOUR', 'FIVE_VS_FIVE');
CREATE TYPE match_purpose AS ENUM ('CLUB_PRACTICE', 'CASUAL', 'GUEST_NEEDED', 'FRIENDLY');

-- Hibernate @Enumerated(EnumType.STRING)이 VARCHAR로 전송하므로,
-- PostgreSQL이 자동으로 club_role로 캐스팅할 수 있도록 implicit cast 등록
CREATE CAST (character varying AS club_role) WITH INOUT AS IMPLICIT;

-- ============================================================
-- users
-- ============================================================
CREATE TABLE users (
    user_id                 BIGSERIAL PRIMARY KEY,
    email                   VARCHAR(255) NOT NULL UNIQUE,
    password                VARCHAR(255),
    real_name               VARCHAR(50) NOT NULL,
    phone_number            VARCHAR(20),
    phone_number_verified_at TIMESTAMP,
    profile_image_url       VARCHAR(500),
    login_type              VARCHAR(20) NOT NULL DEFAULT 'EMAIL',
    google_id               VARCHAR(255) UNIQUE,
    kakao_id                VARCHAR(255) UNIQUE,
    date_of_birth           DATE,
    is_pnu_student          BOOLEAN NOT NULL DEFAULT false,
    department              VARCHAR(100),
    student_id              VARCHAR(20),
    wins                    INTEGER NOT NULL DEFAULT 0,
    games                   INTEGER NOT NULL DEFAULT 0,
    total_score             INTEGER NOT NULL DEFAULT 0,
    virtual_currency        INTEGER NOT NULL DEFAULT 0,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_student_id_unique ON users(student_id) WHERE student_id IS NOT NULL AND student_id != '';
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_users_kakao_id ON users(kakao_id);
CREATE INDEX idx_users_real_name ON users(real_name);

-- ============================================================
-- clubs
-- ============================================================
CREATE TABLE clubs (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name          VARCHAR(100) NOT NULL,
    logo_url      VARCHAR(500),
    introduction  TEXT,
    captain_id    BIGINT REFERENCES users(user_id) ON DELETE SET NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clubs_captain_id ON clubs(captain_id);
CREATE INDEX idx_clubs_name ON clubs(name);

-- ============================================================
-- club_members (1 user : 1 club)
-- ============================================================
CREATE TABLE club_members (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    club_id     UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    role        club_role NOT NULL DEFAULT 'MEMBER',
    joined_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_club_members_user UNIQUE (user_id)
);

CREATE INDEX idx_club_members_user_id ON club_members(user_id);
CREATE INDEX idx_club_members_club_id ON club_members(club_id);

-- ============================================================
-- venues (경기장/코트)
-- ============================================================
CREATE TABLE venues (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_venues_name ON venues(name);

-- ============================================================
-- club_court_slots (동아리별 코트 사용시간 - 매주 반복)
-- ============================================================
CREATE TABLE club_court_slots (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id         UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    venue_id        UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    day_of_week     SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_court_slot_time CHECK (start_time < end_time)
);
CREATE INDEX idx_club_court_slots_club ON club_court_slots(club_id);
CREATE INDEX idx_club_court_slots_venue ON club_court_slots(venue_id);
CREATE INDEX idx_club_court_slots_day ON club_court_slots(day_of_week);

-- ============================================================
-- matches
-- ============================================================
CREATE TABLE matches (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    home_club_id    UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    away_club_id    UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    scheduled_at    TIMESTAMP NOT NULL,
    state           match_state NOT NULL DEFAULT 'SCHEDULED',
    home_score      INTEGER,
    away_score      INTEGER,
    game_format     game_format NOT NULL DEFAULT 'FIVE_VS_FIVE',
    venue_id        UUID REFERENCES venues(id) ON DELETE SET NULL,
    match_purpose   match_purpose NOT NULL DEFAULT 'CASUAL',
    end_at          TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_match_clubs_different CHECK (home_club_id != away_club_id)
);

CREATE INDEX idx_matches_home_club ON matches(home_club_id);
CREATE INDEX idx_matches_away_club ON matches(away_club_id);
CREATE INDEX idx_matches_scheduled_at ON matches(scheduled_at);
CREATE INDEX idx_matches_state ON matches(state);

-- ============================================================
-- match_participants
-- ============================================================
CREATE TABLE match_participants (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id        UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    club_id         UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    points_scored   INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_match_participant UNIQUE (match_id, user_id),
    CONSTRAINT chk_points_non_negative CHECK (points_scored >= 0)
);

CREATE INDEX idx_match_participants_match_id ON match_participants(match_id);
CREATE INDEX idx_match_participants_user_id ON match_participants(user_id);
CREATE INDEX idx_match_participants_club_id ON match_participants(club_id);

-- venues 시드 데이터
INSERT INTO venues (name, description) VALUES
    ('넉넉한터 본관코트', '부산대학교 넉넉한터 본관 실내 코트'),
    ('넉넉한터 공원코트', '부산대학교 넉넉한터 야외 공원 코트'),
    ('부산대역 농구코트', '부산대역 인근 농구 코트')
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- posts
-- ============================================================
CREATE TABLE posts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title           VARCHAR(200) NOT NULL,
    content         TEXT NOT NULL,
    view_count      INTEGER NOT NULL DEFAULT 0,
    is_pinned       BOOLEAN NOT NULL DEFAULT false,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- comments
-- ============================================================
CREATE TABLE comments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id         UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    content         TEXT NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

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
