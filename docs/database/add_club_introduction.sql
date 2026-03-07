-- clubs 테이블에 동아리 소개(introduction) 컬럼 추가
-- 기존 DB에 적용용
--
-- 실행: psql -U <user> -d ddalba_DB -f add_club_introduction.sql

ALTER TABLE clubs ADD COLUMN IF NOT EXISTS introduction TEXT;
