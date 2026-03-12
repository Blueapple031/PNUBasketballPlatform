-- ============================================================
-- schedule_locations (매칭 장소 - 유동적 확장)
-- ============================================================
CREATE TABLE IF NOT EXISTS schedule_locations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    sort_order      INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_schedule_locations_sort ON schedule_locations(sort_order);

-- ============================================================
-- schedules (농구장 일정)
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
    location_id     UUID NOT NULL REFERENCES schedule_locations(id) ON DELETE RESTRICT,
    schedule_date   DATE NOT NULL,
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    status          schedule_status NOT NULL DEFAULT 'SCHEDULED',
    schedule_type   VARCHAR(50) NOT NULL DEFAULT 'REGULAR',
    title           VARCHAR(200),
    description     TEXT,
    match_id        UUID,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_schedule_time CHECK (start_time < end_time)
);

CREATE INDEX idx_schedules_location_id ON schedules(location_id);
CREATE INDEX idx_schedules_date ON schedules(schedule_date);
CREATE INDEX idx_schedules_location_date ON schedules(location_id, schedule_date);
CREATE INDEX idx_schedules_match_id ON schedules(match_id) WHERE match_id IS NOT NULL;

COMMENT ON TABLE schedule_locations IS '매칭 장소 (유동적 확장)';
COMMENT ON TABLE schedules IS '농구장 일정';
COMMENT ON COLUMN schedules.status IS 'AVAILABLE=비어있음, SCHEDULED=사용중, CANCELLED=사용 예정';
COMMENT ON COLUMN schedules.schedule_type IS 'REGULAR=일반, TRAINING=훈련(주간 반복)';
COMMENT ON COLUMN schedules.match_id IS '향후 매칭/모집 확정 시 연동';
