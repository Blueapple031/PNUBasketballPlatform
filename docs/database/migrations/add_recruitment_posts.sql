-- 매칭 시스템 Phase 2: 게스트/번개 모집 테이블

CREATE TYPE recruitment_game_format AS ENUM ('THREE_VS_THREE', 'FOUR_VS_FOUR', 'FIVE_VS_FIVE', 'FLEXIBLE');
CREATE TYPE recruitment_status AS ENUM ('OPEN', 'CONFIRMED', 'CLOSED', 'CANCELLED');
CREATE TYPE application_status AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED');

CREATE TABLE recruitment_posts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id       BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    start_at        TIMESTAMP NOT NULL,
    end_at          TIMESTAMP NOT NULL,
    location_id     UUID NOT NULL REFERENCES schedule_locations(id) ON DELETE RESTRICT,
    base_members_count INTEGER NOT NULL,
    needed_members  INTEGER NOT NULL,
    game_format     recruitment_game_format NOT NULL,
    deadline_at     TIMESTAMP,
    status          recruitment_status NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_recruitment_time CHECK (start_at < end_at)
);

CREATE INDEX idx_recruitment_posts_author ON recruitment_posts(author_id);
CREATE INDEX idx_recruitment_posts_status ON recruitment_posts(status);
CREATE INDEX idx_recruitment_posts_start_at ON recruitment_posts(start_at);
CREATE INDEX idx_recruitment_posts_location ON recruitment_posts(location_id);

CREATE TABLE recruitment_applications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recruitment_id  UUID NOT NULL REFERENCES recruitment_posts(id) ON DELETE CASCADE,
    applicant_id    BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status          application_status NOT NULL DEFAULT 'PENDING',
    message         VARCHAR(200),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(recruitment_id, applicant_id)
);

CREATE INDEX idx_recruitment_applications_recruitment ON recruitment_applications(recruitment_id);
CREATE INDEX idx_recruitment_applications_applicant ON recruitment_applications(applicant_id);
