# PNU Basketball Flutter app

## Android 실행

```bash
flutter run --dart-define-from-file=dart_defines.json
```

## iOS 실행

iOS 빌드는 macOS와 Xcode가 필요하다. 최초 1회 다음 설정을 완료한다.

1. `ios/Runner/GoogleService-Info.plist`는 번들 ID `com.pnu.basketball`인 Firebase iOS 앱 설정이며 Runner 타깃에 연결되어 있다. Firebase에서 다시 내려받았다면 같은 경로의 파일만 교체한다.
2. Google 로그인을 사용하려면 Firebase Authentication에서 Google 로그인을 활성화한 뒤 plist를 다시 내려받는다. 해당 파일의 `REVERSED_CLIENT_ID`를 `ios/Runner/Info.plist`의 `CFBundleURLTypes`에 두 번째 URL scheme으로 추가하고, `CLIENT_ID`는 `GIDClientID`, 웹 클라이언트 ID는 `GIDServerClientID`로 추가한다.
3. Firebase Console의 Project Settings > Cloud Messaging에 Apple APNs 인증 키를 등록한다.
4. Xcode의 Runner 타깃에서 Team을 선택하고 Signing & Capabilities에 Push Notifications와 Background Modes > Remote notifications가 켜졌는지 확인한다.
5. Kakao Developers에 iOS 번들 ID `com.pnu.basketball`을 등록한다.

그다음 프로젝트 루트의 `frontend` 디렉터리에서 실행한다.

```bash
flutter pub get
flutter run --dart-define-from-file=dart_defines.json
```

현재 Firebase와 FCM 설정은 연결되어 있다. Google 로그인은 Firebase에서 Google 제공업체를 활성화하고 OAuth 클라이언트 정보가 포함된 plist로 교체한 뒤 URL scheme을 추가해야 한다.
