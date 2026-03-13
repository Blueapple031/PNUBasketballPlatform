-- clubs 테이블에 wins 컬럼 추가 (동아리전 승리 수)
-- 매칭 확정 시 winner_club_id 기준으로 clubs.wins를 갱신하는 로직은 애플리케이션에서 처리
-- club_matches 테이블은 schemas/06_club_matches.sql 참고 (schedules 존재 시 별도 실행)

ALTER TABLE clubs ADD COLUMN IF NOT EXISTS wins INTEGER NOT NULL DEFAULT 0;
CREATE INDEX IF NOT EXISTS idx_clubs_wins ON clubs(wins DESC);
