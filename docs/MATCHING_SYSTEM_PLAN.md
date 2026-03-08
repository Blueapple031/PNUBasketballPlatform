# 📋 매칭 시스템 구현 계획서

> **딸바 (PNU Basketball Platform)** 농구 매칭 시스템 구현 계획서  
> **버전**: 1.0.0  
> **작성일**: 2026-03

---

## 📋 목차

1. [개요](#개요)
2. [핵심 요구사항 정리](#핵심-요구사항-정리)
3. [데이터베이스 설계](#데이터베이스-설계)
4. [API 설계](#api-설계)
5. [Backend 구현 계획](#backend-구현-계획)
6. [Frontend 구현 계획](#frontend-구현-계획)
7. [일정 화면 및 달력 기능](#일정-화면-및-달력-기능)
8. [매칭 라이프사이클](#매칭-라이프사이클)
9. [작업 일정](#작업-일정)

---

## 🎯 개요

### 배경 및 목적

- **매칭 시스템**: 동아리·개인 간 농구 경기 매칭을 생성·조회·확정하는 기능
- **일정 통합**: 동아리별 넉넉한터 코트 사용시간 확인, 확정된 매칭 일정 표시
- **유연한 매칭**: 게임 종류·장소·목적·시간을 고려한 매칭 생성

### 목표

1. **매칭 생성**: 게임 종류(3:3, 4:4, 5:5), 장소, 목적, 시간 지정
2. **장소(코트) 관리**: 넉넉한터 본관코트, 넉넉한터 공원코트, 부산대역 농구코트 등
3. **동아리 코트 사용시간**: 동아리별 넉넉한터 코트 고정 사용시간 등록·조회
4. **일정 달력**: 매주 동아리 코트 사용시간 확인, 확정 매칭 일정 표시
5. **매칭 확정**: 인원 모집 완료 시 매칭 확정 → 일정에 추가

---

## 📌 핵심 요구사항 정리

| 구분 | 항목 | 설명 |
|------|------|------|
| **게임 종류** | 3:3, 4:4, 5:5 | 팀당 인원 수 (game_format) |
| **게임 장소** | 넉넉한터 본관코트, 넉넉한터 공원코트, 부산대역 농구코트 등 | venues 테이블로 관리 |
| **게임 목적** | 동아리 연습경기, 간단농구, 게스트 구함 등 | match_purpose ENUM 또는 코드 테이블 |
| **게임 시간** | 0월 0일 00시~00시 | start_time, end_time (또는 scheduled_at + duration_minutes) |
| **동아리 코트 사용시간** | 매주 고정 시간대 | club_court_slots (club_id, venue_id, day_of_week, start_time, end_time) |
| **일정 달력** | 네비게이션 "일정" 탭 | 매주 동아리 코트 사용시간 + 확정된 매칭 표시 |
| **매칭 확정** | 인원 모집 완료 시 | PENDING → CONFIRMED 전환, 일정에 추가 |

---

## 🗄️ 데이터베이스 설계

### 1. ERD 개요

```
venues (경기장/코트)
├── id (PK, UUID)
├── name (VARCHAR)           -- "넉넉한터 본관코트", "부산대역 농구코트" 등
├── description (TEXT)       -- 선택
└── created_at

club_court_slots (동아리별 코트 사용시간 - 매주 반복)
├── id (PK, UUID)
├── club_id (FK → clubs)
├── venue_id (FK → venues)
├── day_of_week (INT 0~6)    -- 0=일요일, 1=월요일, ...
├── start_time (TIME)        -- 14:00
├── end_time (TIME)          -- 16:00
└── created_at

matches (매칭 - 기존 확장)
├── id (PK)
├── match_type (FORMAL/QUICK)
├── game_format (3, 4, 5)    -- 3:3, 4:4, 5:5
├── venue_id (FK → venues)   -- 신규
├── match_purpose (ENUM)     -- 신규: CLUB_PRACTICE, CASUAL, GUEST_NEEDED 등
├── scheduled_at             -- 시작 시각
├── end_at                   -- 종료 시각 (신규)
├── home_club_id, away_club_id, created_by, location, max_players_per_team
├── state (PENDING 추가)      -- SCHEDULED, PENDING, READY, ONGOING, DONE, CANCELLED
└── ...
```

### 2. ENUM 확장

```sql
-- 게임 포맷 (팀당 인원)
CREATE TYPE game_format AS ENUM ('THREE_VS_THREE', 'FOUR_VS_FOUR', 'FIVE_VS_FIVE');

-- 매칭 목적
CREATE TYPE match_purpose AS ENUM (
    'CLUB_PRACTICE',   -- 동아리 연습경기
    'CASUAL',          -- 간단농구
    'GUEST_NEEDED',    -- 게스트 구함
    'FRIENDLY'         -- 친선경기
);

-- match_state 확장 (PENDING 추가)
-- SCHEDULED: 예정됨 (기존)
-- PENDING: 모집 중 (인원 미달)
-- CONFIRMED: 확정됨 (인원 충족, 일정에 표시)
-- READY, ONGOING, DONE, CANCELLED (기존)
```

### 3. 스키마 DDL

```sql
-- ============================================================
-- venues (경기장/코트)
-- ============================================================
CREATE TABLE venues (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100) NOT NULL,
    description     TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_venues_name ON venues(name);

-- ============================================================
-- club_court_slots (동아리별 코트 사용시간 - 매주 반복)
-- ============================================================
CREATE TABLE club_court_slots (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id         UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    venue_id        UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    day_of_week     SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time      TIME NOT NULL,
    end_time        TIME NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_court_slot_time CHECK (start_time < end_time)
);

CREATE INDEX idx_club_court_slots_club ON club_court_slots(club_id);
CREATE INDEX idx_club_court_slots_venue ON club_court_slots(venue_id);
CREATE INDEX idx_club_court_slots_day ON club_court_slots(day_of_week);

-- ============================================================
-- matches 테이블 확장 (마이그레이션)
-- ============================================================
-- game_format, venue_id, match_purpose, end_at, state(PENDING/CONFIRMED) 추가
ALTER TABLE matches ADD COLUMN IF NOT EXISTS game_format game_format DEFAULT 'FIVE_VS_FIVE';
ALTER TABLE matches ADD COLUMN IF NOT EXISTS venue_id UUID REFERENCES venues(id) ON DELETE SET NULL;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS match_purpose match_purpose DEFAULT 'CASUAL';
ALTER TABLE matches ADD COLUMN IF NOT EXISTS end_at TIMESTAMP;
-- match_state ENUM에 PENDING, CONFIRMED 추가 필요
```

### 4. 제약 조건

| 제약 | 설명 |
|------|------|
| `club_court_slots.day_of_week` | 0(일)~6(토) |
| `club_court_slots.start_time < end_time` | 종료 시각이 시작 시각보다 커야 함 |
| `matches.end_at` | scheduled_at 이후여야 함 (애플리케이션 레벨 검증) |
| 동일 venue, 동일 시간대 중복 | club_court_slots 또는 matches에서 충돌 검증 필요 |

---

## 🔧 API 설계

### 1. 경기장(Venue) API

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/venues` | 경기장 목록 조회 |
| GET | `/api/venues/{id}` | 경기장 상세 조회 |

### 2. 동아리 코트 사용시간 API

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/clubs/{clubId}/court-slots` | 동아리별 코트 사용시간 목록 |
| POST | `/api/clubs/{clubId}/court-slots` | 코트 사용시간 등록 (동아리 관리자) |
| PUT | `/api/clubs/{clubId}/court-slots/{slotId}` | 수정 |
| DELETE | `/api/clubs/{clubId}/court-slots/{slotId}` | 삭제 |

### 3. 매칭 API

| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | `/api/matches` | 매칭 생성 |
| GET | `/api/matches` | 매칭 목록 (필터: 상태, 날짜, 장소, 게임종류 등) |
| GET | `/api/matches/{id}` | 매칭 상세 |
| PATCH | `/api/matches/{id}/confirm` | 매칭 확정 (인원 충족 시) |
| PATCH | `/api/matches/{id}/cancel` | 매칭 취소 |
| POST | `/api/matches/{id}/join` | 매칭 참가 신청 (QUICK 매치) |

### 4. 일정/달력 API

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/schedule/court-slots` | 주간 동아리 코트 사용시간 (쿼리: year, week 또는 startDate, endDate) |
| GET | `/api/schedule/confirmed-matches` | 확정된 매칭 목록 (쿼리: startDate, endDate, clubId?) |

### 5. 매칭 생성 요청 예시

```json
{
  "matchType": "FORMAL",
  "gameFormat": "FIVE_VS_FIVE",
  "venueId": "uuid",
  "matchPurpose": "CLUB_PRACTICE",
  "scheduledAt": "2026-03-15T14:00:00",
  "endAt": "2026-03-15T16:00:00",
  "homeClubId": "uuid",
  "awayClubId": "uuid"
}
```

```json
{
  "matchType": "QUICK",
  "gameFormat": "THREE_VS_THREE",
  "venueId": "uuid",
  "matchPurpose": "GUEST_NEEDED",
  "scheduledAt": "2026-03-16T18:00:00",
  "endAt": "2026-03-16T19:30:00",
  "maxPlayersPerTeam": 3
}
```

---

## 🔧 Backend 구현 계획

### 1단계: DB 마이그레이션

| 파일 | 내용 |
|------|------|
| `docs/database/schemas/06_venues.sql` | venues, club_court_slots |
| `docs/database/migrations/add_matching_system.sql` | 기존 DB 마이그레이션 |
| `match_state` ENUM 확장 | PENDING, CONFIRMED 추가 |

### 2단계: 도메인 모델

| 파일 | 작업 |
|------|------|
| `Venue.java` | 신규 - id, name, description |
| `ClubCourtSlot.java` | 신규 - club, venue, dayOfWeek, startTime, endTime |
| `Match.java` | 확장 - gameFormat, venue, matchPurpose, endAt |
| `GameFormat.java` | 신규 ENUM |
| `MatchPurpose.java` | 신규 ENUM |
| `MatchState` | PENDING, CONFIRMED 추가 |

### 3단계: Repository

| 파일 | 작업 |
|------|------|
| `VenueRepository.java` | findAll, findById |
| `ClubCourtSlotRepository.java` | findByClubId, findByVenueIdAndDayOfWeek |
| `MatchRepository` | 확장 - findByState, findByScheduledAtBetween, findByVenueId |

### 4단계: Service

| 파일 | 작업 |
|------|------|
| `VenueService` | 목록/상세 조회 |
| `ClubCourtSlotService` | CRUD, 주간 조회 |
| `MatchService` | 생성, 확정, 취소, 참가 신청 |
| `ScheduleService` | 주간 코트 사용시간, 확정 매칭 조회 |

### 5단계: Controller

| 파일 | 작업 |
|------|------|
| `VenueController` | GET /venues |
| `ClubCourtSlotController` | CRUD (club 소속 검증) |
| `MatchController` | CRUD, confirm, cancel, join |
| `ScheduleController` | GET /schedule/court-slots, /schedule/confirmed-matches |

---

## 📱 Frontend 구현 계획

### 1단계: 모델

| 파일 | 작업 |
|------|------|
| `venue_model.dart` | VenueModel |
| `club_court_slot_model.dart` | ClubCourtSlotModel |
| `match_model.dart` | MatchModel 확장 (gameFormat, venue, matchPurpose, endAt) |

### 2단계: API

| 파일 | 작업 |
|------|------|
| `venue_service.dart` | getVenues |
| `club_service.dart` | getCourtSlots, createCourtSlot, ... |
| `match_service.dart` | createMatch, getMatches, confirmMatch, joinMatch |
| `schedule_service.dart` | getCourtSlotsWeekly, getConfirmedMatches |

### 3단계: 화면

| 화면 | 작업 |
|------|------|
| `ScheduleScreen` | PlaceholderScreen 대체 - 달력/주간 뷰 |
| `MatchCreateScreen` | 매칭 생성 (게임종류, 장소, 목적, 시간 선택) |
| `MatchDetailScreen` | 매칭 상세, 참가 신청, 확정 버튼 |
| `MatchListScreen` | 매칭 목록 (필터) |

### 4단계: 일정 탭

- `root_screen.dart`: PlaceholderScreen → ScheduleScreen 교체
- ScheduleScreen: 주간 달력 + 동아리 코트 사용시간 + 확정 매칭 표시

---

## 📅 일정 화면 및 달력 기능

### 1. 화면 구성

```
┌─────────────────────────────────────┐
│  일정                        [주간] │
├─────────────────────────────────────┤
│  ◀ 2026년 3월 2주 (3/9~3/15)  ▶    │
├─────────────────────────────────────┤
│  [탭: 전체 | 내 동아리 | 코트별]     │
├─────────────────────────────────────┤
│  일   월   화   수   목   금   토   │
│  9   10  11  12  13  14  15   │
│  ─────────────────────────────     │
│  · 넉넉한터 본관 A동아리 14~16시     │
│  · 부산대역 B동아리 18~20시         │
│  · [확정] A vs B 14:00 (넉넉한터)   │
└─────────────────────────────────────┘
```

### 2. 표시 데이터

| 구분 | 데이터 소스 | 표시 내용 |
|------|-------------|-----------|
| **동아리 코트 사용시간** | club_court_slots | "넉넉한터 본관코트 - OO동아리 14:00~16:00" |
| **확정 매칭** | matches (state=CONFIRMED) | "A동아리 vs B동아리 14:00 (넉넉한터 본관)" |

### 3. 주간 조회 로직

- `GET /api/schedule/court-slots?year=2026&week=11`  
  → 해당 주의 요일(0~6)에 맞는 club_court_slots 반환
- `GET /api/schedule/confirmed-matches?startDate=2026-03-09&endDate=2026-03-15`  
  → scheduled_at이 해당 기간 내인 CONFIRMED 매칭 반환

---

## 🔄 매칭 라이프사이클

```
[매칭 생성] → PENDING (모집 중)
     │
     ├── 인원 충족 → [확정] → CONFIRMED (일정에 표시)
     │                            │
     │                            └── [경기 진행] → READY → ONGOING → DONE
     │
     └── [취소] → CANCELLED
```

| 상태 | 설명 |
|------|------|
| PENDING | 매칭 생성됨, 인원 모집 중 |
| CONFIRMED | 인원 충족, 확정됨, 일정에 표시 |
| SCHEDULED | (기존) 예정됨 (FORMAL 매치 등에서 바로 확정 시) |
| READY | 시작 직전 |
| ONGOING | 진행 중 |
| DONE | 종료됨 |
| CANCELLED | 취소됨 |

### 확정 조건

- **FORMAL 매치**: home_club, away_club 지정 시 → 생성 시점에 CONFIRMED 또는 SCHEDULED 가능
- **QUICK 매치**: max_players_per_team × 2 인원 충족 시 → CONFIRMED 전환

---

## 📅 작업 일정

### Phase 1: DB 및 도메인 (1일)

| 작업 |
|------|
| venues, club_court_slots 스키마 작성 |
| match_state, game_format, match_purpose ENUM 추가 |
| matches 테이블 확장 (game_format, venue_id, match_purpose, end_at) |
| Venue, ClubCourtSlot 엔티티, Match 엔티티 확장 |
| Repository 생성 |

### Phase 2: Backend API (2일)

| 작업 |
|------|
| VenueService, ClubCourtSlotService |
| MatchService 확장 (생성, 확정, 취소) |
| ScheduleService (주간 코트 사용시간, 확정 매칭) |
| Controller 구현 |
| 단위 테스트 |

### Phase 3: Frontend - 일정 화면 (1.5일)

| 작업 |
|------|
| ScheduleScreen 구현 (주간 달력 뷰) |
| 동아리 코트 사용시간 표시 |
| 확정 매칭 표시 |
| root_screen PlaceholderScreen → ScheduleScreen 교체 |

### Phase 4: Frontend - 매칭 생성/관리 (1.5일)

| 작업 |
|------|
| MatchCreateScreen (게임종류, 장소, 목적, 시간) |
| MatchListScreen, MatchDetailScreen |
| 매칭 확정/참가 UI |

### Phase 5: 동아리 코트 사용시간 관리 (0.5일)

| 작업 |
|------|
| 동아리 상세 또는 설정 화면에서 코트 사용시간 CRUD |
| 관리자 페이지에서 venues, club_court_slots 관리 (선택) |

**총 예상 기간**: 약 6~7일

---

## 📝 참고 사항

- **venue 초기 데이터**: 넉넉한터 본관코트, 넉넉한터 공원코트, 부산대역 농구코트 등 시드 데이터 필요
- **시간대 충돌**: 동일 venue, 동일 시간대에 여러 club_court_slots 또는 matches가 겹치지 않도록 검증
- **일정 권한**: 본인 소속 동아리 코트 사용시간만 조회 vs 전체 공개 (정책 결정 필요)
- **알림**: 매칭 확정 시 참가자에게 푸시 알림 (추후 확장)

---

**문서 작성일**: 2026년 3월  
**작성자**: 딸바 개발팀
