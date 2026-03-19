-- 매칭 시스템 Phase 2: matches + 참가 이력 테이블

CREATE TABLE matches (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_type             VARCHAR(20) NOT NULL CHECK (source_type IN ('RECRUITMENT', 'CLUB_MATCH')),
    recruitment_id          UUID REFERENCES recruitment_posts(id) ON DELETE SET NULL,
    club_match_request_id   UUID,  -- Phase 3에서 FK 추가
    location_id             UUID NOT NULL REFERENCES schedule_locations(id) ON DELETE RESTRICT,
    start_at                TIMESTAMP NOT NULL,
    end_at                  TIMESTAMP NOT NULL,
    game_format             recruitment_game_format,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_match_time CHECK (start_at < end_at),
    CONSTRAINT chk_match_source CHECK (
        (source_type = 'RECRUITMENT' AND recruitment_id IS NOT NULL AND club_match_request_id IS NULL) OR
        (source_type = 'CLUB_MATCH' AND club_match_request_id IS NOT NULL AND recruitment_id IS NULL)
    )
);

CREATE INDEX idx_matches_source ON matches(source_type);
CREATE INDEX idx_matches_recruitment ON matches(recruitment_id) WHERE recruitment_id IS NOT NULL;
CREATE INDEX idx_matches_start_at ON matches(start_at);

CREATE TABLE match_participations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id        UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status          VARCHAR(20) NOT NULL CHECK (status IN ('ATTENDED', 'NO_SHOW')),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, user_id)
);

CREATE INDEX idx_match_participations_match ON match_participations(match_id);
CREATE INDEX idx_match_participations_user ON match_participations(user_id);

CREATE TABLE participation_reviews (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id            UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    reviewer_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    reviewee_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, reviewer_id, reviewee_id)
);

CREATE TABLE no_show_reports (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id            UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    reporter_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    reported_user_id    BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status              VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED')),
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
