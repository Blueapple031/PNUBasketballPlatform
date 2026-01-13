# Contributing to Basket Match App

프로젝트에 기여해 주셔서 감사합니다.
이 문서는 우리 팀이 **높은 품질의 코드를 유지**하고 **효율적으로 협업**하기 위해 반드시 준수해야 할 가이드라인입니다.
모든 팀원은 작업 전 이 문서를 숙지해야 합니다.

---

## 1. 🌿 Branch Strategy (브랜치 전략)

우리는 **Git Flow**를 변형한 전략을 사용하며, 모든 브랜치명은 소문자와 하이픈(`-`)만을 사용합니다.

### 1.1 브랜치 종류
* **main**: 제품(Production) 배포용 브랜치. (직접 Push 불가, 배포 책임자만 Merge 가능)
* **develop**: 다음 버전을 위한 통합 브랜치. (평소 개발의 기준점)
* **feat/**: 새로운 기능 개발 (예: `feat/login-auth`)
* **fix/**: 버그 수정 (예: `fix/chat-socket-error`)
* **refactor/**: 코드 리팩토링 (기능 변경 없음)
* **docs/**: 문서 작업

### 1.2 작업 흐름 (Workflow)
1.  Jira/GitHub Issue에서 티켓을 생성합니다.
2.  `develop` 브랜치에서 새로운 기능 브랜치를 생성합니다.
    * `git checkout -b feat/issue-id-description develop`
3.  작업 완료 후 `develop` 브랜치로 **Pull Request(PR)**를 생성합니다.
4.  동료의 **Code Review(승인)**를 받은 후 Squash & Merge 합니다.

---

## 2. 📝 Commit Convention (커밋 컨벤션)

우리는 **[Conventional Commits](https://www.conventionalcommits.org/)** 표준을 따릅니다.
이 규칙을 지키지 않은 커밋은 PR 단계에서 반려될 수 있습니다.

### 2.1 커밋 메시지 구조
<type>(<scope>): <subject>

<body>

<footer>
2.2 Type (태그)태그설명feat새로운 기능 추가 (Features)fix버그 수정 (Bug Fixes)docs문서 변경 (Documentation)style코드 포맷팅, 세미콜론 누락 등 (비즈니스 로직 변경 없음)refactor코드 리팩토링 (기능 추가나 버그 수정이 아님)test테스트 코드 추가 및 리팩토링chore빌드 태스크 업데이트, 패키지 매니저 설정 등 (소스 코드 변경 없음)2.3 Scope (범위) - Monorepo 필수변경된 모듈의 범위를 괄호 안에 명시합니다.feat(fe): 프론트엔드(Flutter) 관련 기능fix(be): 백엔드(Spring Boot) 관련 수정chore(common): 프로젝트 전체 설정 (gitignore 등)2.4 Subject (제목) 규칙영문 소문자로 시작합니다. (한글 사용 시 통일성 유지)동사 원형을 사용합니다. ("Added" -> "Add", "Fixed" -> "Fix")제목 끝에 마침표(.)를 찍지 않습니다.50자를 넘기지 않습니다.2.5 Body (본문) & Footer (꼬리말)Body: '무엇을', '왜' 변경했는지 상세히 작성합니다. (선택 사항)Footer: 관련된 이슈 번호를 명시하여 트래킹을 자동화합니다.예: Closes #123 (이슈 자동 닫힘), Refs #123 (참고)✅ 예시 (Best Practice)Plaintextfeat(be): implement social login api

- Kakao, Google OAuth2 연동
- JWT 토큰 발급 로직 추가

Closes #42
3. 🚀 Pull Request (PR) ProcessPR은 코드 품질을 지키는 마지막 관문입니다. 아래 **Definition of Done (DoD)**을 만족해야 합니다.PR 제목: 커밋 컨벤션과 동일하게 작성합니다. (예: feat(fe): 지도 마커 클러스터링 구현)템플릿 작성: 제공된 PR 템플릿의 모든 항목(변경 사항, 테스트 방법, 스크린샷)을 채웁니다.Labeling: PR 성격에 맞는 라벨을 부착합니다 (frontend, backend, enhancement 등).Reviewers:프론트엔드 코드는 프론트엔드 팀원 1명 이상백엔드 코드는 백엔드 팀원 1명 이상Merge 기준:CI(빌드/테스트) 통과최소 1명 이상의 Approve모든 코멘트(Review Comment)가 해결(Resolve)된 상태4. 🎨 Code Style (코딩 컨벤션)일관된 코드 스타일을 위해 아래 설정을 IDE에 적용해 주세요.Java (Backend): Google Java Style Guide를 준수합니다. (IntelliJ 포맷터 사용 권장)Dart (Frontend): Effective Dart 스타일을 따르며, flutter analyze 명령어를 통과해야 합니다.
---

### 📚 작성 근거 및 참고 자료 (References)

위 문서는 다음의 글로벌 표준 및 기업 사례를 기반으로 작성되었습니다.

1.  **커밋 컨벤션의 근거: [Conventional Commits & Angular Commit Message Guidelines]**
    * **링크:** [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
    * **이유:** 구글의 Angular 팀에서 시작되어 현재 전 세계 개발 표준이 되었습니다. 이 방식을 쓰면 나중에 `CHANGELOG.md` 파일을 자동으로 생성할 수 있고, 시멘틱 버저닝(v1.0.0 -> v1.1.0)을 자동화하기 유리합니다.

2.  **브랜치 전략의 근거: [Git Flow & GitHub Flow]**
    * **링크:** [nvie.com - A successful Git branching model](https://nvie.com/posts/a-successful-git-branching-model/)
    * **이유:** 협업의 안정성을 보장하는 가장 클래식하고 검증된 방법입니다. 대기업에서는 배포 사고를 막기 위해 `develop`과 `main`을 철저히 분리합니다.

3.  **코드 스타일의 근거: [Google Style Guides]**
    * **링크:** [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
    * **이유:** 네이버, 카카오 등 국내 대기업들도 자체 스타일 가이드의 베이스를 구글 스타일 가이드로 삼는 경우가 많습니다.

4.  **PR 프로세스의 근거: [Google Engineering Practices Documentation]**
    * **링크:** [How to do a code review](https://google.github.io/eng-practices/review/reviewer/)
    * **이유:** 구글의 코드 리뷰 가이드라인을 참고하여 '승인(Approve)' 절차와 '테스트 통과(CI)'를 필수 조건으로 넣었습니다.

### 💡 세훈님을 위한 실무 Tip
이 문서를 레포지토리에 올리는 것만으로도 팀의 수준이 달라 보입니다.
하지만 초보 팀원들이 처음부터 완벽하게 지키기는 어렵습니다. 처음 2주 동안은 **세훈님(팀장)이 PR을 직접 보면서 "커밋 메시지 이렇게 수정해주세요"라고 코멘트를 남기며 습관을 잡아주는 과정**이 꼭 필요합니다. 이것을 '온보딩(On-boarding)'이라고 합니다.