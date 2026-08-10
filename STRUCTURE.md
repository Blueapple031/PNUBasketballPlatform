# 📁 프로젝트 구조 명세서 (STRUCTURE.md)

> **넉터(NUKTU)** 프로젝트의 폴더 구조 및 아키텍처 설계 명세서

---

## 📋 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [전체 구조](#전체-구조)
3. [Backend 구조](#backend-구조)
4. [Frontend 구조](#frontend-구조)
5. [폴더별 상세 명세](#폴더별-상세-명세)
6. [아키텍처 설계 근거](#아키텍처-설계-근거)
7. [파일 명명 규칙](#파일-명명-규칙)

---

## 🎯 프로젝트 개요

### 프로젝트 정보

- **프로젝트명**: 넉터(NUKTU)
- **프로젝트 타입**: Monorepo (단일 저장소)
- **아키텍처 패턴**:
  - Backend: **Layered Architecture** (Controller → Service → Repository)
  - Frontend: **Clean Architecture** (Presentation → Domain → Data)

### 기술 스택

- **Backend**: Java 17, Spring Boot 3.2.1, Gradle, PostgreSQL, Redis
- **Frontend**: Flutter 3.0+, Dart, Provider (State Management)
- **인프라**: WebSocket (STOMP), JWT 인증

---

## 🏗️ 전체 구조

```
PNUBasketballPlatform/
├── .github/                      # GitHub 관련 설정
│   ├── workflows/                # CI/CD 파이프라인
│   └── ISSUE_TEMPLATE/           # 이슈 템플릿
│
├── backend/                      # Spring Boot 백엔드 서버
│   ├── gradle/                   # Gradle Wrapper
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/             # Java 소스 코드
│   │   │   └── resources/       # 설정 파일
│   │   └── test/                 # 테스트 코드
│   ├── build.gradle              # Gradle 빌드 설정
│   └── settings.gradle           # Gradle 프로젝트 설정
│
├── frontend/                     # Flutter 프론트엔드 앱
│   ├── android/                  # Android 플랫폼 설정
│   ├── ios/                      # iOS 플랫폼 설정
│   ├── macos/                    # macOS 플랫폼 설정
│   ├── windows/                  # Windows 플랫폼 설정
│   ├── web/                      # Web 플랫폼 설정
│   ├── lib/                      # Dart 소스 코드
│   ├── test/                     # 테스트 코드
│   ├── assets/                   # 이미지, 폰트 등 리소스
│   └── pubspec.yaml              # Flutter 패키지 설정
│
├── docs/                         # 프로젝트 문서
│   ├── api/                      # API 문서
│   ├── architecture/             # 아키텍처 설계 문서
│   └── database/                 # 데이터베이스 스키마
│
├── scripts/                      # 유틸리티 스크립트
│
├── .gitignore                    # Git 제외 파일 목록
├── README.md                     # 프로젝트 소개
├── CONTRIBUTING.md               # 기여 가이드
├── LICENSE                       # 라이선스
└── STRUCTURE.md                  # 이 문서
```

---

## 🔧 Backend 구조

### 전체 디렉토리 트리

```
backend/
├── gradle/
│   └── wrapper/                 # Gradle Wrapper 파일
│
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── pnu/
│   │   │           └── basketball/
│   │   │               ├── BasketballApplication.java    # 메인 애플리케이션
│   │   │               │
│   │   │               ├── config/                       # 설정 클래스
│   │   │               │   ├── SecurityConfig.java       # Spring Security 설정
│   │   │               │   ├── WebSocketConfig.java      # WebSocket 설정
│   │   │               │   └── SwaggerConfig.java        # API 문서화 설정
│   │   │               │
│   │   │               ├── controller/                   # REST API 컨트롤러
│   │   │               │   ├── auth/                     # 인증 관련 API
│   │   │               │   │   ├── AuthController.java
│   │   │               │   │   └── UserController.java
│   │   │               │   ├── match/                    # 매칭 관련 API
│   │   │               │   │   ├── MatchController.java
│   │   │               │   │   └── MatchParticipantController.java
│   │   │               │   ├── court/                   # 농구장 관련 API
│   │   │               │   │   └── CourtController.java
│   │   │               │   └── chat/                    # 채팅 관련 API
│   │   │               │       └── ChatController.java
│   │   │               │
│   │   │               ├── service/                     # 비즈니스 로직 계층
│   │   │               │   ├── auth/
│   │   │               │   │   ├── AuthService.java
│   │   │               │   │   └── UserService.java
│   │   │               │   ├── match/
│   │   │               │   │   └── MatchService.java
│   │   │               │   └── chat/
│   │   │               │       └── ChatService.java
│   │   │               │
│   │   │               ├── repository/                  # 데이터 접근 계층
│   │   │               │   ├── UserRepository.java
│   │   │               │   ├── MatchRepository.java
│   │   │               │   ├── CourtRepository.java
│   │   │               │   └── ChatMessageRepository.java
│   │   │               │
│   │   │               ├── domain/                      # 엔티티 (JPA)
│   │   │               │   ├── User.java
│   │   │               │   ├── Match.java
│   │   │               │   ├── Court.java
│   │   │               │   └── ChatMessage.java
│   │   │               │
│   │   │               ├── dto/                         # 데이터 전송 객체
│   │   │               │   ├── request/                 # 요청 DTO
│   │   │               │   │   ├── LoginRequest.java
│   │   │               │   │   ├── SignupRequest.java
│   │   │               │   │   └── CreateMatchRequest.java
│   │   │               │   └── response/               # 응답 DTO
│   │   │               │       ├── AuthResponse.java
│   │   │               │       └── MatchResponse.java
│   │   │               │
│   │   │               ├── exception/                   # 예외 처리
│   │   │               │   ├── GlobalExceptionHandler.java
│   │   │               │   ├── CustomException.java
│   │   │               │   └── ErrorCode.java
│   │   │               │
│   │   │               └── util/                        # 유틸리티 클래스
│   │   │                   ├── JwtUtil.java
│   │   │                   └── PasswordEncoder.java
│   │   │
│   │   └── resources/
│   │       ├── application.yml                          # 기본 설정
│   │       ├── application-dev.yml                     # 개발 환경 설정
│   │       ├── application-prod.yml                    # 운영 환경 설정
│   │       └── static/                                 # 정적 리소스
│   │
│   └── test/
│       └── java/
│           └── com/
│               └── pnu/
│                   └── basketball/
│                       ├── controller/                 # 컨트롤러 테스트
│                       ├── service/                     # 서비스 테스트
│                       └── repository/                  # 리포지토리 테스트
│
├── build.gradle                                         # Gradle 빌드 설정
├── settings.gradle                                      # Gradle 프로젝트 설정
├── gradlew                                              # Gradle Wrapper (Unix)
└── gradlew.bat                                          # Gradle Wrapper (Windows)
```

### Backend 폴더별 상세 명세

#### 📂 `config/`

**역할**: Spring Framework 설정 클래스 모음

**생성 근거**:

- Spring Boot의 설정을 코드로 관리하여 유지보수성 향상
- 보안, WebSocket, API 문서화 등 각 기능별 설정을 분리하여 관리

**주요 파일**:

- `SecurityConfig.java`: JWT 인증, CORS, 접근 권한 설정
- `WebSocketConfig.java`: STOMP 프로토콜 기반 실시간 채팅 설정
- `SwaggerConfig.java`: API 문서 자동 생성 설정

**설계 원칙**:

- 각 설정은 단일 책임 원칙(SRP) 준수
- 환경별 설정은 `application-{env}.yml`로 분리

---

#### 📂 `controller/`

**역할**: REST API 엔드포인트 정의 및 HTTP 요청/응답 처리

**생성 근거**:

- RESTful API 설계 원칙 준수
- 도메인별 컨트롤러 분리로 코드 가독성 및 유지보수성 향상
- URL 경로와 비즈니스 로직 분리

**폴더 구조**:

- `auth/`: 인증/인가 관련 API (로그인, 회원가입, 토큰 갱신)
- `match/`: 매칭 관련 API (매칭 생성, 조회, 참여, 취소)
- `court/`: 농구장 정보 API (농구장 조회, 정보 수정)
- `chat/`: 채팅 관련 API (채팅방 생성, 메시지 조회)

**설계 원칙**:

- 컨트롤러는 요청 검증 및 응답 변환만 담당
- 비즈니스 로직은 Service 계층에 위임
- DTO를 통한 데이터 전송 (Entity 직접 노출 방지)

---

#### 📂 `service/`

**역할**: 비즈니스 로직 구현 및 트랜잭션 관리

**생성 근거**:

- 비즈니스 로직의 재사용성 향상
- 트랜잭션 경계 명확화
- 테스트 용이성 확보

**주요 책임**:

- 도메인 로직 실행
- 트랜잭션 관리 (`@Transactional`)
- Repository 계층 호출
- 예외 처리 및 변환

**설계 원칙**:

- Service는 인터페이스와 구현체로 분리 가능 (확장성 고려)
- 하나의 Service는 하나의 도메인 책임만 담당
- Service 간 순환 참조 방지

---

#### 📂 `repository/`

**역할**: 데이터베이스 접근 계층 (JPA Repository)

**생성 근거**:

- Spring Data JPA를 활용한 데이터 접근 추상화
- 반복적인 CRUD 코드 제거
- 커스텀 쿼리 메서드 정의

**주요 기능**:

- 기본 CRUD 연산 (JpaRepository 상속)
- 커스텀 쿼리 메서드 (`@Query` 어노테이션)
- 페이징 및 정렬 지원

**설계 원칙**:

- Repository는 Entity만 다루며, DTO 변환은 Service에서 처리
- 복잡한 쿼리는 `@Query` 또는 QueryDSL 사용
- N+1 문제 방지를 위한 `@EntityGraph` 활용

---

#### 📂 `domain/`

**역할**: JPA 엔티티 (데이터베이스 테이블 매핑)

**생성 근거**:

- 객체-관계 매핑(ORM)을 통한 데이터 모델링
- 도메인 모델의 명확한 표현
- 데이터베이스 스키마와 코드 동기화

**주요 엔티티**:

- `User`: 사용자 정보 (이메일, 닉네임, 위치 등)
- `Match`: 매칭 정보 (시간, 장소, 인원수 등)
- `Court`: 농구장 정보 (위치, 골대 수, 바닥 재질 등)
- `ChatMessage`: 채팅 메시지 (내용, 발신자, 시간 등)

**설계 원칙**:

- 엔티티는 순수한 도메인 모델로 유지 (비즈니스 로직 최소화)
- 양방향 관계는 필요한 경우에만 사용
- `@CreatedDate`, `@LastModifiedDate` 등 자동 감사 필드 활용

---

#### 📂 `dto/`

**역할**: 계층 간 데이터 전송 객체

**생성 근거**:

- Entity 직접 노출 방지 (보안 및 캡슐화)
- API 계약 명확화
- 요청/응답 데이터 검증 용이

**폴더 구조**:

- `request/`: 클라이언트 → 서버 요청 DTO
- `response/`: 서버 → 클라이언트 응답 DTO

**설계 원칙**:

- DTO는 불변 객체로 설계 (`final` 필드, `@Builder` 패턴)
- `@Valid` 어노테이션을 통한 요청 데이터 검증
- 중첩 객체는 내부 DTO로 분리

---

#### 📂 `exception/`

**역할**: 전역 예외 처리 및 커스텀 예외 정의

**생성 근거**:

- 일관된 에러 응답 형식 제공
- 예외 처리 로직 중앙화
- 클라이언트 친화적인 에러 메시지 제공

**주요 파일**:

- `GlobalExceptionHandler.java`: `@ControllerAdvice` 기반 전역 예외 처리
- `CustomException.java`: 커스텀 예외 클래스
- `ErrorCode.java`: 에러 코드 열거형

**설계 원칙**:

- 모든 예외는 `ErrorCode`를 통해 관리
- 예외 메시지는 클라이언트에게 노출 가능한 수준으로 작성
- 민감한 정보는 로그에만 기록

---

#### 📂 `util/`

**역할**: 공통 유틸리티 클래스

**생성 근거**:

- 재사용 가능한 기능의 중앙화
- 테스트 용이성 향상
- 코드 중복 제거

**주요 유틸리티**:

- `JwtUtil.java`: JWT 토큰 생성/검증
- `PasswordEncoder.java`: 비밀번호 암호화 (BCrypt)

**설계 원칙**:

- 유틸리티 클래스는 정적 메서드로 구성
- 순수 함수로 설계 (부작용 최소화)
- 단위 테스트 필수

---

## 📱 Frontend 구조

### 전체 디렉토리 트리

```
frontend/
├── android/                     # Android 플랫폼 설정
├── ios/                         # iOS 플랫폼 설정
├── macos/                       # macOS 플랫폼 설정
├── windows/                     # Windows 플랫폼 설정
├── web/                         # Web 플랫폼 설정
│
├── lib/
│   ├── main.dart                # 앱 진입점
│   ├── app.dart                 # 메인 앱 위젯
│   │
│   ├── core/                    # 핵심 기능 (공통)
│   │   ├── constants/           # 상수 정의
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── api_endpoints.dart
│   │   ├── theme/               # 앱 테마 설정
│   │   │   ├── app_colors.dart  # PNU Plato 색상 체계
│   │   │   └── app_theme.dart
│   │   ├── routes/              # 라우팅 설정
│   │   │   └── app_routes.dart
│   │   └── utils/               # 공통 유틸리티
│   │       ├── validators.dart
│   │       └── date_formatter.dart
│   │
│   ├── data/                    # 데이터 계층
│   │   ├── models/              # 데이터 모델
│   │   │   ├── user_model.dart
│   │   │   ├── match_model.dart
│   │   │   └── court_model.dart
│   │   ├── repositories/        # Repository 구현
│   │   │   ├── auth_repository.dart
│   │   │   └── match_repository.dart
│   │   └── services/            # API 서비스
│   │       ├── api_service.dart
│   │       └── websocket_service.dart
│   │
│   ├── domain/                  # 도메인 계층 (비즈니스 로직)
│   │   ├── entities/            # 도메인 엔티티
│   │   │   ├── user_entity.dart
│   │   │   └── match_entity.dart
│   │   └── usecases/            # Use Cases
│   │       ├── login_usecase.dart
│   │       └── create_match_usecase.dart
│   │
│   ├── presentation/            # UI 계층
│   │   ├── screens/             # 화면 (페이지)
│   │   │   ├── root/            # 루트 네비게이션
│   │   │   │   └── root_screen.dart  # BottomNavigationBar 관리
│   │   │   ├── splash/
│   │   │   │   └── splash_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── signup_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── map/
│   │   │   │   └── map_screen.dart
│   │   │   ├── match/
│   │   │   │   ├── match_list_screen.dart
│   │   │   │   └── match_detail_screen.dart
│   │   │   ├── chat/
│   │   │   │   └── chat_screen.dart
│   │   │   ├── profile/
│   │   │   │   └── profile_screen.dart
│   │   │   └── user/            # 사용자 프로필 화면
│   │   │       ├── user_tab.dart          # 마이페이지 메인
│   │   │       └── edit_profile_screen.dart  # 프로필 수정
│   │   │
│   │   ├── widgets/             # 재사용 가능한 위젯
│   │   │   ├── common/          # 공통 위젯
│   │   │   │   ├── custom_button.dart
│   │   │   │   ├── custom_textfield.dart
│   │   │   │   └── loading_indicator.dart
│   │   │   ├── match/           # 매칭 관련 위젯
│   │   │   │   └── match_card.dart
│   │   │   └── user/            # 사용자 관련 위젯
│   │   │       ├── profile_header.dart      # 프로필 헤더
│   │   │       ├── subscription_banner.dart # 구독 배너
│   │   │       └── settings_list.dart       # 설정 메뉴
│   │   │
│   │   └── providers/           # 상태 관리 (Provider)
│   │       ├── auth_provider.dart
│   │       ├── match_provider.dart
│   │       └── location_provider.dart
│   │
│   └── generated/               # 자동 생성 파일 (선택사항)
│
├── test/
│   ├── unit/                    # 단위 테스트
│   ├── widget/                  # 위젯 테스트
│   └── integration/            # 통합 테스트
│
├── assets/
│   ├── images/                  # 이미지 리소스
│   ├── icons/                   # 아이콘 리소스
│   └── fonts/                   # 폰트 파일
│
└── pubspec.yaml                 # Flutter 패키지 설정
```

### Frontend 폴더별 상세 명세

#### 📂 `core/`

**역할**: 앱 전체에서 공통으로 사용되는 핵심 기능

**생성 근거**:

- Clean Architecture의 공통 계층 구현
- 코드 재사용성 및 일관성 확보
- 설정 중앙화

**하위 폴더**:

- `constants/`: 앱 전역 상수 (색상, 문자열, API 엔드포인트)
- `theme/`: Material Design 테마 설정
- `routes/`: 네비게이션 라우팅 설정
- `utils/`: 공통 유틸리티 함수

**설계 원칙**:

- `core/`는 다른 계층에 의존하지 않음
- 순수 함수로 구성 (부작용 최소화)

---

#### 📂 `data/`

**역할**: 외부 데이터 소스와의 통신 계층

**생성 근거**:

- 데이터 소스 추상화 (API, 로컬 DB 등)
- Repository 패턴 구현
- 네트워크 로직 분리

**하위 폴더**:

- `models/`: API 응답 데이터 모델 (JSON 직렬화/역직렬화)
- `repositories/`: 데이터 접근 구현체
- `services/`: HTTP 클라이언트, WebSocket 클라이언트

**설계 원칙**:

- `data/`는 `domain/`에 의존 (의존성 역전 원칙)
- Repository는 인터페이스로 정의하고 `domain/`에 배치 가능
- 에러 처리는 `domain/` 계층으로 변환하여 전달

---

#### 📂 `domain/`

**역할**: 비즈니스 로직 및 도메인 모델

**생성 근거**:

- 비즈니스 로직의 독립성 확보
- 프레임워크 독립적 설계
- 테스트 용이성 향상

**하위 폴더**:

- `entities/`: 순수 도메인 엔티티 (비즈니스 규칙 포함)
- `usecases/`: 특정 기능의 Use Case 구현

**설계 원칙**:

- `domain/`은 다른 계층에 의존하지 않음
- Entity는 순수 Dart 클래스 (Flutter 의존성 없음)
- Use Case는 단일 책임 원칙 준수

---

#### 📂 `presentation/`

**역할**: UI 및 상태 관리 계층

**생성 근거**:

- UI 로직과 비즈니스 로직 분리
- 재사용 가능한 컴포넌트 구성
- 상태 관리 중앙화

**하위 폴더**:

- `screens/`: 전체 화면 위젯 (페이지 단위)
- `widgets/`: 재사용 가능한 작은 위젯
- `providers/`: Provider를 활용한 상태 관리

**설계 원칙**:

- Screen은 비즈니스 로직을 직접 포함하지 않음
- Provider를 통해 Use Case 호출
- 위젯은 최대한 작고 재사용 가능하게 설계

---

#### 📂 `assets/`

**역할**: 정적 리소스 파일 저장

**생성 근거**:

- 이미지, 폰트 등 리소스 관리
- 플랫폼별 리소스 분리 가능

**하위 폴더**:

- `images/`: PNG, JPG 등 이미지 파일
- `icons/`: SVG, PNG 아이콘
- `fonts/`: TTF, OTF 폰트 파일

**설계 원칙**:

- 리소스는 `pubspec.yaml`에 명시
- 이미지는 적절한 해상도로 최적화
- 폰트는 필요한 weight만 포함

---

## 🏛️ 아키텍처 설계 근거

### 1. Monorepo 구조 선택

**근거**:

- ✅ 프론트엔드와 백엔드의 긴밀한 협업 필요
- ✅ 공통 문서 및 스크립트 관리 용이
- ✅ 버전 관리 일원화
- ✅ CI/CD 파이프라인 단순화

**단점 및 대응**:

- ❌ 저장소 크기 증가 → `.gitignore` 최적화
- ❌ 권한 관리 복잡 → 브랜치 전략 명확화

---

### 2. Backend: Layered Architecture

**근거**:

- ✅ Spring Boot의 표준 아키텍처 패턴
- ✅ 계층별 책임 분리 명확
- ✅ 테스트 용이성 (각 계층 독립 테스트 가능)
- ✅ 유지보수성 향상

**계층 구조**:

```
Controller (Presentation Layer)
    ↓
Service (Business Logic Layer)
    ↓
Repository (Data Access Layer)
    ↓
Database
```

---

### 3. Frontend: Clean Architecture

**근거**:

- ✅ 프레임워크 독립적 비즈니스 로직
- ✅ 테스트 용이성 (도메인 로직 단위 테스트)
- ✅ 확장성 및 유지보수성 향상
- ✅ Flutter 커뮤니티 표준 패턴

**의존성 방향**:

```
Presentation (UI)
    ↓
Domain (Business Logic)
    ↑
Data (External Sources)
```

**핵심 원칙**:

- 외부 계층은 내부 계층에 의존
- 내부 계층은 외부 계층에 의존하지 않음
- 의존성은 인터페이스를 통해 역전 (DIP)

---

### 4. 패키지 구조: 도메인 중심 vs 계층 중심

**선택**: 계층 중심 구조 (Layer-based)

**근거**:

- ✅ Spring Boot 표준 구조와 일치
- ✅ 작은 규모 프로젝트에 적합
- ✅ 도메인 추가 시 확장 용이

**대안 고려사항**:

- 대규모 프로젝트의 경우 도메인 중심 구조 (Domain-based) 고려 가능
  ```
  com.pnu.basketball.auth.controller
  com.pnu.basketball.auth.service
  com.pnu.basketball.match.controller
  com.pnu.basketball.match.service
  ```

---

### 5. 상태 관리: Provider 선택

**근거**:

- ✅ Flutter 공식 추천 패키지
- ✅ 학습 곡선 낮음
- ✅ 작은 규모 프로젝트에 적합
- ✅ React의 Context API와 유사한 패턴

**대안**:

- **Riverpod**: 타입 안정성 및 테스트 용이성 향상 (향후 마이그레이션 고려)
- **Bloc**: 복잡한 상태 관리 필요 시 고려

---

## 📝 파일 명명 규칙

### Backend (Java)

#### 클래스 명명

- **Controller**: `{Domain}Controller.java` (예: `AuthController.java`)
- **Service**: `{Domain}Service.java` (예: `MatchService.java`)
- **Repository**: `{Domain}Repository.java` (예: `UserRepository.java`)
- **Entity**: 단수형 도메인명 (예: `User.java`, `Match.java`)
- **DTO**: `{Purpose}{Domain}DTO.java` (예: `CreateMatchRequest.java`, `MatchResponse.java`)
- **Exception**: `{Domain}Exception.java` (예: `UserNotFoundException.java`)
- **Config**: `{Purpose}Config.java` (예: `SecurityConfig.java`)

#### 패키지 명명

- 소문자만 사용
- 단어 구분은 점(`.`)으로
- 도메인 역순 (예: `com.pnu.basketball`)

---

### Frontend (Dart)

#### 파일 명명

- **Screen**: `{purpose}_screen.dart` (예: `login_screen.dart`)
- **Widget**: `{purpose}_widget.dart` (예: `match_card.dart`)
- **Model**: `{domain}_model.dart` (예: `user_model.dart`)
- **Provider**: `{domain}_provider.dart` (예: `auth_provider.dart`)
- **Service**: `{purpose}_service.dart` (예: `api_service.dart`)
- **UseCase**: `{action}_{domain}_usecase.dart` (예: `login_usecase.dart`)

#### 클래스 명명

- **Screen**: `{Purpose}Screen` (예: `LoginScreen`)
- **Widget**: `{Purpose}Widget` 또는 구체적 이름 (예: `MatchCard`)
- **Model**: `{Domain}Model` (예: `UserModel`)
- **Provider**: `{Domain}Provider` (예: `AuthProvider`)

**규칙**:

- 파일명: `snake_case`
- 클래스명: `PascalCase`
- 변수/함수명: `camelCase`
- 상수: `SCREAMING_SNAKE_CASE`

---

## 🔄 향후 확장 고려사항

### 1. 마이크로서비스 전환

현재는 모놀리식 구조이지만, 향후 확장 시 다음 도메인으로 분리 가능:

- Auth Service
- Match Service
- Chat Service
- Court Service

### 2. 멀티 모듈 Gradle 프로젝트

백엔드가 커질 경우 모듈 분리 고려:

```
backend/
├── api/          # REST API 모듈
├── core/         # 공통 모듈
├── domain/       # 도메인 모듈
└── infra/        # 인프라 모듈
```

### 3. 상태 관리 마이그레이션

Provider → Riverpod 마이그레이션 고려 (타입 안정성 향상)

---

## 📚 참고 자료

- [Spring Boot 공식 문서](https://spring.io/projects/spring-boot)
- [Flutter Clean Architecture 가이드](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Gradle 공식 문서](https://docs.gradle.org/)
- [RESTful API 설계 가이드](https://restfulapi.net/)

---

## 📅 문서 이력

| 버전  | 날짜    | 작성자 | 변경 내용                     |
| ----- | ------- | ------ | ----------------------------- |
| 1.0.0 | 2026-01 | 팀     | 초기 구조 설계 및 명세서 작성 |

---

**문서 작성일**: 2026년 1월  
**최종 수정일**: 2026년 1월  
**작성자**: 넉터(NUKTU) 개발팀
