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
--   04_posts.sql   - 게시글, 댓글

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUM
-- ============================================================
CREATE TYPE club_role AS ENUM ('PRESIDENT', 'MEMBER', 'OB', 'MANAGER');

-- Hibernate @Enumerated(EnumType.STRING)이 VARCHAR로 전송하므로,
-- PostgreSQL이 자동으로 enum으로 캐스팅할 수 있도록 implicit cast 등록
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
    is_admin                BOOLEAN NOT NULL DEFAULT false,
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

-- ============================================================
-- schedule_locations (매칭 장소 - 유동적 확장)
-- ============================================================
CREATE TABLE schedule_locations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    sort_order      INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_schedule_locations_sort ON schedule_locations(sort_order);

-- ============================================================
-- schedule_status ENUM
-- ============================================================
CREATE TYPE schedule_status AS ENUM ('AVAILABLE', 'SCHEDULED', 'CANCELLED');
CREATE CAST (character varying AS schedule_status) WITH INOUT AS IMPLICIT;

-- ============================================================
-- schedules (농구장 일정)
-- ============================================================
CREATE TABLE schedules (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    location_id     UUID NOT NULL REFERENCES schedule_locations(id) ON DELETE RESTRICT,
    schedule_date   DATE NOT NULL,
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    status          schedule_status NOT NULL DEFAULT 'SCHEDULED',
    schedule_type   VARCHAR(50) NOT NULL DEFAULT 'REGULAR',
    title           VARCHAR(200),
    description     TEXT,
    match_id        UUID,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_schedule_time CHECK (start_time < end_time)
);

CREATE INDEX idx_schedules_location_id ON schedules(location_id);
CREATE INDEX idx_schedules_date ON schedules(schedule_date);
CREATE INDEX idx_schedules_location_date ON schedules(location_id, schedule_date);

-- MVP 기본 매칭 장소
INSERT INTO schedule_locations (name, sort_order) VALUES
    ('넉넉한터 본관 방향', 1),
    ('넉넉한터 공원 방향', 2),
    ('온천천 부산대역 농구장', 3)
ON CONFLICT (name) DO NOTHING;
