# 🏀 딸바

> **내 주변 농구장을 찾고, 실시간으로 번개 매칭을 즐기세요!** > 위치 기반 실시간 농구 매칭 & 커뮤니티 플랫폼

[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FYOUR_ID%2FREPO_NAME&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

---

## 📅 Project Duration
* **기간:** 2026.01 ~ 2026.XX (진행 중)

## 👥 Team Members
| Position | Name | GitHub | Role |
| :--- | :---: | :---: | :--- |
| **Backend** | **김세엽** (팀장) | [@gildong](https://github.com/username) | API 설계, DB 구축, 배포 |
| **Backend** | **임도균** | [@chulsoo](https://github.com/username) | 회원가입/인증, 채팅 서버 구현 |
| **Frontend** | **이학영** | [@younghee](https://github.com/username) | 지도 서비스, 매칭 UI 구현 |
| **Frontend** | **박현아** | [@minsoo](https://github.com/username) | 채팅 클라이언트, 게시판 UI |

---

## 🛠️ Tech Stack

### Environment
![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)

### Development
| Frontend (App) | Backend (Server) | Data & Infra |
| :---: | :---: | :---: |
| ![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) | ![Java](https://img.shields.io/badge/java-%23ED8B00.svg?style=for-the-badge&logo=openjdk&logoColor=white) | ![PostgreSQL](https://img.shields.io/badge/postgresql-316192.svg?style=for-the-badge&logo=postgresql&logoColor=white) |
| ![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white) | ![Spring Boot](https://img.shields.io/badge/springboot-6DB33F.svg?style=for-the-badge&logo=springboot&logoColor=white) | ![Redis](https://img.shields.io/badge/redis-%23DD0031.svg?style=for-the-badge&logo=redis&logoColor=white) |
| | ![WebSocket](https://img.shields.io/badge/Websocket-white?style=for-the-badge) | |

### Communication
![Slack](https://img.shields.io/badge/Slack-4A154B?style=for-the-badge&logo=slack&logoColor=white)
![Notion](https://img.shields.io/badge/Notion-%23000000.svg?style=for-the-badge&logo=notion&logoColor=white)

---

## 🏛️ Project Architecture
이 프로젝트는 **Monorepo** 구조를 채택하고 있습니다.

```bash
basket-match-app/
├── .github/              # GitHub Actions & Issue Templates
├── backend/              # Spring Boot Server
│   ├── src/main/java     # Java Source Code
│   └── build.gradle      
├── frontend/             # Flutter Application
│   ├── lib/              # Dart Source Code
│   └── pubspec.yaml      
└── README.md

```


## ✨ Key Features

* **🏀 위치 기반 매칭:** 내 주변 반경 3km 내의 농구 번개 모임을 지도에서 확인하고 참여할 수 있습니다.
* **💬 실시간 채팅:** WebSocket(STOMP)을 이용하여 매칭된 팀원들과 실시간으로 대화를 나눌 수 있습니다.
* **🏆 농구장 정보 공유:** 사용자 참여형 농구장 정보(골대 상태, 바닥 재질 등) 공유 기능을 제공합니다.

---

## 🚀 Getting Started

### 1. Backend (Spring Boot)

서버 실행을 위해 Java 17 이상과 PostgreSQL이 필요합니다.

**데이터베이스 설정:**
```bash
# PostgreSQL 데이터베이스 생성
createdb basketball_db

# 또는 psql에서 실행
psql -U postgres
CREATE DATABASE basketball_db;
```

**애플리케이션 실행:**
```bash
# 프로젝트 루트에서 백엔드 폴더로 이동
cd backend

# 의존성 설치 및 실행
./gradlew bootRun
```

* **Server Port:** 8080
* **Database:** PostgreSQL (기본 포트: 5432)
* **API Docs:** `http://localhost:8080/swagger-ui.html` (실행 후 접속 가능)

### 2. Frontend (Flutter)

앱 실행을 위해 Flutter SDK 설치가 필요합니다.

```bash
# 프로젝트 루트에서 프론트엔드 폴더로 이동
cd frontend

# 패키지 설치
flutter pub get

# 앱 실행 (에뮬레이터 혹은 실기기 연결 필수)
flutter run

```

---

## 🤝 Git Convention

우리 팀은 아래의 커밋 규칙을 따릅니다.

* `feat`: 새로운 기능 추가 (예: `feat: 로그인 기능 구현`)
* `fix`: 버그 수정 (예: `fix: 채팅 스크롤 오류 수정`)
* `docs`: 문서 수정 (예: `docs: README 수정`)
* `style`: 코드 포맷팅, 세미콜론 누락 등 (코드 변경 없음)
* `refactor`: 코드 리팩토링
* `test`: 테스트 코드 추가
* `chore`: 빌드 업무 수정, 패키지 매니저 수정

---

## 📸 Screen Shots

| 메인 화면(지도) | 매칭 리스트 | 채팅 화면 | 프로필 설정 |
| --- | --- | --- | --- |
| <img src="" width="200"/> | <img src="" width="200"/> | <img src="" width="200"/> | <img src="" width="200"/> |

> (스크린샷은 개발 진행 후 업데이트 예정입니다)

---

## 주간 진행 상황

### Week 1 (12/22 ~ 12/28)

- **작업 내역**:
  - Git 사용법 숙지 (이론)
- **사용 LLM**:
  - Gemini: Git 명령어 관련 질문 용도

### Week 2 (12/29 ~ 1/4)

- **작업 내역**:
  - GitHub를 활용해 개인 프로젝트 진행해보기
- **사용 LLM**:
  - GitHub Copilot: 프로젝트용 더미 파일 제작 용도
  - Gemini: Git 명령어 관련 질문 용도

### Week 3 (1/5 ~ 1/11)

- **작업 내역**:
  - 프로젝트에 사용할 언어 선택
- **사용 LLM**:
  - Gemini: 프로젝트에 사용할 언어 장단점 질문 용도

### Week 4 (1/12 ~ 1/18)

- **작업 내역**:
  - 프론트: 로그인 탭, 유저 탭, 매칭 탭 스켈레톤 구현 (이슈 번호 1, 4, 5)
  - 백엔드: 회원가입 API 구현 (이슈 번호 3)
- **사용 LLM**:
  - GitHub Copilot: 실제 구현 및 커밋 메시지 작성 용도
  - Gemini: 코드 점검 용도

### Week 5 (1/19 ~ 1/25)

- **작업 내역**:
  - 프론트: 디자인 통일을 위한 하네스 구축 (이슈 번호 4번에서 함께 진행)
- **사용 LLM**:
  - Gemini: design.md 파일 제작 용도
  - GitHub Copilot: design.md 파일 점검 및 보충 용도

### Week 6 (1/26 ~ 2/1)

- **작업 내역**:
  - 프론트: design.md 파일을 바탕으로 기존 탭 디자인 변경 (별도 이슈 없음)
- **사용 LLM**:
  - GitHub Copilot: 탭 디자인 수정 용도

### Week 7 (2/2 ~ 2/8)

- **작업 내역**:
  - 프론트: 추가해야 할 탭에 필요한 요소 토의 (별도 이슈 없음)
  - 백엔드: 유저 관련 API 개발 (이슈 번호 8)

### Week 8 (2/9 ~ 2/15)

- **작업 내역**:
  - 프론트: API 문서를 바탕으로 추가되어야 할 API 피드백 (별도 이슈 없음)
  - 백엔드: API 명세서 작성 (별도 이슈 없음)
- **사용 LLM**:
  - GitHub Copilot: API 문서 확인 및 필요한 API 문서화 용도

### Week 9 (2/16 ~ 2/22)

- **작업 내역**:
  - 프론트: 매칭 탭 스켈레톤 구현, 동아리 탭 스켈레톤 구현 및 데이터베이스 연동 (이슈 번호 13, 17)
  - 백엔드: 카카오 로그인 소셜 로그인 API 추가
- **사용 LLM**:
  - Gemini: 사진을 바탕으로 탭 디자인 스켈레톤 코드 생성 용도
  - GitHub Copilot: 생성된 코드 점검 및 디자인 적용 용도

### Week 10 (2/23 ~ 3/1)

- **작업 내역**:
  - 프론트: 브랜치 간 충돌 해결 후 병합 (별도 이슈 없음)
- **사용 LLM**:
  - Gemini: 충돌 해결 방법 확인 용도
  - GitHub Copilot: 충돌 해결 방법 확인 용도

### Week 11 (3/2 ~ 3/8)

- **작업 내역**:
  - 프론트: 매칭 탭 UI 개선, 동아리 목록 및 동아리 상세 페이지 구현 (이슈 번호 17, 29)
  - 백엔드: 게시판 게시글, 댓글 API 및 필수 입력 정보 API 구현
- **사용 LLM**:
  - GitHub Copilot: 구현 및 실행 오류 수정 용도


 ---

 ## 저장소 시각화
 ![Alt](https://repobeats.axiom.co/api/embed/b8f3ebb1afc5bd69f7feaf0d8f6fe2fe25205ebb.svg "Repobeats analytics image")
