-- ============================================================
-- clubs (동아리)
-- ============================================================

CREATE TABLE clubs (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name          VARCHAR(100) NOT NULL,
    logo_url      VARCHAR(500),
    introduction  TEXT,
    captain_id    BIGINT REFERENCES users(user_id) ON DELETE SET NULL,
    wins          INTEGER NOT NULL DEFAULT 0,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clubs_captain_id ON clubs(captain_id);
CREATE INDEX idx_clubs_name ON clubs(name);
CREATE INDEX idx_clubs_wins ON clubs(wins DESC);

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
