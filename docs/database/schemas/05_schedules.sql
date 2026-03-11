-- ============================================================
-- schedules (농구장 일정)
-- MVP: 넉넉한터 본관 방향, 넉넉한터 공원 방향, 온천천 부산대역 농구장
-- 추후 Match/Recruitment 도메인과 match_id로 연동 가능
-- ============================================================
DO $$ BEGIN
    CREATE TYPE schedule_status AS ENUM ('AVAILABLE', 'SCHEDULED', 'CANCELLED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
DO $$ BEGIN
    CREATE CAST (character varying AS schedule_status) WITH INOUT AS IMPLICIT;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE schedules (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    location        VARCHAR(100) NOT NULL,
    schedule_date   DATE NOT NULL,
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    status          schedule_status NOT NULL DEFAULT 'SCHEDULED',
    title           VARCHAR(200),
    description     TEXT,
    match_id        UUID,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_schedule_time CHECK (start_time < end_time)
);

CREATE INDEX idx_schedules_location ON schedules(location);
CREATE INDEX idx_schedules_date ON schedules(schedule_date);
CREATE INDEX idx_schedules_location_date ON schedules(location, schedule_date);
CREATE INDEX idx_schedules_match_id ON schedules(match_id) WHERE match_id IS NOT NULL;

COMMENT ON TABLE schedules IS '농구장 일정 (MVP: 넉넉한터 본관/공원, 온천천 부산대역)';
COMMENT ON COLUMN schedules.status IS 'AVAILABLE=비어있음, SCHEDULED=사용중, CANCELLED=취소';
COMMENT ON COLUMN schedules.match_id IS '향후 매칭/모집 확정 시 연동';
