-- ============================================================
-- club_matches (동아리전 매칭 - 가정)
-- schedules.match_id와 연동하여 동아리전 결과를 기록
-- ============================================================
CREATE TABLE IF NOT EXISTS club_matches (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    schedule_id     UUID REFERENCES schedules(id) ON DELETE SET NULL,
    home_club_id    UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    away_club_id    UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    home_score      INTEGER NOT NULL DEFAULT 0,
    away_score      INTEGER NOT NULL DEFAULT 0,
    winner_club_id  UUID REFERENCES clubs(id) ON DELETE SET NULL,
    match_date      DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'COMPLETED',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_club_matches_different_clubs CHECK (home_club_id != away_club_id)
);

CREATE INDEX idx_club_matches_home_club ON club_matches(home_club_id);
CREATE INDEX idx_club_matches_away_club ON club_matches(away_club_id);
CREATE INDEX idx_club_matches_winner ON club_matches(winner_club_id);
CREATE INDEX idx_club_matches_date ON club_matches(match_date);

COMMENT ON TABLE club_matches IS '동아리전 매칭 결과 (승리 시 clubs.wins 업데이트)';
