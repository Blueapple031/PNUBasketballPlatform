-- clubs, matches, club_members, match_participants 테이블 생성
-- 정식 매치(동아리 vs 동아리) + 빠른 매치(픽업 게임) 지원
-- 실행: psql -h 호스트 -U 사용자 -d DB명 -f scripts/migrate-basketball-tables.sql

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DO $$ BEGIN
    CREATE TYPE match_type AS ENUM ('FORMAL', 'QUICK');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE team_side AS ENUM ('HOME', 'AWAY');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE match_state AS ENUM ('SCHEDULED', 'READY', 'ONGOING', 'DONE', 'CANCELLED');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS clubs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL,
    logo_url        VARCHAR(500),
    captain_id      BIGINT REFERENCES users(user_id) ON DELETE SET NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS tr_clubs_updated_at ON clubs;
CREATE TRIGGER tr_clubs_updated_at
    BEFORE UPDATE ON clubs FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TABLE IF NOT EXISTS club_members (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    club_id         UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    joined_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_club_members_user UNIQUE (user_id)
);

CREATE TABLE IF NOT EXISTS matches (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_type          match_type NOT NULL,
    home_club_id        UUID REFERENCES clubs(id) ON DELETE CASCADE,
    away_club_id        UUID REFERENCES clubs(id) ON DELETE CASCADE,
    created_by          BIGINT REFERENCES users(user_id) ON DELETE SET NULL,
    scheduled_at        TIMESTAMP NOT NULL,
    location            VARCHAR(255),
    max_players_per_team INTEGER DEFAULT 5,
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

DROP TRIGGER IF EXISTS tr_matches_updated_at ON matches;
CREATE TRIGGER tr_matches_updated_at
    BEFORE UPDATE ON matches FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TABLE IF NOT EXISTS match_participants (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id        UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    club_id         UUID REFERENCES clubs(id) ON DELETE CASCADE,
    team_side       team_side NOT NULL,
    points_scored   INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_match_participant UNIQUE (match_id, user_id),
    CONSTRAINT chk_points_non_negative CHECK (points_scored >= 0)
);

CREATE INDEX IF NOT EXISTS idx_clubs_captain_id ON clubs(captain_id);
CREATE INDEX IF NOT EXISTS idx_clubs_name ON clubs(name);
CREATE INDEX IF NOT EXISTS idx_club_members_user_id ON club_members(user_id);
CREATE INDEX IF NOT EXISTS idx_club_members_club_id ON club_members(club_id);
CREATE INDEX IF NOT EXISTS idx_matches_match_type ON matches(match_type);
CREATE INDEX IF NOT EXISTS idx_matches_home_club ON matches(home_club_id);
CREATE INDEX IF NOT EXISTS idx_matches_away_club ON matches(away_club_id);
CREATE INDEX IF NOT EXISTS idx_matches_created_by ON matches(created_by);
CREATE INDEX IF NOT EXISTS idx_matches_scheduled_at ON matches(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_matches_state ON matches(state);
CREATE INDEX IF NOT EXISTS idx_match_participants_match_id ON match_participants(match_id);
CREATE INDEX IF NOT EXISTS idx_match_participants_user_id ON match_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_match_participants_team_side ON match_participants(match_id, team_side);
