import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'app.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko', null);

  // Firebase의 iOS 설정 파일이 아직 없어도 앱 자체는 실행할 수 있게 한다.
  // 설정이 완료된 환경에서는 FCM이 정상적으로 초기화된다.
  try {
    await Firebase.initializeApp();
    await FcmService.init();
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
  }

  // 카카오 SDK 초기화 (run.ps1 사용 시 gradle.properties 키 전달)
  const nativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
    defaultValue: '',
  );
  KakaoSdk.init(nativeAppKey: nativeAppKey);

  runApp(const BasketballApp());
}
