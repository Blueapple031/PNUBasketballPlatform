-- 기존 테이블/ENUM 전부 삭제 후 schema.sql 적용용
-- 실행: psql -U postgres -d ddalba_DB -f docs/database/drop_all.sql

-- FK 때문에 자식 테이블부터 삭제
DROP TABLE IF EXISTS poll_votes CASCADE;
DROP TABLE IF EXISTS poll_options CASCADE;
DROP TABLE IF EXISTS polls CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS club_members CASCADE;
DROP TABLE IF EXISTS clubs CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ENUM 삭제
DROP TYPE IF EXISTS club_role CASCADE;
