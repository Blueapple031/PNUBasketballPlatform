# 📋 게시판 API 명세 (Board API Specification)

> **넉터(NUKTU)** 게시판 REST API 명세서
> **버전**: 1.0.0  
> **최종 수정일**: 2026-02

---

## 📋 목차

1. [개요](#-개요)
2. [공통 사항](#-공통-사항)
3. [엔드포인트 요약](#-엔드포인트-요약)
4. [API 상세](#-api-상세)
5. [에러 응답](#-에러-응답)
6. [구현 목표](#-구현-목표)

---

## 🎯 개요

로그인한 사용자만 게시글 작성·게시 및 답글 작성이 가능한 게시판 REST API입니다. 목록·상세 조회는 비로그인도 가능합니다.

| 작업 | 인증 필요 |
|------|----------|
| 게시글 목록/상세 조회 | ❌ |
| 게시글 작성·수정·삭제 | ✅ (작성자 본인만 수정·삭제) |
| 답글 작성·수정·삭제 | ✅ (작성자 본인만 수정·삭제) |

---

## 📌 공통 사항

**Base URL**  
- 개발: `http://localhost:8080`  
- 운영: `https://api.basketball.pnu.ac.kr`

**Base Path**  
`/api/board`

**공통 헤더**  
`Content-Type: application/json`, `Accept: application/json`

**인증 헤더** (작성·수정·삭제 시)  
`Authorization: Bearer {access_token}`

**공통 응답 형식** (AUTH_API_SPEC.md 동일)  
- 성공: `{ "success": true, "data": { ... }, "message": "..." }`  
- 실패: `{ "success": false, "error": { "code", "message", "details" } }`

---

## 📌 엔드포인트 요약

| 번호 | 기능 | 메서드 | 엔드포인트 | 인증 |
|------|------|--------|------------|------|
| 1 | 게시글 목록 조회 | GET | `/api/board/posts/list` | ❌ |
| 2 | 게시글 상세 조회 | GET | `/api/board/posts/{postId}/detail` | ❌ |
| 3 | 게시글 작성 | POST | `/api/board/posts/create` | ✅ |
| 4 | 게시글 수정 | PUT | `/api/board/posts/{postId}/update` | ✅ |
| 5 | 게시글 삭제 | DELETE | `/api/board/posts/{postId}/delete` | ✅ |
| 6 | 답글 작성 | POST | `/api/board/posts/{postId}/comments/create` | ✅ |
| 7 | 답글 수정 | PUT | `/api/board/posts/{postId}/comments/{commentId}/update` | ✅ |
| 8 | 답글 삭제 | DELETE | `/api/board/posts/{postId}/comments/{commentId}/delete` | ✅ |

---

## 📄 API 상세

### 1. 게시글 목록 조회

- **엔드포인트**: `GET /api/board/posts/list`
- **URL 예시**: `GET http://localhost:8080/api/board/posts/list?page=0&size=10`
- **인증**: ❌

**쿼리 파라미터**

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| page | integer | ❌ | 0 | 페이지 번호 |
| size | integer | ❌ | 10 | 페이지당 개수 (최대 50) |

**성공 응답 (200)**  
`data`: `{ content: [ { postId, userId, authorNickname, title, content, viewCount, commentCount, createdAt, updatedAt } ], totalElements, totalPages, size, number, first, last }`

**에러**: 400 (잘못된 page/size)

---

### 2. 게시글 상세 조회

- **엔드포인트**: `GET /api/board/posts/{postId}/detail`
- **URL 예시**: `GET http://localhost:8080/api/board/posts/1/detail`
- **인증**: ❌  
- **동작**: 조회 시 조회수 +1, 삭제된 글은 404

**성공 응답 (200)**  
`data`: 게시글 상세 + `comments` 배열 (답글 목록, 삭제된 답글 제외)

**에러**: 404 POST_NOT_FOUND

---

### 3. 게시글 작성

- **엔드포인트**: `POST /api/board/posts/create`
- **URL 예시**: `POST http://localhost:8080/api/board/posts/create`
- **인증**: ✅

**요청 본문**

| 필드 | 타입 | 필수 | 제약 |
|------|------|------|------|
| title | string | ✅ | 1~200자 |
| content | string | ✅ | 1자 이상 |

**성공 응답 (201)**  
`data`: 생성된 게시글 (postId, userId, authorNickname, title, content, viewCount: 0, commentCount: 0, createdAt, updatedAt)

**에러**: 400 INVALID_INPUT, 401 UNAUTHORIZED

---

### 4. 게시글 수정

- **엔드포인트**: `PUT /api/board/posts/{postId}/update`
- **URL 예시**: `PUT http://localhost:8080/api/board/posts/1/update`
- **인증**: ✅ (작성자만)

**요청 본문**: `title`, `content` (동일 제약)

**성공 응답 (200)**  
`data`: 수정된 게시글

**에러**: 400, 401, 403 FORBIDDEN, 404 POST_NOT_FOUND

---

### 5. 게시글 삭제

- **엔드포인트**: `DELETE /api/board/posts/{postId}/delete`
- **URL 예시**: `DELETE http://localhost:8080/api/board/posts/1/delete`
- **인증**: ✅ (작성자만)  
- **동작**: 소프트 삭제 (`deleted_at` 설정)

**성공 응답 (200)**  
`data`: null

**에러**: 401, 403, 404 POST_NOT_FOUND

---

### 6. 답글 작성

- **엔드포인트**: `POST /api/board/posts/{postId}/comments/create`
- **URL 예시**: `POST http://localhost:8080/api/board/posts/1/comments/create`
- **인증**: ✅

**요청 본문**

| 필드 | 타입 | 필수 | 제약 |
|------|------|------|------|
| content | string | ✅ | 1~1000자 |

**성공 응답 (201)**  
`data`: 생성된 답글 (commentId, postId, userId, authorNickname, content, createdAt, updatedAt)

**에러**: 400, 401, 404 POST_NOT_FOUND

---

### 7. 답글 수정

- **엔드포인트**: `PUT /api/board/posts/{postId}/comments/{commentId}/update`
- **URL 예시**: `PUT http://localhost:8080/api/board/posts/1/comments/5/update`
- **인증**: ✅ (작성자만)

**요청 본문**: `content` (1~1000자)

**성공 응답 (200)**  
`data`: 수정된 답글

**에러**: 400, 401, 403, 404 POST_NOT_FOUND / COMMENT_NOT_FOUND

---

### 8. 답글 삭제

- **엔드포인트**: `DELETE /api/board/posts/{postId}/comments/{commentId}/delete`
- **URL 예시**: `DELETE http://localhost:8080/api/board/posts/1/comments/5/delete`
- **인증**: ✅ (작성자만)  
- **동작**: 소프트 삭제 (`deleted_at` 설정)

**성공 응답 (200)**  
`data`: null

**에러**: 401, 403, 404 POST_NOT_FOUND / COMMENT_NOT_FOUND

---

## ⚠️ 에러 응답

| HTTP | 에러 코드 | 설명 |
|------|----------|------|
| 400 | INVALID_INPUT | 필수/제약 위반 |
| 401 | UNAUTHORIZED | 인증 실패 |
| 403 | FORBIDDEN | 본인 글/답글 아님 |
| 404 | POST_NOT_FOUND | 게시글 없음/삭제됨 |
| 404 | COMMENT_NOT_FOUND | 답글 없음/삭제됨 |

---

## ✅ 구현 목표

### DB 스키마
- [ ] `posts` 테이블 (post_id, user_id, title, content, view_count, deleted_at, created_at, updated_at)
- [ ] `comments` 테이블 (comment_id, post_id, user_id, content, deleted_at, created_at, updated_at)
- [ ] Post, Comment 엔티티 및 마이그레이션

### API별 체크리스트
- [ ] `GET /api/board/posts/list` — 비로그인 조회, 페이지네이션, deleted_at 제외, 최신순
- [ ] `GET /api/board/posts/{postId}/detail` — 비로그인 조회, 조회수 증가, 답글 포함
- [ ] `POST /api/board/posts/create` — 인증 필수, JWT에서 작성자
- [ ] `PUT /api/board/posts/{postId}/update` — 작성자만 수정
- [ ] `DELETE /api/board/posts/{postId}/delete` — 작성자만, 소프트 삭제
- [ ] `POST /api/board/posts/{postId}/comments/create` — 인증 필수, 삭제글 404
- [ ] `PUT /api/board/posts/{postId}/comments/{commentId}/update` — 작성자만
- [ ] `DELETE /api/board/posts/{postId}/comments/{commentId}/delete` — 작성자만, 소프트 삭제

---

## 💡 참고 자료

- `SPEC/AUTH_API_SPEC.md` — 인증, 공통 응답, 에러 코드
- `backend/src/main/java/com/pnu/basketball/domain/User.java`
- `docs/database/schema.sql`
