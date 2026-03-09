-- clubs, club_members 테이블 생성
-- 실행: psql -h 호스트 -U 사용자 -d DB명 -f scripts/migrate-basketball-tables.sql

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

CREATE INDEX IF NOT EXISTS idx_clubs_captain_id ON clubs(captain_id);
CREATE INDEX IF NOT EXISTS idx_clubs_name ON clubs(name);
CREATE INDEX IF NOT EXISTS idx_club_members_user_id ON club_members(user_id);
CREATE INDEX IF NOT EXISTS idx_club_members_club_id ON club_members(club_id);
