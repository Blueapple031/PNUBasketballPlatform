-- AWS RDS에 ddalba_DB 데이터베이스 생성
-- 실행 방법:
-- psql -h ddalba-rds.cjiaygo2w28p.ap-northeast-2.rds.amazonaws.com -U postgre -d postgres -f create-rds-database.sql

-- 1. ddalba_DB 데이터베이스 생성
CREATE DATABASE ddalba_DB
    WITH 
    OWNER = postgre
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- 2. 데이터베이스 코멘트
COMMENT ON DATABASE ddalba_DB IS '넉터(NUKTU) Database';

-- 데이터베이스 목록 확인
\l

-- ddalba_DB로 연결
\c ddalba_DB

-- 테이블 생성 (schema.sql 실행)
\i schema.sql
