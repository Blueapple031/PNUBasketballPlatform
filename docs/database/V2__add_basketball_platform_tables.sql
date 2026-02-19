-- V2: Basketball Platform - clubs, matches, club_members, match_participants
-- 기존 users 테이블과 호환 (user_id BIGINT)

-- ============================================================
-- 확장 및 ENUM
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE match_state AS ENUM (
    'SCHEDULED',
    'READY',
    'ONGOING',
    'DONE',
    'CANCELLED'
);

-- ============================================================
-- users 테이블 확장 (성과 통계, 가상 화폐, kakao_id)
-- ============================================================
ALTER TABLE users ADD COLUMN IF NOT EXISTS wins INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS games INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_score INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS virtual_currency INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS kakao_id VARCHAR(255) UNIQUE;

COMMENT ON COLUMN users.wins IS '참가 경기 중 승리 횟수 (집계)';
COMMENT ON COLUMN users.games IS '총 참가 경기 수 (집계)';
COMMENT ON COLUMN users.total_score IS '총 득점 (집계)';
COMMENT ON COLUMN users.virtual_currency IS '가상 화폐 잔액';
COMMENT ON COLUMN users.kakao_id IS '카카오 사용자 ID';

-- ============================================================
-- clubs 테이블
-- ============================================================
CREATE TABLE clubs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL,
    logo_url        VARCHAR(500),
    captain_id      BIGINT REFERENCES users(user_id) ON DELETE SET NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER tr_clubs_updated_at
    BEFORE UPDATE ON clubs FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

COMMENT ON TABLE clubs IS '농구 동아리/팀';
COMMENT ON COLUMN clubs.captain_id IS '주장 (users.user_id)';

-- ============================================================
-- club_members (Junction: User ↔ Club, 1 user : 1 club)
-- ============================================================
CREATE TABLE club_members (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    club_id         UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    joined_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_club_members_user UNIQUE (user_id)
);

COMMENT ON TABLE club_members IS '사용자-클럽 소속 (1 user : 1 club)';

-- ============================================================
-- matches 테이블
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
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_match_clubs_different CHECK (home_club_id != away_club_id)
);

CREATE TRIGGER tr_matches_updated_at
    BEFORE UPDATE ON matches FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

COMMENT ON TABLE matches IS '클럽 간 경기';

-- ============================================================
-- match_participants (Junction: Match ↔ User, 경기별 득점)
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

COMMENT ON TABLE match_participants IS '경기별 참가자 및 개인 득점';

-- ============================================================
-- 인덱스
-- ============================================================
CREATE INDEX idx_users_wins_desc ON users(wins DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_total_score_desc ON users(total_score DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_kakao_id ON users(kakao_id) WHERE kakao_id IS NOT NULL;

CREATE INDEX idx_clubs_captain_id ON clubs(captain_id);
CREATE INDEX idx_clubs_name ON clubs(name);

CREATE INDEX idx_club_members_user_id ON club_members(user_id);
CREATE INDEX idx_club_members_club_id ON club_members(club_id);
CREATE INDEX idx_club_members_club_user ON club_members(club_id, user_id);

CREATE INDEX idx_matches_home_club ON matches(home_club_id);
CREATE INDEX idx_matches_away_club ON matches(away_club_id);
CREATE INDEX idx_matches_scheduled_at ON matches(scheduled_at);
CREATE INDEX idx_matches_state ON matches(state);
CREATE INDEX idx_matches_clubs_scheduled ON matches(home_club_id, scheduled_at);
CREATE INDEX idx_matches_clubs_scheduled_away ON matches(away_club_id, scheduled_at);
CREATE INDEX idx_matches_state_scheduled ON matches(state, scheduled_at);

CREATE INDEX idx_match_participants_match_id ON match_participants(match_id);
CREATE INDEX idx_match_participants_user_id ON match_participants(user_id);
CREATE INDEX idx_match_participants_club_id ON match_participants(club_id);
CREATE INDEX idx_match_participants_match_user ON match_participants(match_id, user_id);
CREATE INDEX idx_match_participants_user_match ON match_participants(user_id, match_id);
