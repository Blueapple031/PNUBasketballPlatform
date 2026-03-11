-- schedule_type 컬럼 추가 (REGULAR: 일반, TRAINING: 훈련)
ALTER TABLE schedules ADD COLUMN IF NOT EXISTS schedule_type VARCHAR(50) NOT NULL DEFAULT 'REGULAR';
COMMENT ON COLUMN schedules.schedule_type IS 'REGULAR=일반, TRAINING=훈련(주간 반복)';
