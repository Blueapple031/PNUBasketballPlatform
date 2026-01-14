---

# Contributing to Basket Match App

프로젝트에 기여해 주셔서 감사합니다. 🙌
이 문서는 우리 팀이 **높은 품질의 코드를 유지**하고 **효율적으로 협업**하기 위해 반드시 준수해야 할 가이드라인입니다.
모든 팀원은 작업을 시작하기 전에 이 문서를 숙지해야 합니다.

---

## 1. 🌿 Branch Strategy (브랜치 전략)

우리는 **Git Flow를 변형한 전략**을 사용합니다.
모든 브랜치 이름은 **소문자와 하이픈(`-`)만 사용**합니다.

### 1.1 브랜치 종류

| 브랜치          | 설명                                                     |
| ------------ | ------------------------------------------------------ |
| `main`       | 제품(Production) 배포용 브랜치<br>직접 Push 불가, 배포 책임자만 Merge 가능 |
| `develop`    | 다음 버전을 위한 통합 브랜치 (기본 개발 브랜치)                           |
| `feat/*`     | 새로운 기능 개발 (예: `feat/login-auth`)                       |
| `fix/*`      | 버그 수정 (예: `fix/chat-socket-error`)                     |
| `refactor/*` | 코드 리팩토링 (기능 변경 없음)                                     |
| `docs/*`     | 문서 작업                                                  |

---

### 1.2 작업 흐름 (Workflow)

1. Jira 또는 GitHub Issue에서 티켓을 생성합니다.
2. `develop` 브랜치에서 작업 브랜치를 생성합니다.

```
git checkout -b feat/issue-id-description develop
```

3. 작업 완료 후 `develop` 브랜치로 Pull Request(PR)를 생성합니다.
4. Code Review 승인 후 Squash & Merge 합니다.

---

## 2. 📝 Commit Convention (커밋 컨벤션)

우리는 **Conventional Commits** 규칙을 따릅니다.
이 규칙을 지키지 않은 커밋은 PR 단계에서 반려될 수 있습니다.

### 2.1 커밋 메시지 구조

```
<type>(<scope>): <subject>

<body>

<footer>
```

---

### 2.2 Type (태그)

| Type     | 설명                |
| -------- | ----------------- |
| feat     | 새로운 기능 추가         |
| fix      | 버그 수정             |
| docs     | 문서 변경             |
| style    | 코드 포맷팅 (로직 변경 없음) |
| refactor | 코드 리팩토링           |
| test     | 테스트 코드 추가/수정      |
| chore    | 빌드/설정/패키지 관리      |

---

### 2.3 Scope (범위) — Monorepo 필수

변경된 모듈을 괄호 안에 명시합니다.

* `feat(fe)` : 프론트엔드 (Flutter)
* `fix(be)` : 백엔드 (Spring Boot)
* `chore(common)` : 공통 설정

---

### 2.4 Subject (제목) 규칙

* 영문 소문자로 시작 (한글 사용 시 통일)
* 동사 원형 사용 (`Add`, `Fix`, `Implement`)
* 마침표 사용 금지
* 50자 이내

---

### 2.5 Body & Footer

* Body (선택): 무엇을, 왜 변경했는지 설명
* Footer (권장): 이슈 번호 연결

예시:

* `Closes #123`
* `Refs #123`

#### 커밋 예시

```
feat(be): implement social login api

- Kakao, Google OAuth2 연동
- JWT 토큰 발급 로직 추가

Closes #42
```

---

## 3. 🚀 Pull Request (PR) Process

PR은 코드 품질을 보장하는 마지막 관문입니다.

### 3.1 PR 작성 규칙

* PR 제목은 커밋 컨벤션과 동일하게 작성
* PR 템플릿 모든 항목 작성

  * 변경 사항
  * 테스트 방법
  * 스크린샷 (UI 변경 시)
* PR 성격에 맞는 라벨 부착

---

### 3.2 Review & Merge 기준

* Reviewer

  * 프론트엔드: 프론트엔드 팀원 1명 이상
  * 백엔드: 백엔드 팀원 1명 이상
* Merge 조건

  * CI 통과
  * 최소 1명 Approve
  * 모든 Review Comment Resolve

---

## 4. 🎨 Code Style (코딩 컨벤션)

### Backend (Java)

* Google Java Style Guide 준수
* IntelliJ Formatter 사용 권장

### Frontend (Flutter / Dart)

* Effective Dart 스타일 준수
* `flutter analyze` 통과 필수

---

## 📚 References

* Conventional Commits
  [https://www.conventionalcommits.org/en/v1.0.0/](https://www.conventionalcommits.org/en/v1.0.0/)
* Git Flow
  [https://nvie.com/posts/a-successful-git-branching-model/](https://nvie.com/posts/a-successful-git-branching-model/)
* Google Java Style Guide
  [https://google.github.io/styleguide/javaguide.html](https://google.github.io/styleguide/javaguide.html)
* Google Code Review Guide
  [https://google.github.io/eng-practices/review/reviewer/](https://google.github.io/eng-practices/review/reviewer/)

---
