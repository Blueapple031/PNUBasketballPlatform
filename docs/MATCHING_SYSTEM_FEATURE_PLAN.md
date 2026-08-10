# 매칭 시스템 기능 계획서

> **작성일**: 2026-03-16  
> **프로젝트**: 넉터(NUKTU)
> **핵심**: EXP 시스템, 게스트/번개 모집, 동아리 친선전, 리뷰 + 노쇼 관리

---

## 목차

1. [시스템 개요](#1-시스템-개요)
2. [공통 요구사항](#2-공통-요구사항)
3. [게스트/번개 모집](#3-게스트번개-모집)
4. [동아리 친선전](#4-동아리-친선전)
5. [경기 종료 후 리뷰 + 노쇼 시스템](#5-경기-종료-후-리뷰--노쇼-시스템)
6. [DB 및 도메인 설계](#6-db-및-도메인-설계)
7. [API 설계](#7-api-설계)
8. [구현 우선순위](#8-구현-우선순위)

---

## 1. 시스템 개요

### 1.1 매칭 유형

| 유형 | 점수 기록 | 경기 형식 | 설명 |
|------|----------|----------|------|
| **게스트/번개 모집** | ❌ (참여 이력만) | 3:3, 4:4, 5:5, 모이는대로 | 번개, 즉석 농구, 결원 보충 |
| **동아리 친선전** | ✅ 상세 기록 | 5:5만 | 팀 대 팀 공식 매치 |

### 1.2 핵심 가치

- **경험치(EXP) 시스템**: 게임할 때마다 경험치 누적. 등급/레벨은 나중에 EXP 구간으로 재미있게 나눌 수 있도록 **EXP만 저장**
- **닉네임**: 모든 사용자에게 닉네임 필수 (모집/리뷰에서 노출)
- **노쇼 페널티**: 모든 경기 공통 적용

### 1.3 모집글과 실제 경기 분리

> **모집글은 인원 모집을 위한 엔티티이며, 목표 인원 충족 및 확정 시 실제 일정/경기 엔티티로 승격 또는 연결될 수 있다.**

| 엔티티 | 역할 |
|--------|------|
| **RecruitmentPost** | 사람 모으는 글 (수정 여러 번 가능, 인원 부족 시 취소 가능) |
| **Match / ScheduledGame** | 실제 성사된 경기 (확정 시 생성) |
| **Participation** | 실제 참가 이력 (경기 단위로 기록) |

**플로우**:

```
모집글 → 확정 → 실제 경기(matches) 생성 → 일정(schedules)에 자동 등록 → 참가 이력 기록
```

- recruitment_posts.status=CONFIRMED만으로 처리하면 일정 탭, 장소 중복 체크 등에서 복잡해짐
- 확정 시 별도 `matches` 테이블에 경기를 생성하고, 참가 이력은 `matches` 기준으로 기록
- **matches 생성 시 `schedules` 테이블에도 일정을 자동 등록**하여 일정 탭과 연계
  - `schedules.match_id` = `matches.id` (기존 스키마에 이미 match_id 컬럼 존재)
  - `schedules.schedule_type` = 'MATCH'
  - `schedules.status` = 'SCHEDULED'
  - 일정 탭에서 기존 일반 일정과 매칭 확정 일정을 함께 표시

---

## 2. 공통 요구사항

### 2.1 사용자(User) 확장

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| **nickname** | varchar(30) | O | 닉네임 (앱 내 표시명, 모집/리뷰에 노출) |
| **position** | enum | O | 주 포지션 1개 (GUARD / FORWARD / CENTER). 추후 보조 포지션 다중 선택 확장 가능 |
| **exp** | int | O | 경험치 (누적) — DB에는 EXP만 저장 |
| **no_show_count** | int | O | 노쇼 누적 횟수 |
| **participation_count** | int | O | 참여 완료 횟수 |

**기존 User 필드**: real_name, email, wins, games, total_score 등 유지  
**닉네임 vs 실명**: real_name은 본명(인증용), nickname은 앱 내 활동용

> **nickname, position은 회원가입 중 "필수정보 입력" 단계에서 반드시 입력해야 한다.**  
> 기존 completeProfile 플로우에 nickname, position 필드를 추가한다.

> **레벨/등급은 DB에 저장하지 않음.**  
> 나중에 EXP 구간으로 재미있게 나눌 수 있음 (예: 0~99=루키, 100~299=슈터, 300~=올스타 등).  
> **체크/로직은 경험치(exp)만 사용.**

### 2.2 경험치(EXP) 시스템

| 항목 | 설명 |
|------|------|
| **경험치 부여** | 게스트/번개 참여 완료 시 +EXP, 동아리전 참여 시 +EXP (더 높음) |
| **등급/레벨** | DB에 저장 X. 필요 시 EXP 구간으로 앱에서 계산 |
| **노출** | 프로필, 모집글 신청자 목록에 "EXP 150 닉네임" 또는 "등급 닉네임" 형태 |

**경험치 부여 예시**

```
게스트/번개 참여 완료: +10 EXP
동아리전 참여 시: +30 EXP
(등급/레벨은 나중에 EXP 구간으로 재미있게 정의 가능)
```

---

## 3. 게스트/번개 모집

### 3.1 개요

- **점수 기록**: 하지 않음. "참여했었다" 이력만 저장
- **경기 형태**: 3:3, 4:4, 5:5, 모이는대로

### 3.2 필요한 정보

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| 시작 시각 | start_at | O | 경기 시작 (datetime) |
| 종료 시각 | end_at | O | 경기 종료 (datetime) — 장소 중복 체크, 일정 표시에 필요 |
| 장소 | location_id | O | **있는 장소에서 선택** (schedule_locations 참조) |
| 기본 인원 | base_members_count | O | 모집 생성 시점에 이미 확보된 인원 수 |
| 필요한 인원 | needed_members | O | 추가로 모집할 인원 수 |
| 포지션 | multi-select | △ | 가드/포워드/센터 우대 |
| 경기 형태 | enum | O | THREE_VS_THREE, FOUR_VS_FOUR, FIVE_VS_FIVE, FLEXIBLE |
| 모집 마감 시간 | datetime | △ | 마감 시각 |

### 3.3 필요 기능

#### 1) 모집 진행률 시각화

```
┌─────────────────────────────────────┐
│  현재 3 / 6명                        │
│  ████████████░░░░░░  50%            │
│  3명 더 모이면 확정!                 │
└─────────────────────────────────────┘
```

- 실시간 인원 수 반영
- 목표 인원 도달 여부는 **상태가 아닌 계산값** (`accepted_count >=needed_members`)
- "FULL" 뱃지는 UI에서만 표시, DB 상태로 관리하지 않음
- 모집자가 최종 확정 버튼 → `OPEN` → `CONFIRMED` → matches 생성

#### 2) 폼 기반 모집 신청

- 텍스트 게시판 X, 입력 필드 O
- 신청 시: 한줄 메시지 선택형 ("가드 가능", "바로 갈 수 있음" 등)
- 모집자: 신청자 프로필(닉네임, EXP, 참여율, 노쇼 횟수) 확인 후 수락/거절

#### 3) 경기 종료 후 리뷰 + 노쇼 신고

- 모든 매칭(게스트/번개, 동아리 친선전) 공통으로 적용
- 상세는 **5장 "경기 종료 후 리뷰 + 노쇼 팝업"** 참조

### 3.4 참여 이력 저장

| 테이블 | 설명 |
|--------|------|
| **matches** | 실제 확정된 경기 (모집글 확정 시 생성) |
| **match_participations** | 경기별 참가 이력 (점수 없음) — **matches** 참조 |
| - match_id | 실제 경기 ID |
| - user_id | |
| - status | ATTENDED / NO_SHOW |

---

## 4. 동아리 친선전

### 4.1 개요

- **점수 기록**: 상세 기록 (득점, 승패 등)
- **경기 형식**: 5:5만

### 4.2 필요한 정보

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| 신청 동아리 (홈팀) | club_id | O | 친선전을 신청하는 동아리 |
| 시작 시각 | start_at | O | 경기 시작 (datetime) |
| 종료 시각 | end_at | O | 경기 종료 (datetime) |
| 장소 | location_id | O | **있는 장소에서 선택** (schedule_locations 참조) |
| 상대 동아리 | club_id | △ | 지정 시 바로 매칭, 미지정 시 모집 |

### 4.3 참가 의사 기반 확정 조건

> **같은 동아리 소속인 5명 이상 모여야 상대 동아리로 지정 가능**

| 단계 | 설명 |
|------|------|
| 1 | 홈팀 대표가 친선전 신청 (날짜, 장소) |
| 2 | 동아리 멤버가 "참가 의사" 등록 |
| 3 | **5명 이상** 모이면 → 상대 동아리 지정 가능 (매칭 풀에 노출) |
| 4 | 상대 동아리도 5명 이상 모이면 → 매칭 확정 |
| 5 | 경기 진행 → 결과 입력 |

### 4.4 필요 기능

#### 1) 경기 후 결과 입력

- **입력 내용**: 홈팀 점수 N : 원정팀 점수 N
- **승인 플로우**: 
  1. 홈팀 대표가 결과 입력 (예: 72 : 68)
  2. 원정팀 대표가 결과 확인 및 승인
  3. **두 동아리 대표가 모두 승인** → 관리자 탭에서 최종 기록

#### 2) 관리자 탭

- 대표 양측 승인된 경기 목록
- 승인 시 `club_matches`에 기록, `clubs.wins` 업데이트
- 이력 추적 (누가 언제 승인했는지)

### 4.5 상태 흐름

```
[홈팀 신청] → [참가 의사 5명↑] → [상대 지정 가능]
    → [상대팀 매칭] → [양측 5명↑] → [경기 확정]
    → [경기 진행] → [결과 입력] → [양측 대표 승인] → [관리자 기록]
    → [경기 종료 후] → [리뷰 + 노쇼 팝업] (5장 참조)
```

---

## 5. 경기 종료 후 리뷰 + 노쇼 시스템

> **모든 매칭(게스트/번개, 동아리 친선전)에 공통 적용.**  
> matches 테이블에 경기가 생성된 이상, 종류 구분 없이 동일한 리뷰+노쇼 팝업이 뜬다.

### 5.1 리뷰 + 노쇼 팝업

경기 종료 시각(`end_at`) 이후 앱 접속 시 참가자에게 **리뷰 팝업**이 자동으로 뜬다.

**팝업 구조 (모바일 바텀시트/다이얼로그)**

```
┌──────────────────────────────────────────────┐
│  🏀 경기가 끝났어요! 함께한 사람들을 평가해주세요  │
│                                               │
│  ── 우리 팀 ──────────────────────────────── │
│  ┌────────────────────────────────────────┐  │
│  │  닉네임A (가드)          👍            │  │
│  │  닉네임B (포워드)        👍            │  │
│  │  닉네임C (센터)          👍            │  │
│  └────────────────────────────────────────┘  │
│                                               │
│  ── 상대 팀 ──────────────────────────────── │
│  ┌────────────────────────────────────────┐  │
│  │  닉네임D (가드)          👍            │  │
│  │  닉네임E (포워드)        👍            │  │
│  │  닉네임F (센터)          👍   ⚠️노쇼   │  │
│  └────────────────────────────────────────┘  │
│                                               │
│             [ 제출하기 ]                       │
└──────────────────────────────────────────────┘
```

**UX 원칙**

- **따봉(👍) 방식**: 좋았던 참가자에게만 👍를 남기는 방식이며, 별점/비추천 기능은 제공하지 않는다. (row 존재 = 추천, row 없음 = 미평가)
- **간단함**: 한 화면에서 모든 참가자 한 번에 평가
- **우리 팀 / 상대 팀** 구분 표시 (한 눈에 보기 쉽게)
- **노쇼 신고 버튼**: 각 참가자 옆에 "⚠️노쇼" 버튼 (안 나왔으면 누르기)
- 리뷰 제출은 **선택** (건너뛰기 가능), 노쇼 신고만 별도 가능

**타이밍**

- 경기 종료 시각(`end_at`) 이후 앱 접속 시 팝업 노출
- 제출 안 했으면 "내 매치" 탭에서 다시 접근 가능
- 리뷰 기한: 경기 종료 후 24시간 이내

**매칭 유형별 차이**

| 항목 | 게스트/번개 | 동아리 친선전 |
|------|------------|-------------|
| 팝업 구조 | 동일 | 동일 |
| 우리 팀/상대 팀 | 모집자 vs 참가자 또는 랜덤 편 | 홈팀 vs 원정팀 (동아리 기준) |
| 따봉 대상 | 모든 참가자 | 모든 참가자 |
| 노쇼 신고 | 모든 참가자 | 모든 참가자 |

### 5.2 노쇼 페널티

#### 적용 범위

- **모든 경기**에 적용 (게스트/번개, 동아리 친선전)

#### 노쇼 정의

| 상황 | 노쇼 여부 |
|------|-----------|
| 신청 후 수락됐는데 경기 불참 | O (노쇼) |
| 사전 취소 (N시간 전) | X (정상 취소) |
| 경기 당일 무단 불참 | O (노쇼) |

#### 페널티 내용

| 항목 | 설명 |
|------|------|
| **노쇼 카운트** | users.no_show_count 증가 |
| **프로필 노출** | "최근 10회 중 노쇼 0회" 등 표시 |
| **모집자 참고** | 신청자 목록에서 노쇼 횟수 확인 가능 |
| **제재** | N회 이상 시 모집 참여 제한 (선택) |

#### 노쇼 신고 방법

- **리뷰 팝업에 통합**: 경기 종료 후 리뷰 팝업에서 각 참가자 옆에 "⚠️노쇼" 버튼
- 안 나온 사람이 있으면 해당 버튼을 누르는 것만으로 신고 완료
- 별도 신고 화면 없이 리뷰와 같은 화면에서 처리

#### 필요 기능

| 기능 | 설명 |
|------|------|
| 노쇼 신고 | 리뷰 팝업에서 참가자별 "⚠️노쇼" 버튼 |
| 노쇼 확인 | **초기 MVP에서는 자동 확정 없이 관리자 확인 후 반영.** 추후 복수 참가자 신고(2인 이상 또는 과반) 시 자동 확정 후보 분류 도입 |
| 노쇼 이력 조회 | 사용자별 노쇼 이력 (관리자용) |

> **노쇼 신고 정책**: 노쇼 신고는 경기 종료 후 24시간 이내 가능하며, 동일 경기의 복수 참가자가 동일 사용자를 신고한 경우 자동 확정 후보로 분류한다. 단, 최종 반영은 운영 정책에 따라 관리자 확인 또는 최소 기준 충족 시 자동 확정한다. **초기 MVP에서는 자동 확정 없이 관리자 확인 후 반영한다.**

### 5.3 정책 요약 표

| 항목 | 기한 / 조건 |
|------|------------|
| 리뷰 제출 | 경기 종료 후 24시간 이내 |
| 노쇼 신고 | 경기 종료 후 24시간 이내 |
| 모집 취소 | 경기 시작 N시간 전까지 (운영 정책에 따라 결정) |
| 노쇼 확정 (MVP) | 관리자 확인 후 수동 반영 |
| 노쇼 확정 (추후) | 2인 이상 또는 과반 신고 시 자동 확정 후보 분류 |

### 5.4 경기 완료 처리 권한

`POST /api/matches/{id}/complete` 호출 권한:

| 매칭 유형 | 완료 처리 가능자 |
|----------|----------------|
| 게스트/번개 모집 | 모집자 또는 관리자 |
| 동아리 친선전 | 양팀 대표 중 1인 또는 관리자 |

### 5.5 일정 중복 체크 시점

| 시점 | 검증 내용 |
|------|----------|
| 모집 생성 시 | 사용자에게 가능한 슬롯인지 사전 안내 (경고 수준) |
| 모집 확정 시 | 서버에서 최종 중복 검증 후 match/schedule 생성 |
| 관리자 일정 생성 시 | 동일 검증 수행 |

> **최종 신뢰는 schedules 기준 서버 검증**이다. 모집 생성 시 안내는 UX 편의를 위한 것이며, 확정 시점에 서버에서 반드시 재검증한다.

---

## 6. DB 및 도메인 설계

### 6.1 DB 마이그레이션 시각화

#### 현재 (Before) → 이후 (After)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  users (현재)                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│  user_id (PK)  │ email  │ real_name  │ wins  │ games  │ total_score  │ ...  │ (fcm_token 등)     │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                    │
                                                    │  ALTER TABLE (컬럼 추가)
                                                    ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  users (이후)                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│  user_id (PK)  │ email  │ real_name  │ wins  │ games  │ total_score  │ ...  │ (기존)             │
│  + nickname    │ + position  │ + exp  │ + no_show_count  │ + participation_count  │ (신규)     │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### 마이그레이션 요약 (시각적)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  📦 1. users 테이블 변경 (ALTER)                                                                  │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                  │
│   users  ────────────────────────────────────────────────────────────────────────────────────   │
│                                                                                                  │
│   [기존 컬럼]                      [추가 컬럼]                                                  │
│   • user_id                        • nickname      VARCHAR(30) UNIQUE                           │
│   • email                          • position      VARCHAR(20) CHECK (GUARD/FORWARD/CENTER)     │
│   • real_name                      • exp           INTEGER DEFAULT 0                             │
│   • real_name                      • no_show_count INTEGER DEFAULT 0                             │
│   • wins, games, total_score       • participation_count INTEGER DEFAULT 0                      │
│   • ...                                                                                          │
│                                                                                                  │
│   ⚠️ level 컬럼 없음 — 등급/레벨은 나중에 exp 구간으로 앱에서 계산                               │
│                                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  📦 2. 신규 테이블 (CREATE)                                                         │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                  │
│   recruitment_posts ◄── users (author_id), schedule_locations (location_id)                      │
│         │                                                                                        │
│         ├── recruitment_applications ◄── users (applicant_id)                                    │
│         │                                                                                        │
│         └── (확정 시) matches 생성 ◄── recruitment_posts 또는 club_match_requests                │
│                   │                                                                              │
│                   ├── schedules (일정 자동 등록, schedules.match_id 단방향 참조)                    │
│                   ├── match_participations ◄── users (실제 경기 참가 이력)                        │
│                   │         └── participation_reviews                                            │
│                   └── no_show_reports (match_id 기준)                                             │
│                                                                                                  │
│   club_match_requests ◄────────── clubs (home/away), schedule_locations (location_id)           │
│         │                                                                                        │
│         ├── club_match_attendances ◄── users, clubs                                             │
│         │                                                                                        │
│         └── club_match_results ◄───── club_match_requests                                       │
│                                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│  📦 3. ER 관계도 (시각적)                                                                         │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                  │
│      users ───────────────────────────────────────────────────────────────────────────────────   │
│        │                                                                                         │
│        ├── author ───────────────────► recruitment_posts                                        │
│        │                                    │                                                    │
│        │                                    ├── applications (applicant)                         │
│        │                                    ├── match_participations                              │
│        │                                    │       └── participation_reviews                   │
│        │                                    └── no_show_reports                                  │
│        │                                                                                         │
│        └── club_members ─────────────► clubs                                                     │
│                                            │                                                     │
│                                            └── club_match_requests (home/away)                   │
│                                                    ├── club_match_attendances                    │
│                                                    └── club_match_results                        │
│                                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

#### 마이그레이션 실행 순서

```
※ schedule_locations는 schema.sql에 이미 존재 (넉넉한터, 온천천 등). 별도 생성 불필요.

1단계: users 확장
   └── V001__add_users_matching_fields.sql

2단계: 모집/매칭 관련 ENUM
   └── recruitment_game_format, recruitment_status, application_status, club_match_status

3단계: recruitment_posts, recruitment_applications
   └── V002__create_recruitment_posts.sql

4단계: club_match_requests, club_match_attendances, club_match_results
   └── V003__create_club_match_requests.sql

5단계: matches, match_participations, participation_reviews, no_show_reports
   └── V004__create_matches_and_participations.sql
```

### 6.2 User 확장 (SQL)

```sql
-- level 컬럼 없음. exp만 저장. 등급/레벨은 나중에 exp 구간으로 앱에서 계산
ALTER TABLE users ADD COLUMN IF NOT EXISTS nickname VARCHAR(30) UNIQUE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS position VARCHAR(20) CHECK (position IN ('GUARD', 'FORWARD', 'CENTER'));
ALTER TABLE users ADD COLUMN IF NOT EXISTS exp INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS no_show_count INTEGER NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS participation_count INTEGER NOT NULL DEFAULT 0;
-- nickname, position은 회원가입 필수정보 입력 단계(completeProfile)에서 필수
```

### 6.3 게스트/번개 모집

```sql
CREATE TYPE recruitment_game_format AS ENUM ('THREE_VS_THREE', 'FOUR_VS_FOUR', 'FIVE_VS_FIVE', 'FLEXIBLE');
-- 상태는 단순하게. FULL은 계산값(accepted_count >= needed_members)으로 UI 뱃지만 표시
CREATE TYPE recruitment_status AS ENUM ('OPEN', 'CONFIRMED', 'CLOSED', 'CANCELLED');

CREATE TABLE recruitment_posts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id       BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    start_at        TIMESTAMP NOT NULL,   -- 경기 시작 (datetime) — 장소 중복 체크, 일정 표시에 필요
    end_at          TIMESTAMP NOT NULL,   -- 경기 종료 (datetime)
    location_id     UUID NOT NULL REFERENCES schedule_locations(id) ON DELETE RESTRICT,  -- 있는 장소에서 선택
    base_members_count INTEGER NOT NULL,  -- 모집 생성 시점에 이미 확보된 기본 인원 수. 진행률 = base_members_count + accepted_count
    needed_members INTEGER NOT NULL,     -- 추가로 모집할 인원 수
    game_format     recruitment_game_format NOT NULL,
    deadline_at     TIMESTAMP,
    status          recruitment_status NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_recruitment_time CHECK (start_at < end_at)
);

CREATE TYPE application_status AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED');

CREATE TABLE recruitment_applications (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recruitment_id  UUID NOT NULL REFERENCES recruitment_posts(id) ON DELETE CASCADE,
    applicant_id    BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status          application_status NOT NULL DEFAULT 'PENDING',
    message         VARCHAR(200),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(recruitment_id, applicant_id)
);
```

### 6.4 동아리 친선전

```sql
CREATE TYPE club_match_status AS ENUM ('GATHERING', 'READY', 'MATCHED', 'CONFIRMED', 'DONE', 'CANCELLED');
-- GATHERING: 홈팀 인원 모집 중
-- READY:     홈팀 5인 이상 확보, 상대 지정 가능
-- MATCHED:   상대팀 지정 완료
-- CONFIRMED: 양팀 5인 이상 확보, 일정 확정
-- DONE:      경기 종료
-- CANCELLED: 취소

-- 친선전 신청 (홈팀이 먼저 생성)
CREATE TABLE club_match_requests (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    home_club_id    UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    start_at        TIMESTAMP NOT NULL,   -- 경기 시작 (datetime)
    end_at          TIMESTAMP NOT NULL,  -- 경기 종료 (datetime)
    location_id     UUID NOT NULL REFERENCES schedule_locations(id) ON DELETE RESTRICT,  -- 있는 장소에서 선택
    status          club_match_status NOT NULL DEFAULT 'GATHERING',
    away_club_id    UUID REFERENCES clubs(id) ON DELETE SET NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_club_match_request_time CHECK (start_at < end_at)
);

-- 동아리별 참가 의사 (5명 모이기)
CREATE TABLE club_match_attendances (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID NOT NULL REFERENCES club_match_requests(id) ON DELETE CASCADE,
    club_id         UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(request_id, club_id, user_id)
);

-- 경기 결과 (양측 승인 대기)
CREATE TABLE club_match_results (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id      UUID NOT NULL REFERENCES club_match_requests(id) ON DELETE CASCADE UNIQUE,
    home_score      INTEGER NOT NULL,
    away_score      INTEGER NOT NULL,
    home_approved   BOOLEAN NOT NULL DEFAULT FALSE,
    away_approved   BOOLEAN NOT NULL DEFAULT FALSE,
    admin_approved  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- club_matches는 양측+관리자 승인 후 최종 기록 (기존 테이블 활용)
```

### 6.5 matches (실제 경기) 및 참가 이력

```sql
-- 실제 확정된 경기 (모집글/동아리전 확정 시 생성)
CREATE TABLE matches (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_type         VARCHAR(20) NOT NULL CHECK (source_type IN ('RECRUITMENT', 'CLUB_MATCH')),
    recruitment_id      UUID REFERENCES recruitment_posts(id) ON DELETE SET NULL,   -- 게스트/번개 확정 시
    club_match_request_id UUID REFERENCES club_match_requests(id) ON DELETE SET NULL,  -- 동아리전 확정 시
    location_id         UUID NOT NULL REFERENCES schedule_locations(id) ON DELETE RESTRICT,
    start_at            TIMESTAMP NOT NULL,
    end_at              TIMESTAMP NOT NULL,
    game_format         recruitment_game_format,  -- 게스트/번개만 (동아리전은 5:5 고정)
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_match_time CHECK (start_at < end_at),
    CONSTRAINT chk_match_source CHECK (
        (source_type = 'RECRUITMENT' AND recruitment_id IS NOT NULL AND club_match_request_id IS NULL) OR
        (source_type = 'CLUB_MATCH' AND club_match_request_id IS NOT NULL AND recruitment_id IS NULL)
    )
);

-- ※ 매치 확정 시 서비스 로직에서 아래를 동시에 수행:
--   1. matches INSERT
--   2. schedules INSERT (schedule_type='MATCH', match_id=matches.id)
-- → schedules.match_id 단방향 참조. matches에서 schedule을 찾으려면 schedules.match_id로 역조회

-- 참가 이력 (실제 경기 기준)
CREATE TABLE match_participations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id        UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status          VARCHAR(20) NOT NULL CHECK (status IN ('ATTENDED', 'NO_SHOW')),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, user_id)
);

-- 리뷰 (따봉 방식: 👍를 누른 대상에 대해서만 row 생성)
-- row 존재 = 추천함, row 없음 = 미평가/추천 안 함
CREATE TABLE participation_reviews (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id            UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    reviewer_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    reviewee_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, reviewer_id, reviewee_id)
);

-- 노쇼 신고 (실제 경기 기준)
CREATE TABLE no_show_reports (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id        UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    reporter_id     BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    reported_user_id BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    status          VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'REJECTED')),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### 6.6 일정(schedules) 연동 상세

#### 현재 schedules 구조 (schema.sql 기준)

```
schedules (기존)
├── id              UUID PK
├── location_id     UUID FK → schedule_locations  (장소)
├── schedule_date   DATE                          (날짜)
├── start_time      TIME                          (시작 시간)
├── end_time        TIME                          (종료 시간)
├── status          ENUM (AVAILABLE, SCHEDULED, CANCELLED)
├── schedule_type   VARCHAR (REGULAR, TRAINING)   ← 'MATCH' 추가 예정
├── title           VARCHAR
├── description     TEXT
├── match_id        UUID                          ← 이미 존재 (현재 미사용)
├── created_at, updated_at
```

**핵심**: `schedule_type`에 `'MATCH'` 값 추가, `match_id`에 `matches.id` 연결만 하면 기존 구조 그대로 활용 가능.

#### 기존 엔티티 (Schedule.java)

```
Schedule.java (현재 구현)
├── location      → ScheduleLocationEntity (ManyToOne)
├── scheduleDate  → LocalDate
├── startTime     → LocalTime
├── endTime       → LocalTime
├── status        → ScheduleStatus (AVAILABLE, SCHEDULED, CANCELLED)
├── scheduleType  → String ("REGULAR", "TRAINING")
├── title, description
├── matchId       → UUID (이미 필드 존재, 현재 null)
```

#### 매치 확정 시 연동 플로우

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  1. 모집 확정 (recruitment_posts.status → CONFIRMED)                        │
│     또는 동아리전 확정 (club_match_requests.status → CONFIRMED)              │
│                                                                              │
│  2. matches 테이블에 INSERT                                                 │
│     ├── source_type, recruitment_id/club_match_request_id                    │
│     ├── location_id, start_at, end_at, game_format                           │
│                                                                              │
│  3. schedules 테이블에 INSERT (일정 자동 등록)                               │
│     ├── location_id    = matches.location_id                                 │
│     ├── schedule_date  = matches.start_at의 날짜 부분                        │
│     ├── start_time     = matches.start_at의 시간 부분                        │
│     ├── end_time       = matches.end_at의 시간 부분                          │
│     ├── status         = 'SCHEDULED'                                        │
│     ├── schedule_type  = 'MATCH'              ← 신규 값                      │
│     ├── title          = "게스트 모집 경기" 또는 "동아리전: A vs B" 자동 생성  │
│     ├── match_id       = matches.id           ← 기존 컬럼 활용              │
│     └── description    = 모집 정보 요약                                      │
│                                                                              │
│  ※ matches에서 schedule 조회 시: SELECT * FROM schedules WHERE match_id = :matchId │
└──────────────────────────────────────────────────────────────────────────────┘
```

#### 서비스 로직 (의사코드)

```java
@Transactional
public Match confirmRecruitment(UUID recruitmentId) {
    RecruitmentPost post = recruitmentPostRepository.findById(recruitmentId);
    post.setStatus(CONFIRMED);

    // 1) matches 생성
    Match match = Match.builder()
        .sourceType("RECRUITMENT")
        .recruitmentId(recruitmentId)
        .locationId(post.getLocationId())
        .startAt(post.getStartAt())
        .endAt(post.getEndAt())
        .gameFormat(post.getGameFormat())
        .build();
    matchRepository.save(match);

    // 2) schedules 생성 (기존 Schedule 엔티티 그대로 활용)
    Schedule schedule = Schedule.builder()
        .location(post.getLocation())
        .scheduleDate(post.getStartAt().toLocalDate())
        .startTime(post.getStartAt().toLocalTime())
        .endTime(post.getEndAt().toLocalTime())
        .status(ScheduleStatus.SCHEDULED)
        .scheduleType("MATCH")
        .title("게스트 모집 경기")
        .matchId(match.getId())
        .build();
    scheduleRepository.save(schedule);

    // 3) 수락된 신청자 → match_participations
    ...

    return match;
}
```

#### 일정 탭 표시 (기존 API 호환)

```
GET /api/schedules?startDate=2026-03-20&endDate=2026-03-26

응답 예시:
[
  { scheduleType: "REGULAR",  title: "정기 연습",      matchId: null,  ... },
  { scheduleType: "TRAINING", title: "주간 훈련",      matchId: null,  ... },
  { scheduleType: "MATCH",    title: "게스트 모집 경기", matchId: "abc", ... },  ← 신규
  { scheduleType: "MATCH",    title: "동아리전: RIV vs ABC", matchId: "def", ... }  ← 신규
]
```

- **기존 ScheduleController, ScheduleResponse 수정 불필요** — `scheduleType`과 `matchId`는 이미 응답에 포함
- 프론트엔드에서 `scheduleType === 'MATCH'`일 때 매칭 상세 화면으로 연결하는 분기만 추가

#### 장소/시간 중복 체크

```sql
-- 같은 장소, 같은 날짜에 시간이 겹치는 일정이 있는지 확인
SELECT COUNT(*) FROM schedules
WHERE location_id = :locationId
  AND schedule_date = :date
  AND status != 'CANCELLED'
  AND start_time < :endTime
  AND end_time > :startTime;
```

- 모집글 생성 시, 매치 확정 시 모두 이 체크 수행
- 기존 `schedules` 테이블 하나로 일반 일정 + 매칭 일정 통합 관리

#### 변경 영향 범위

| 대상 | 변경 내용 |
|------|----------|
| **DB (schedules)** | 변경 없음. `schedule_type`에 'MATCH' 값만 추가 사용, `match_id`는 이미 존재 |
| **DB (matches)** | 변경 없음. schedules.match_id로 단방향 참조 |
| **Schedule.java** | 변경 없음. `scheduleType`은 String, `matchId`는 UUID로 이미 대응 |
| **ScheduleResponse.java** | 변경 없음. `scheduleType`, `matchId` 이미 응답에 포함 |
| **ScheduleController** | 변경 없음. 기존 API가 `schedule_type='MATCH'`도 함께 조회 |
| **프론트엔드 (ScheduleScreen)** | `scheduleType === 'MATCH'` 분기 추가, 매칭 상세 화면 연결 |

### 6.7 포지션 (선택)

```sql
-- 포지션 enum 또는 테이블
CREATE TYPE position_type AS ENUM ('GUARD', 'FORWARD', 'CENTER');

-- recruitment_posts에 preferred_positions (배열 또는 junction)
CREATE TABLE recruitment_preferred_positions (
    recruitment_id  UUID NOT NULL REFERENCES recruitment_posts(id) ON DELETE CASCADE,
    position        position_type NOT NULL,
    PRIMARY KEY (recruitment_id, position)
);
```

---

## 7. API 설계

### 7.1 게스트/번개 모집

| Method | Path | 설명 |
|--------|------|------|
| POST | /api/recruitments | 모집글 생성 |
| GET | /api/recruitments | 목록 조회 (필터: start_at~end_at, 장소, 경기형태) |
| GET | /api/recruitments/{id} | 상세 (진행률 포함) |
| POST | /api/recruitments/{id}/apply | 신청 |
| POST | /api/recruitments/{id}/applications/{applicationId}/accept | 수락 |
| POST | /api/recruitments/{id}/applications/{applicationId}/reject | 거절 |
| POST | /api/recruitments/{id}/confirm | 모집 확정 → matches 생성 |
| POST | /api/matches/{id}/complete | 경기 완료 처리 |
| POST | /api/matches/{id}/review | 리뷰 + 노쇼 일괄 제출 (팝업에서 한 번에) |
| GET | /api/matches/{id}/review-form | 리뷰 팝업용 참가자 목록 (우리팀/상대팀 구분) |

### 7.2 실제 경기 (matches)

| Method | Path | 설명 |
|--------|------|------|
| GET | /api/matches | 내 확정 경기 목록 (일정 탭용) |
| GET | /api/matches/{id} | 경기 상세 |

### 7.3 동아리 친선전

| Method | Path | 설명 |
|--------|------|------|
| POST | /api/club-matches/requests | 친선전 신청 (홈팀) |
| POST | /api/club-matches/requests/{id}/attend | 참가 의사 등록 |
| GET | /api/club-matches/requests | 신청 목록 (5명↑인 것만 상대 지정 가능) |
| POST | /api/club-matches/requests/{id}/match | 상대 동아리 지정 |
| POST | /api/club-matches/requests/{id}/result | 결과 입력 |
| POST | /api/club-matches/requests/{id}/approve-result | 대표 승인 |
| GET | /api/admin/club-matches/pending | 관리자: 승인 대기 목록 |
| POST | /api/admin/club-matches/{id}/confirm | 관리자: 최종 기록 |

### 7.4 사용자

| Method | Path | 설명 |
|--------|------|------|
| PATCH | /api/users/me | 프로필 수정 (nickname, position 포함) |
| GET | /api/users/{id}/profile | 공개 프로필 (닉네임, 포지션, EXP, 참여율, 노쇼) |

---

## 8. 구현 우선순위

### Phase 1: 기반 구축

| 순서 | 항목 | 설명 |
|------|------|------|
| 1 | User 확장 | nickname, position, exp, no_show_count, participation_count |
| 2 | 경험치 로직 | 참여 완료 시 EXP 부여 (레벨/등급은 DB에 저장 X) |
| 3 | 필수정보 입력 | 회원가입 completeProfile 단계에 nickname, position 추가 |

### Phase 2: 게스트/번개 모집

| 순서 | 항목 | 설명 |
|------|------|------|
| 1 | recruitment_posts CRUD | 모집글 생성, 조회 (start_at, end_at) |
| 2 | 신청/수락/거절 | applications, 진행률 계산 |
| 3 | 진행률 시각화 | API 응답에 base_members_count + accepted_count / total 포함 |
| 4 | 확정 → matches + schedules 생성 | 목표 인원 충족 시 matches + 일정 자동 등록 |
| 5 | match_participations | 실제 경기 기준 참가 이력 저장 |
| 6 | 리뷰 기능 | participation_reviews (match 기준) |
| 7 | 노쇼 신고 | no_show_reports (match_id 기준), users.no_show_count 업데이트 |

### Phase 3: 동아리 친선전

| 순서 | 항목 | 설명 |
|------|------|------|
| 1 | club_match_requests | 친선전 신청 |
| 2 | club_match_attendances | 5명 모이기 |
| 3 | 상대 지정/매칭 | 5명↑ 시 상대 지정 가능 |
| 4 | club_match_results | 결과 입력, 양측 승인 |
| 5 | 관리자 승인 | club_matches 기록, clubs.wins 업데이트 |

### Phase 4: 노쇼 페널티 통합

| 순서 | 항목 | 설명 |
|------|------|------|
| 1 | 동아리전 노쇼 | club_match_attendances에서 실제 참석 여부 |
| 2 | 노쇼 신고 플로우 | 게스트/동아리전 공통 |
| 3 | 제재 정책 | N회 이상 시 제한 (선택) |

---

## 부록: 요약 체크리스트

- [ ] **닉네임 + 포지션** 필수 (User 확장, 회원가입 필수정보 입력 단계)
- [ ] **경험치(EXP)** 시스템 (경기 참여 시 EXP, 레벨/등급은 DB에 저장 X)
- [ ] **게스트/번개**: start_at/end_at, 장소(location_id), 인원, 포지션, 경기형태, 마감
- [ ] **진행률 시각화** (3/6명)
- [ ] **폼 기반 신청** + 수락/거절
- [ ] **경기 후 리뷰 팝업** (👍 누른 대상만 row 생성 + 노쇼 신고 통합, 우리팀/상대팀 구분)
- [ ] **동아리 친선전**: 5명↑ 모여야 상대 지정, 5:5만
- [ ] **결과 입력** → 양측 대표 승인 → 관리자 기록
- [ ] **노쇼 페널티** (모든 경기)
- [ ] **모집글 ↔ 실제 경기 분리** (확정 시 matches 생성 + schedules에 일정 자동 등록, 단방향 참조)
- [ ] **정책 표** (리뷰/노쇼 24시간, 모집 취소 기한, 완료 처리 권한)
- [ ] **일정 중복 체크** (생성 시 안내 + 확정 시 서버 검증)
