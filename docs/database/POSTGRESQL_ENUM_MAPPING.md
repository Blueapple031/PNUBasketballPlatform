# PostgreSQL Enum 타입 매핑 가이드

## 1. 왜 DB 타입 매칭 오류가 발생하는가?

### 원인

PostgreSQL에는 **네이티브 ENUM 타입**이 있고, JPA/Hibernate의 `@Enumerated(EnumType.STRING)`은 기본적으로 **VARCHAR(문자열)** 로 바인딩합니다.

```
Hibernate가 보내는 값:  'OPEN' (VARCHAR/character varying)
PostgreSQL 컬럼 타입:   recruitment_status (ENUM)
→ 타입 불일치! PostgreSQL은 암시적 변환을 허용하지 않음
```

### 에러 메시지

```
ERROR: column "status" is of type recruitment_status but expression is of type character varying
Hint: You will need to rewrite or cast the expression.
```

---

## 2. 해결 방법 (두 가지)

### 방법 A: `@JdbcType(PostgreSQLEnumJdbcType.class)` (현재 적용)

Hibernate 6 내장 타입으로, INSERT/UPDATE 시 PostgreSQL enum 타입으로 올바르게 바인딩합니다.

```java
@Enumerated(EnumType.STRING)
@JdbcType(PostgreSQLEnumJdbcType.class)
@Column(name = "status", nullable = false, columnDefinition = "recruitment_status")
private RecruitmentStatus status;
```

- **장점**: JPA 레벨에서 명시적, DB 스키마 변경 불필요
- **필수**: `columnDefinition`에 PostgreSQL enum 타입명 지정

### 방법 B: PostgreSQL implicit cast 등록

DB 마이그레이션에서 VARCHAR → enum 자동 변환을 허용합니다.

```sql
CREATE TYPE recruitment_status AS ENUM ('OPEN', 'CONFIRMED', 'CLOSED', 'CANCELLED');
CREATE CAST (character varying AS recruitment_status) WITH INOUT AS IMPLICIT;
```

- **장점**: `@Enumerated(EnumType.STRING)`만으로 동작
- **단점**: DB 스키마에 의존, enum 추가 시 cast 재등록 필요

---

## 3. 프로젝트 내 Enum 매핑 현황

| 엔티티 | 필드 | DB 컬럼 타입 | JPA 매핑 | 상태 |
|--------|------|--------------|----------|------|
| **RecruitmentPost** | gameFormat | recruitment_game_format | @JdbcType | ✅ 수정됨 |
| **RecruitmentPost** | status | recruitment_status | @JdbcType | ✅ 수정됨 |
| **RecruitmentApplication** | status | application_status | @JdbcType | ✅ 수정됨 |
| **ClubMatchRequest** | status | club_match_status | @JdbcType | ✅ 수정됨 |
| **Match** | gameFormat | recruitment_game_format | @JdbcType | ✅ 수정됨 |
| **Match** | sourceType | VARCHAR(20) CHECK | @Enumerated | ✅ 문제없음 |
| **ClubMember** | role | club_role | @Enumerated | ✅ implicit cast 있음 |
| **Schedule** | status | schedule_status | @Enumerated | ✅ implicit cast 있음 |
| **User** | loginType | VARCHAR(20) | @Enumerated | ✅ 문제없음 |
| **User** | position | VARCHAR(20) CHECK | @Enumerated | ✅ 문제없음 |
| **MatchParticipation** | status | VARCHAR(20) CHECK | @Enumerated | ✅ 문제없음 |
| **NoShowReport** | status | VARCHAR(20) CHECK | @Enumerated | ✅ 문제없음 |

---

## 4. 새 PostgreSQL enum 추가 시 체크리스트

1. **마이그레이션**에 `CREATE TYPE ... AS ENUM (...)` 추가
2. **엔티티**에 `@JdbcType(PostgreSQLEnumJdbcType.class)` + `columnDefinition = "enum_type_name"` 추가
3. **또는** implicit cast 등록: `CREATE CAST (character varying AS enum_type) WITH INOUT AS IMPLICIT`

---

## 5. 참고: VARCHAR vs ENUM

| DB 컬럼 정의 | Hibernate @Enumerated(STRING) | 동작 |
|-------------|------------------------------|------|
| `VARCHAR(20)` | ✅ | 정상 (문자열로 저장) |
| `VARCHAR(20) CHECK (x IN (...))` | ✅ | 정상 |
| `custom_enum` (PostgreSQL ENUM) | ❌ | **타입 불일치** → @JdbcType 필요 |
