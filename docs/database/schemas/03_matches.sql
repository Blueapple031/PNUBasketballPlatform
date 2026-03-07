-- ============================================================
-- matches (매치)
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
-- match_participants (매치 참가자)
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
