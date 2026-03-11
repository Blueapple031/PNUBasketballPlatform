import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'app.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko', null);

  await Firebase.initializeApp();
  await FcmService.init();

  // 카카오 SDK 초기화 (run.ps1 사용 시 gradle.properties 키 전달)
  const nativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
    defaultValue: '',
  );
  KakaoSdk.init(nativeAppKey: nativeAppKey);

  runApp(const BasketballApp());
}

