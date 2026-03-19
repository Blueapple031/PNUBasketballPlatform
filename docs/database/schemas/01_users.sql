-- ============================================================
-- users (회원)
-- ============================================================

CREATE TABLE users (
    user_id                 BIGSERIAL PRIMARY KEY,
    email                   VARCHAR(255) NOT NULL UNIQUE,
    password                VARCHAR(255),
    real_name               VARCHAR(50) NOT NULL,
    phone_number            VARCHAR(20),
    phone_number_verified_at TIMESTAMP,
    profile_image_url       VARCHAR(500),
    login_type              VARCHAR(20) NOT NULL DEFAULT 'EMAIL',
    google_id               VARCHAR(255) UNIQUE,
    kakao_id                VARCHAR(255) UNIQUE,
    date_of_birth           DATE,
    is_pnu_student          BOOLEAN NOT NULL DEFAULT false,
    department              VARCHAR(100),
    student_id              VARCHAR(20),
    wins                    INTEGER NOT NULL DEFAULT 0,
    games                   INTEGER NOT NULL DEFAULT 0,
    total_score             INTEGER NOT NULL DEFAULT 0,
    virtual_currency        INTEGER NOT NULL DEFAULT 0,
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    nickname                VARCHAR(30) UNIQUE,
    position                VARCHAR(20) CHECK (position IN ('GUARD', 'FORWARD', 'CENTER')),
    exp                     INTEGER NOT NULL DEFAULT 0,
    no_show_count           INTEGER NOT NULL DEFAULT 0,
    participation_count     INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_users_student_id_unique ON users(student_id) WHERE student_id IS NOT NULL AND student_id != '';
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_users_kakao_id ON users(kakao_id);
CREATE INDEX idx_users_real_name ON users(real_name);
CREATE INDEX idx_users_nickname ON users(nickname);
