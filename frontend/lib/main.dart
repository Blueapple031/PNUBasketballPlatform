import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화 (KAKAO_NATIVE_APP_KEY 환경변수 필요)
  const nativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
    defaultValue: '',
  );
  if (nativeAppKey.isNotEmpty) {
    KakaoSdk.init(nativeAppKey: nativeAppKey);
  }

  runApp(const BasketballApp());
}

