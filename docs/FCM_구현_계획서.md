# FCM(Firebase Cloud Messaging) 알람 기능 구현 계획서

> **프로젝트:** 딸바 (PNUBasketballPlatform)  
> **작성일:** 2026.03.09  
> **목적:** FCM 토큰 기반 푸시 알림 기능 상세 구현 계획

---

## 1. 개요

### 1.1 목표
- 사용자 기기에 FCM 토큰을 발급·등록하여 푸시 알림 수신
- 매칭, 채팅, 게시글 등 주요 이벤트 발생 시 알림 발송

### 1.2 기술 스택
| 구분 | 기술 |
|------|------|
| 백엔드 | Spring Boot 3.2.1, Firebase Admin SDK |
| 프론트엔드 | Flutter 3.x, firebase_core, firebase_messaging |
| 인프라 | Firebase Console, PostgreSQL |

### 1.3 아키텍처

```
┌─────────────────┐     FCM 토큰 등록      ┌─────────────────┐
│  Flutter 앱     │ ───────────────────►  │  Spring Boot    │
│  (firebase_     │   POST /api/users/    │  UserService    │
│   messaging)   │   me/fcm-token         │  → DB 저장      │
└────────┬────────┘                       └────────┬────────┘
         │                                         │
         │  푸시 수신                              │ 푸시 발송
         │  (포그라운드/백그라운드)                 │ FcmService
         ▼                                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Firebase Cloud Messaging                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Phase 0: 사전 준비 (Firebase Console)

### 2.1 작업 목록

| # | 작업 | 담당 | 예상 시간 |
|---|------|------|----------|
| 0-1 | Firebase 프로젝트 생성 | 공통 | 10분 |
| 0-2 | Android 앱 등록 (패키지: com.pnu.basketball) | 프론트 | 5분 |
| 0-3 | google-services.json 다운로드 및 배치 | 프론트 | 5분 |
| 0-4 | Cloud Messaging API 활성화 | 공통 | 2분 |
| 0-5 | 서비스 계정 키(JSON) 생성 및 다운로드 | 백엔드 | 5분 |

### 2.2 상세 절차

#### 0-1. Firebase 프로젝트 생성
1. https://console.firebase.google.com/ 접속
2. **프로젝트 추가** → 이름: `ddalba` (또는 PNUBasketballPlatform)
3. Google Analytics: 선택 사항

#### 0-2. Android 앱 등록
1. 프로젝트 설정 → **앱 추가** → Android
2. 패키지 이름: `com.pnu.basketball`
3. 앱 닉네임: `딸바` (선택)
4. SHA-1: 디버그 키는 나중에 추가 가능

#### 0-3. google-services.json 배치
- 다운로드한 파일을 `frontend/android/app/google-services.json`에 저장
- `.gitignore`에 `google-services.json` 포함 여부 확인 (민감정보이므로 팀 정책에 따름)

#### 0-4. Cloud Messaging 활성화
- Firebase Console → 프로젝트 설정 → Cloud Messaging 탭
- Cloud Messaging API (Legacy) 활성화 (필요 시)

#### 0-5. 서비스 계정 키
1. 프로젝트 설정 → **서비스 계정** 탭
2. **새 비공개 키 생성** → JSON 다운로드
3. 파일명: `firebase-service-account.json`
4. 저장 위치: `backend/src/main/resources/` (또는 환경변수로 경로 지정)
5. **반드시** `.gitignore`에 추가

---

## 3. Phase 1: 백엔드 구현

### 3.1 작업 목록

| # | 작업 | 파일 | 예상 시간 |
|---|------|------|----------|
| 1-1 | Firebase Admin SDK 의존성 추가 | build.gradle | 2분 |
| 1-2 | User 엔티티에 FCM 토큰 필드 추가 | User.java | 5분 |
| 1-3 | DB 스키마 변경 (마이그레이션) | V*__add_fcm_token.sql | 5분 |
| 1-4 | FcmTokenRequest DTO 생성 | dto/request/ | 3분 |
| 1-5 | UserService에 updateFcmToken 메서드 추가 | UserService, UserServiceImpl | 10분 |
| 1-6 | UserController에 FCM 토큰 등록 API 추가 | UserController.java | 5분 |
| 1-7 | FcmService 클래스 생성 (초기화 + 발송) | service/notification/ | 30분 |
| 1-8 | FcmService 설정 클래스 (Bean 등록) | config/ | 10분 |

### 3.2 상세 구현 사양

#### 1-1. build.gradle 의존성

```gradle
// backend/build.gradle - dependencies 블록에 추가
implementation 'com.google.firebase:firebase-admin:9.2.0'
```

#### 1-2. User 엔티티 수정

**파일:** `backend/src/main/java/com/pnu/basketball/domain/User.java`

```java
// 추가할 필드
@Column(name = "fcm_token", length = 500)
private String fcmToken;

