-- ============================================================
-- polls (투표)
-- ============================================================

CREATE TABLE polls (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id         UUID NOT NULL UNIQUE REFERENCES posts(id) ON DELETE CASCADE,
    question        VARCHAR(500) NOT NULL,
    expires_at      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_polls_post_id ON polls(post_id);

-- ============================================================
-- poll_options (투표 선택지)
-- ============================================================

CREATE TABLE poll_options (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    poll_id         UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
    option_text     VARCHAR(200) NOT NULL,
    sort_order      INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_poll_options_poll_id ON poll_options(poll_id);

-- ============================================================
-- poll_votes (투표 참여 - 1인 1표)
-- ============================================================

CREATE TABLE poll_votes (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    poll_id         UUID NOT NULL REFERENCES polls(id) ON DELETE CASCADE,
    option_id       UUID NOT NULL REFERENCES poll_options(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_poll_votes_user UNIQUE (poll_id, user_id)
);

CREATE INDEX idx_poll_votes_poll_id ON poll_votes(poll_id);
CREATE INDEX idx_poll_votes_user_id ON poll_votes(user_id);
