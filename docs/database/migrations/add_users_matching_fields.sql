-- 매칭 시스템 Phase 1: users 테이블 확장
-- nickname, position, exp, no_show_count, participation_count 추가

ALTER TABLE users ADD COLUMN IF NOT EXISTS nickname VARCHAR(30) UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS position VARCHAR(20) CHECK (position IN ('GUARD', 'FORWARD', 'CENTER'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS exp INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS no_show_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS participation_count INTEGER NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_users_nickname ON users(nickname);
