# 게시판 관련 기능 개발 PR 요약

> **브랜치**: `feat/게시판_구현`  
> **작성일**: 2026-03

---

## 📋 개요

딸바(PNU Basketball Platform) 커뮤니티 게시판 기능 및 게시글 첨부 투표 기능을 구현했습니다.

---

## ✅ 구현 기능 목록

### 1. 게시판 기본 CRUD
- **게시글**: 목록 조회(페이지네이션), 상세 조회, 작성, 수정, 삭제
- **댓글**: 작성, 수정, 삭제
- **API**: `GET/POST /api/posts`, `GET/PUT/DELETE /api/posts/{id}`, `POST/PUT/DELETE /api/posts/{id}/comments/{commentId}`

### 2. 게시글 핀(공지) 기능
- 작성자가 게시글을 상단 고정 가능
- `PATCH /api/posts/{id}/pin` API
- 목록에서 공지 게시글이 최상단 노출

### 3. 게시글 첨부 투표 (1인 1표)
- 게시글 작성 시 투표 첨부 가능 (질문, 선택지 2~10개, 만료일)
- 투표 참여 API: `POST /api/posts/{postId}/polls/vote`
- 1인 1표, 재투표 불가, 만료 후 투표 불가
- 상세 조회 시 옵션별 득표수, 본인 투표 여부 포함

### 4. Flutter 커뮤니티 화면
- **CommunityScreen**: 게시글 목록
- **PostDetailScreen**: 게시글 상세, 댓글, 투표 UI
- **PostCreateScreen**: 글쓰기, 투표 첨부 UI

### 5. 관리자 게시판 관리
- 게시글 목록/상세/수정/삭제/공지 설정
- 댓글 작성/삭제
- 게시글 상세 모달에 투표 결과 표시

### 6. DB 스키마 정리
- `docs/database/schemas/` 도메인별 분리 (00_common ~ 05_polls)
- `schema.sql`에 polls DDL 통합
- `drop_all.sql`에 polls DROP 추가
- 마이그레이션: `docs/database/migrations/add_polls.sql`

---

## 📁 변경/추가 파일 요약

### Backend (Java/Spring Boot)
| 구분 | 파일 |
|------|------|
| **엔티티** | `Poll.java`, `PollOption.java`, `PollVote.java` |
| **Repository** | `PollRepository.java`, `PollOptionRepository.java`, `PollVoteRepository.java` |
| **DTO** | `PollCreateRequest.java`, `VoteRequest.java`, `PollResponse.java`, `PollOptionResponse.java`, `VoteResultResponse.java` |
| **Service** | `PollService.java`, `PollServiceImpl.java` |
| **수정** | `CreatePostRequest` (poll 필드), `PostDetailResponse` (poll 필드), `PostServiceImpl`, `PostService`, `PostController`, `AdminServiceImpl`, `ErrorCode` |

### Frontend (Flutter)
| 구분 | 파일 |
|------|------|
| **모델** | `post_model.dart` (PollModel, PollOptionModel, PollCreatePayload 추가) |
| **API** | `post_service.dart` (createPost poll, votePoll), `post_repository.dart`, `api_endpoints.dart` |
| **Provider** | `community_provider.dart` (createPost poll, votePoll) |
| **화면** | `post_create_screen.dart` (투표 첨부 UI), `post_detail_screen.dart` (투표 표시/참여 UI) |

### DB/문서
| 구분 | 파일 |
|------|------|
| **스키마** | `schemas/05_polls.sql`, `schema.sql` (polls DDL), `drop_all.sql` |
| **마이그레이션** | `migrations/add_polls.sql` |
| **관리자** | `admin/js/posts.js` (투표 결과 표시) |

---

## 🗄️ DB 스키마 (신규)

```
polls          - post_id(FK), question, expires_at
poll_options   - poll_id(FK), option_text, sort_order
poll_votes     - poll_id(FK), option_id(FK), user_id(FK), UNIQUE(poll_id, user_id)
```

---

## 🔧 API 변경/추가

| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | `/api/posts` | `poll` 필드 추가 (게시글 작성 시 투표 첨부) |
| GET | `/api/posts/{id}` | 응답에 `poll` 포함 |
| POST | `/api/posts/{postId}/polls/vote` | **신규** - 투표 참여 |

---

## 📱 사용 방법

1. **투표 첨부 글쓰기**: 글쓰기 화면에서 "투표 첨부" 스위치 ON → 질문·선택지(2~10개)·만료일 입력
2. **투표 참여**: 게시글 상세에서 선택지 "선택" 버튼 클릭
3. **결과 확인**: 투표 후 또는 만료 시 득표수·진행률 표시

---

## ⚠️ 마이그레이션

기존 DB에 polls 테이블 추가 시:

```bash
psql -U postgres -d ddalba_DB -f docs/database/migrations/add_polls.sql
```

---

## 📌 참고 문서

- `docs/POST_POLL_VOTING_PLAN.md` - 투표 기능 계획서
