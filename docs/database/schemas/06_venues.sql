-- ============================================================
-- 매칭 시스템: ENUM 확장, venues, club_court_slots
-- ============================================================
-- 의존성: 00_common, 02_clubs
-- 06_venues.sql은 clubs 테이블 이후에 실행되어야 함

-- 게임 포맷 (팀당 인원)
CREATE TYPE game_format AS ENUM ('THREE_VS_THREE', 'FOUR_VS_FOUR', 'FIVE_VS_FIVE');

-- 매칭 목적
CREATE TYPE match_purpose AS ENUM (
    'CLUB_PRACTICE',   -- 동아리 연습경기
    'CASUAL',          -- 간단농구
    'GUEST_NEEDED',    -- 게스트 구함
    'FRIENDLY'         -- 친선경기
);

-- match_state ENUM 확장 (PENDING, CONFIRMED 추가)
ALTER TYPE match_state ADD VALUE IF NOT EXISTS 'PENDING';
ALTER TYPE match_state ADD VALUE IF NOT EXISTS 'CONFIRMED';

-- Hibernate @Enumerated(EnumType.STRING) 호환
CREATE CAST (character varying AS game_format) WITH INOUT AS IMPLICIT;
CREATE CAST (character varying AS match_purpose) WITH INOUT AS IMPLICIT;

-- ============================================================
-- venues (경기장/코트)
-- ============================================================
CREATE TABLE venues (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_venues_name ON venues(name);

-- ============================================================
-- club_court_slots (동아리별 코트 사용시간 - 매주 반복)
-- ============================================================
CREATE TABLE club_court_slots (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id         UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    venue_id        UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    day_of_week     SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_court_slot_time CHECK (start_time < end_time)
);

CREATE INDEX idx_club_court_slots_club ON club_court_slots(club_id);
CREATE INDEX idx_club_court_slots_venue ON club_court_slots(venue_id);
CREATE INDEX idx_club_court_slots_day ON club_court_slots(day_of_week);

-- ============================================================
-- matches 테이블 확장
-- ============================================================
ALTER TABLE matches ADD COLUMN IF NOT EXISTS game_format game_format DEFAULT 'FIVE_VS_FIVE';
ALTER TABLE matches ADD COLUMN IF NOT EXISTS venue_id UUID REFERENCES venues(id) ON DELETE SET NULL;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_purpose match_purpose DEFAULT 'CASUAL';
ALTER TABLE matches ADD COLUMN IF NOT EXISTS end_at TIMESTAMP;

-- ============================================================
-- venues 시드 데이터 (선택)
-- ============================================================
INSERT INTO venues (name, description) VALUES
    ('넉넉한터 본관코트', '부산대학교 넉넉한터 본관 코트'),
    ('넉넉한터 공원코트', '부산대학교 넉넉한터 공원 코트'),
    ('부산대역 농구코트', '부산대역 인근 농구 코트')
ON CONFLICT (name) DO NOTHING;