@Column(name = "fcm_token_updated_at")
private LocalDateTime fcmTokenUpdatedAt;

// 추가할 메서드
public void updateFcmToken(String fcmToken) {
    this.fcmToken = fcmToken;
    this.fcmTokenUpdatedAt = LocalDateTime.now();
}

public void clearFcmToken() {
    this.fcmToken = null;
    this.fcmTokenUpdatedAt = null;
}
```

#### 1-3. DB 마이그레이션

**옵션 A: Flyway 사용 시**
- `backend/src/main/resources/db/migration/V{다음버전}__add_fcm_token_to_users.sql`

```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token VARCHAR(500);
ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token_updated_at TIMESTAMP;
```

**옵션 B: Flyway 미사용 시**
- `application.yml`의 `spring.jpa.hibernate.ddl-auto`가 `update`이면 엔티티 수정만으로 반영 가능 (운영 환경에서는 권장하지 않음)

#### 1-4. FcmTokenRequest DTO

**파일:** `backend/src/main/java/com/pnu/basketball/dto/request/FcmTokenRequest.java`

```java
package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class FcmTokenRequest {
    @NotBlank(message = "FCM 토큰은 필수입니다.")
    private String fcmToken;
}
```

#### 1-5. UserService 확장

**UserService.java** - 인터페이스에 추가:
```java
void updateFcmToken(Long userId, String fcmToken);
void clearFcmToken(Long userId);
```

**UserServiceImpl.java** - 구현:
```java
@Override
public void updateFcmToken(Long userId, String fcmToken) {
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
    user.updateFcmToken(fcmToken);
    userRepository.save(user);
}

@Override
public void clearFcmToken(Long userId) {
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
    user.clearFcmToken();
    userRepository.save(user);
}
```

#### 1-6. UserController API

**파일:** `backend/src/main/java/com/pnu/basketball/controller/auth/UserController.java`

```java
@PostMapping("/me/fcm-token")
@Operation(summary = "FCM 토큰 등록", description = "푸시 알림 수신을 위한 FCM 토큰을 등록합니다.")
public ResponseEntity<ApiResponse<Void>> registerFcmToken(
        @AuthenticationPrincipal Long userId,
        @Valid @RequestBody FcmTokenRequest request) {
    userService.updateFcmToken(userId, request.getFcmToken());
    return ResponseEntity.ok(ApiResponse.success(null, "FCM 토큰이 등록되었습니다."));
}

@DeleteMapping("/me/fcm-token")
@Operation(summary = "FCM 토큰 삭제", description = "로그아웃 시 FCM 토큰을 삭제합니다.")
public ResponseEntity<ApiResponse<Void>> removeFcmToken(
        @AuthenticationPrincipal Long userId) {
    userService.clearFcmToken(userId);
    return ResponseEntity.ok(ApiResponse.success(null, "FCM 토큰이 삭제되었습니다."));
}
```

**참고:** `/api/users/me` 경로가 UserController에 있는지 확인. 현재 UserController는 `/api/users` 매핑.

#### 1-7. FcmService 클래스

**파일:** `backend/src/main/java/com/pnu/basketball/service/notification/FcmService.java`

```java
package com.pnu.basketball.service.notification;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.*;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Slf4j
@Service
@RequiredArgsConstructor
public class FcmService {

