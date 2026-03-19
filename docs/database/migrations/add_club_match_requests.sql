-- 매칭 시스템 Phase 3: 동아리 친선전 테이블

CREATE TYPE club_match_status AS ENUM ('GATHERING', 'READY', 'MATCHED', 'CONFIRMED', 'DONE', 'CANCELLED');

CREATE TABLE club_match_requests (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    home_club_id    UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    start_at        TIMESTAMP NOT NULL,
    end_at          TIMESTAMP NOT NULL,
    location_id     UUID NOT NULL REFERENCES schedule_locations(id) ON DELETE RESTRICT,
    status          club_match_status NOT NULL DEFAULT 'GATHERING',
    away_club_id    UUID REFERENCES clubs(id) ON DELETE SET NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_club_match_request_time CHECK (start_at < end_at)
);

CREATE INDEX idx_club_match_requests_home ON club_match_requests(home_club_id);
CREATE INDEX idx_club_match_requests_away ON club_match_requests(away_club_id) WHERE away_club_id IS NOT NULL;
CREATE INDEX idx_club_match_requests_status ON club_match_requests(status);

CREATE TABLE club_match_attendances (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID NOT NULL REFERENCES club_match_requests(id) ON DELETE CASCADE,
    club_id         UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(request_id, club_id, user_id)
);

CREATE INDEX idx_club_match_attendances_request ON club_match_attendances(request_id);

CREATE TABLE club_match_results (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID NOT NULL REFERENCES club_match_requests(id) ON DELETE CASCADE UNIQUE,
    home_score      INTEGER NOT NULL,
    away_score      INTEGER NOT NULL,
    home_approved   BOOLEAN NOT NULL DEFAULT FALSE,
    away_approved   BOOLEAN NOT NULL DEFAULT FALSE,
    admin_approved  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- matches 테이블에 club_match_request_id FK 추가 (Phase 2에서 생성된 테이블)
ALTER TABLE matches ADD CONSTRAINT fk_matches_club_match_request
    FOREIGN KEY (club_match_request_id) REFERENCES club_match_requests(id) ON DELETE SET NULL;
