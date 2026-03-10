-- ============================================================
-- 공통: 확장, ENUM
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE club_role AS ENUM ('PRESIDENT', 'MEMBER', 'OB', 'MANAGER');

-- Hibernate @Enumerated(EnumType.STRING)이 VARCHAR로 전송하므로,
-- PostgreSQL이 자동으로 club_role로 캐스팅할 수 있도록 implicit cast 등록
CREATE CAST (character varying AS club_role) WITH INOUT AS IMPLICIT;