    private final UserRepository userRepository;

    @Value("${firebase.service-account-path:classpath:firebase-service-account.json}")
    private Resource serviceAccountResource;

    private FirebaseMessaging firebaseMessaging;

    @PostConstruct
    public void init() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccountResource.getInputStream()))
                        .build();
                FirebaseApp.initializeApp(options);
            }
            this.firebaseMessaging = FirebaseMessaging.getInstance();
            log.info("Firebase Admin SDK 초기화 완료");
        } catch (IOException e) {
            log.error("Firebase 초기화 실패: {}", e.getMessage());
            throw new RuntimeException("Firebase 초기화 실패", e);
        }
    }

    public void sendToUser(Long userId, String title, String body) {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null || user.getFcmToken() == null) return;
        sendToToken(user.getFcmToken(), title, body);
    }

    public void sendToToken(String fcmToken, String title, String body) {
        sendToToken(fcmToken, title, body, null);
    }

    public void sendToToken(String fcmToken, String title, String body, java.util.Map<String, String> data) {
        try {
            Message.Builder builder = Message.builder()
                    .setToken(fcmToken)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .setAndroidConfig(AndroidConfig.builder()
                            .setPriority(AndroidConfig.Priority.HIGH)
                            .setNotification(AndroidNotification.builder()
                                    .setChannelId("high_importance_channel")
                                    .build())
                            .build())
                    .setApnsConfig(ApnsConfig.builder()
                            .setAps(Aps.builder().setSound("default").build())
                            .build());
            if (data != null && !data.isEmpty()) {
                data.forEach(builder::putData);
            }
            builder.putData("click_action", "FLUTTER_NOTIFICATION_CLICK");
            firebaseMessaging.sendAsync(builder.build());
        } catch (Exception e) {
            log.warn("FCM 발송 실패: token={}, error={}", fcmToken != null ? "***" : null, e.getMessage());
        }
    }

    public void sendToMultipleUsers(List<Long> userIds, String title, String body) {
        List<User> users = userRepository.findAllById(userIds);
        users.stream()
                .filter(u -> u.getFcmToken() != null)
                .forEach(u -> sendToToken(u.getFcmToken(), title, body));
    }
}
```

#### 1-8. application.yml 설정

```yaml
# application.yml 또는 application-local.yml
firebase:
  service-account-path: classpath:firebase-service-account.json
# 또는 절대 경로: file:/path/to/firebase-service-account.json
```

---

## 4. Phase 2: Flutter 프론트엔드 구현

### 4.1 작업 목록

| # | 작업 | 파일 | 예상 시간 |
|---|------|------|----------|
| 2-1 | pubspec.yaml 의존성 추가 | pubspec.yaml | 3분 |
| 2-2 | Android build.gradle 수정 | android/build.gradle.kts, app/build.gradle.kts | 10분 |
| 2-3 | AndroidManifest.xml 권한 및 메타데이터 추가 | AndroidManifest.xml | 5분 |
| 2-4 | FcmService 클래스 생성 | lib/services/fcm_service.dart | 40분 |
| 2-5 | ApiEndpoints에 FCM API 추가 | api_endpoints.dart | 2분 |
| 2-6 | AuthService에 registerFcmToken 메서드 추가 | auth_service.dart | 5분 |
| 2-7 | AuthRepository에 FCM 토큰 등록 로직 추가 | auth_repository.dart | 10분 |
| 2-8 | main.dart에서 Firebase 및 FCM 초기화 | main.dart | 10분 |
| 2-9 | AuthProvider에서 로그인 후 FCM 토큰 등록 | auth_provider.dart | 15분 |
| 2-10 | 로그아웃 시 FCM 토큰 삭제 API 호출 | auth_repository.dart | 5분 |

### 4.2 상세 구현 사양

#### 2-1. pubspec.yaml

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^17.0.0
```

