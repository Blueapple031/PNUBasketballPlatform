-- schedule_locations 테이블 추가, schedules를 location_id FK로 마이그레이션
-- 실행: psql -U postgres -d ddalba_DB -f docs/database/migrations/add_schedule_locations.sql

-- 1. schedule_locations 테이블 생성
CREATE TABLE IF NOT EXISTS schedule_locations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL UNIQUE,
    sort_order      INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_schedule_locations_sort ON schedule_locations(sort_order);

-- 2. 기존 schedules에 location_id 컬럼 추가
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS location_id UUID REFERENCES schedule_locations(id) ON DELETE RESTRICT;

-- 3. MVP 기본 장소 삽입 (없을 경우만)
INSERT INTO schedule_locations (id, name, sort_order)
SELECT uuid_generate_v4(), '넉넉한터 본관 방향', 1
WHERE NOT EXISTS (SELECT 1 FROM schedule_locations WHERE name = '넉넉한터 본관 방향');
INSERT INTO schedule_locations (id, name, sort_order)
SELECT uuid_generate_v4(), '넉넉한터 공원 방향', 2
WHERE NOT EXISTS (SELECT 1 FROM schedule_locations WHERE name = '넉넉한터 공원 방향');
INSERT INTO schedule_locations (id, name, sort_order)
SELECT uuid_generate_v4(), '온천천 부산대역 농구장', 3
WHERE NOT EXISTS (SELECT 1 FROM schedule_locations WHERE name = '온천천 부산대역 농구장');

-- 4. 기존 location 문자열을 location_id로 마이그레이션
UPDATE schedules s
SET location_id = sl.id
FROM schedule_locations sl
WHERE s.location = sl.name AND s.location_id IS NULL;

-- 5. location_id NOT NULL, location 컬럼 제거
ALTER TABLE schedules ALTER COLUMN location_id SET NOT NULL;
ALTER TABLE schedules DROP COLUMN IF EXISTS location;

-- 6. 인덱스 정리
DROP INDEX IF EXISTS idx_schedules_location;
CREATE INDEX IF NOT EXISTS idx_schedules_location_id ON schedules(location_id);
CREATE INDEX IF NOT EXISTS idx_schedules_location_date ON schedules(location_id, schedule_date);
