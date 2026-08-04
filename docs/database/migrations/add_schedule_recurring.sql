-- Store an indefinite weekly training rule as one schedule row.
-- Existing TRAINING rows remain non-recurring so this migration never deletes
-- or changes previously registered schedule data.
ALTER TABLE schedules
    ADD COLUMN IF NOT EXISTS is_recurring BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_schedules_recurring
    ON schedules(is_recurring, schedule_date)
    WHERE is_recurring = TRUE;

COMMENT ON COLUMN schedules.is_recurring IS
    'TRUE이면 schedule_date부터 종료일 없이 매주 반복';