#### 2-2. Android Gradle 설정

**frontend/android/settings.gradle** (또는 build.gradle.kts) - plugins 블록에:
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

**frontend/android/app/build.gradle.kts** - plugins에 추가:
```kotlin
id("com.google.gms.google-services")
```

**frontend/android/build.gradle.kts** (프로젝트 레벨) - subprojects 전에:
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

#### 2-3. AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Android 13+ 알림 권한 -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application ...>
        <!-- 기존 내용 -->
        
        <!-- FCM 기본 알림 채널 -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
    </application>
</manifest>
```

#### 2-4. FcmService 클래스

**파일:** `frontend/lib/services/fcm_service.dart`

```dart
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // 백그라운드 수신 시 추가 처리 (선택)
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    '농구 매칭 알림',
    description: '매칭, 채팅 등 중요 알림',
    importance: Importance.high,
  );

  static Future<void> init() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _localNotifications.show(
          message.hashCode,
          message.notification!.title ?? '알림',
          message.notification!.body ?? '',
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // 알림 탭 시 네비게이션 처리
  }

  static void _handleNotificationOpened(RemoteMessage message) {
    // data.payload 등으로 화면 이동
  }

  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  static Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
```

#### 2-5. ApiEndpoints

```dart
static const String fcmToken = '/api/users/me/fcm-token';
```

#### 2-6. AuthService

```dart
Future<ApiResponseModel<void>> registerFcmToken({
  required String accessToken,
  required String fcmToken,
}) async {
  return await apiService.post<void>(
    ApiEndpoints.fcmToken,
    headers: {'Authorization': 'Bearer $accessToken'},
    body: {'fcmToken': fcmToken},
  );
}

Future<ApiResponseModel<void>> removeFcmToken({
  required String accessToken,
}) async {
  return await apiService.delete<void>(
    ApiEndpoints.fcmToken,
    headers: {'Authorization': 'Bearer $accessToken'},
  );
}
```

#### 2-7. AuthRepository - FCM 토큰 등록

```dart
Future<void> registerFcmToken() async {
  final accessToken = await getAccessToken();
  if (accessToken == null) return;

  final token = await FcmService.getToken();
  if (token == null) return;

  try {
    await authService.registerFcmToken(
      accessToken: accessToken,
      fcmToken: token,
    );
  } catch (e) {
    print('FCM 토큰 등록 실패: $e');
  }
}

// onTokenRefresh 리스너 등록 (앱 생명주기 동안)
void setupFcmTokenRefreshListener() {
  FcmService.onTokenRefresh.listen((newToken) async {
    await registerFcmToken();
  });
}
```

#### 2-8. main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await FcmService.init();

  const nativeAppKey = String.fromEnvironment(...);
  KakaoSdk.init(nativeAppKey: nativeAppKey);

  runApp(const BasketballApp());
}
```

#### 2-9. AuthProvider - 로그인 후 FCM 등록

`login`, `signup`, `kakaoLogin`, `googleLogin` 성공 후, `_saveTokens` 호출 직후에:

```dart
// 각 로그인 메서드 성공 블록 내
authRepository.registerFcmToken();
authRepository.setupFcmTokenRefreshListener();
```

`initialize()` 성공 시(토큰 유효 시)에도:
```dart
authRepository.registerFcmToken();
authRepository.setupFcmTokenRefreshListener();
```

#### 2-10. 로그아웃 시 FCM 토큰 삭제

`AuthRepository.logout()` 내, `authService.logout()` 호출 전에:
```dart
try {
  final accessToken = await getAccessToken();
  if (accessToken != null) {
    await authService.removeFcmToken(accessToken: accessToken);
  }
} catch (_) {}
```

---

## 5. Phase 3: 알림 발송 시나리오 연동

### 5.1 발송 시나리오 (우선순위)

