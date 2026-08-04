import 'package:basketball_frontend/core/constants/api_endpoints.dart';
import 'package:basketball_frontend/data/services/api_service.dart';
import 'package:basketball_frontend/data/services/auth_service.dart';
import 'package:basketball_frontend/presentation/widgets/user/settings_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('계정 삭제 API가 인증 헤더와 DELETE 메서드를 사용한다', () async {
    final client = MockClient((request) async {
      expect(request.method, 'DELETE');
      expect(request.url.path, ApiEndpoints.userMe);
      expect(request.headers['Authorization'], 'Bearer test-token');

      return http.Response(
        '{"success":true,"data":null,"message":"회원 탈퇴가 성공적으로 처리되었습니다."}',
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = AuthService(
      apiService: ApiService(baseUrl: 'https://example.com', client: client),
    );

    final response = await service.deleteAccount(accessToken: 'test-token');

    expect(response.success, isTrue);
  });

  testWidgets('설정의 탈퇴 메뉴가 전달된 콜백을 실행한다', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsList(
            onDeleteAccount: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('탈퇴'));

    expect(tapped, isTrue);
  });
}
