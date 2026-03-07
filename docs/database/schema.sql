-- PostgreSQL Database Schema for 딸바 (PNU Basketball Platform)
-- 통합 스키마 (2026-03)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- ENUM
-- ============================================================
CREATE TYPE match_state AS ENUM ('SCHEDULED', 'READY', 'ONGOING', 'DONE', 'CANCELLED');
CREATE TYPE club_role AS ENUM ('PRESIDENT', 'MEMBER', 'OB', 'MANAGER');

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

-- ============================================================
-- posts
-- ============================================================
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