| # | 시나리오 | 발송 대상 | 제목 예시 | 연동 위치 |
|---|----------|----------|----------|----------|
| 1 | 매칭 참여 요청 | 매칭 생성자 | "새로운 매칭 참여 요청이 있습니다" | MatchParticipantService (추후 구현) |
| 2 | 댓글 알림 | 게시글 작성자 | "내 게시글에 댓글이 달렸어요" | CommentServiceImpl.createComment |
| 3 | 매칭 D-1 리마인더 | 매칭 참가자 | "내일 농구 매칭이 있어요!" | 스케줄러 (추후 구현) |
| 4 | 동아리 공지 | 동아리 멤버 | "동아리 공지: {제목}" | AdminService.createPost (pin 시) |

### 5.2 연동 예시: 댓글 알림

**CommentServiceImpl.createComment** 수정:

```java
// 댓글 작성 후, 게시글 작성자에게 알림 (본인 제외)
if (!post.getUser().getUserId().equals(userId)) {
    fcmService.sendToUser(
        post.getUser().getUserId(),
        "새 댓글",
        user.getRealName() + "님이 회원님의 게시글에 댓글을 남겼습니다."
    );
}
```

---

## 6. Phase 4: 테스트 및 검증

### 6.1 체크리스트

| # | 항목 | 방법 |
|---|------|------|
| 1 | FCM 토큰 발급 | 앱 실행 → 로그인 → 로그 확인 |
| 2 | 토큰 DB 저장 | `/api/users/me/fcm-token` 호출 후 DB 조회 |
| 3 | 포그라운드 알림 | 앱 켜진 상태에서 푸시 발송 테스트 |
| 4 | 백그라운드 알림 | 앱 최소화 후 푸시 발송 테스트 |
| 5 | 알림 탭 시 동작 | 알림 탭 → 앱 열림 확인 |
| 6 | 토큰 갱신 | 앱 재설치/데이터 삭제 후 재로그인 → 토큰 재등록 확인 |
| 7 | 로그아웃 시 토큰 삭제 | 로그아웃 후 DB에서 fcm_token null 확인 |

### 6.2 테스트용 API (개발 환경)

```java
@PostMapping("/admin/test-fcm")
public ResponseEntity<Void> testFcm(@AuthenticationPrincipal Long userId) {
    fcmService.sendToUser(userId, "테스트 알림", "FCM 연동이 정상입니다.");
    return ResponseEntity.ok().build();
}
```

---

## 7. 일정 및 마일스톤

| Phase | 내용 | 예상 소요 | 완료 기준 |
|-------|------|----------|----------|
| Phase 0 | Firebase Console 설정 | 0.5일 | google-services.json, 서비스 계정 키 확보 |
| Phase 1 | 백엔드 구현 | 1일 | FCM 토큰 등록 API 동작, FcmService 발송 가능 |
| Phase 2 | Flutter 구현 | 1.5일 | 로그인 후 토큰 등록, 포그라운드/백그라운드 알림 수신 |
| Phase 3 | 시나리오 연동 | 1일 | 댓글 알림 등 1개 이상 연동 |
| Phase 4 | 테스트 | 0.5일 | 체크리스트 통과 |

**총 예상 기간: 4~5일**

---

## 8. 주의사항 및 리스크

### 8.1 보안
- `firebase-service-account.json`, `google-services.json`은 `.gitignore` 필수
- CI/CD에서는 환경 변수 또는 시크릿 관리자 사용

### 8.2 iOS 지원 (추후)
- Xcode에서 Push Notifications, Background Modes 활성화
- `GoogleService-Info.plist` 추가
- APNs 인증서/키 설정

### 8.3 에뮬레이터
- Android 에뮬레이터: Google Play 서비스 포함 이미지 사용 시 FCM 동작
- iOS 시뮬레이터: 푸시 미지원 → 실기기 필수

---

## 9. 참고 자료

- [Firebase Cloud Messaging 문서](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging](https://firebase.flutter.dev/docs/messaging/overview/)
- [Firebase Admin SDK (Java)](https://firebase.google.com/docs/admin/setup)
