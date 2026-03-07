import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화 (run.ps1 사용 시 gradle.properties 키 전달)
  const nativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
    defaultValue: '',
  );
  KakaoSdk.init(nativeAppKey: nativeAppKey);

  runApp(const BasketballApp());
}

