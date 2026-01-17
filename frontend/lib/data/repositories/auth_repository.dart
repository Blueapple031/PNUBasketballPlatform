import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final AuthService authService;
  final FlutterSecureStorage secureStorage;
  final GoogleSignIn googleSignIn;

  AuthRepository({
    AuthService? authService,
    FlutterSecureStorage? secureStorage,
    GoogleSignIn? googleSignIn,
  })  : authService = authService ?? AuthService(),
        secureStorage = secureStorage ?? const FlutterSecureStorage(),
        googleSignIn = googleSignIn ?? GoogleSignIn();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // 자체 로그인
  Future<AuthResponseModel> signup({
    required String email,
    required String password,
    required String nickname,
    String? phoneNumber,
  }) async {
    final response = await authService.signup(
      email: email,
      password: password,
      nickname: nickname,
      phoneNumber: phoneNumber,
    );

    if (response.success && response.data != null) {
      await _saveTokens(response.data!);
      return response.data!;
    } else {
      throw Exception(response.error?['message'] ?? '회원가입 실패');
    }
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await authService.login(
      email: email,
      password: password,
    );

    if (response.success && response.data != null) {
      await _saveTokens(response.data!);
      return response.data!;
    } else {
      throw Exception(response.error?['message'] ?? '로그인 실패');
    }
  }

  // 구글 로그인
  Future<AuthResponseModel> googleLogin() async {
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) {
        throw Exception('구글 로그인이 취소되었습니다.');
      }

      final GoogleSignInAuthentication authentication =
          await account.authentication;
      final String? idToken = authentication.idToken;

      if (idToken == null) {
        throw Exception('구글 ID 토큰을 가져올 수 없습니다.');
      }

      final response = await authService.googleLogin(idToken: idToken);

      if (response.success && response.data != null) {
        await _saveTokens(response.data!);
        return response.data!;
      } else {
        throw Exception(response.error?['message'] ?? '구글 로그인 실패');
      }
    } catch (e) {
      throw Exception('구글 로그인 중 오류 발생: $e');
    }
  }

  // 토큰 관리
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> _saveTokens(AuthResponseModel authResponse) async {
    await secureStorage.write(
      key: _accessTokenKey,
      value: authResponse.accessToken,
    );
    await secureStorage.write(
      key: _refreshTokenKey,
      value: authResponse.refreshToken,
    );
  }

  Future<void> clearTokens() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();

      if (accessToken != null && refreshToken != null) {
        await authService.logout(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
    } catch (e) {
      // 로그아웃 실패해도 토큰은 삭제
      print('로그아웃 API 호출 실패: $e');
    } finally {
      await clearTokens();
      await googleSignIn.signOut();
    }
  }

  // 토큰 갱신
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return null;
      }

      final response = await authService.refreshToken(
        refreshToken: refreshToken,
      );

      if (response.success && response.data != null) {
        await secureStorage.write(
          key: _accessTokenKey,
          value: response.data!.accessToken,
        );
        return response.data!.accessToken;
      }
    } catch (e) {
      print('토큰 갱신 실패: $e');
      await clearTokens();
    }
    return null;
  }

  // 사용자 정보 조회
  Future<UserModel> getCurrentUser() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await authService.getCurrentUser(
      accessToken: accessToken,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error?['message'] ?? '사용자 정보 조회 실패');
    }
  }

  // 중복 확인
  Future<bool> checkEmailAvailability(String email) async {
    final response = await authService.checkEmail(email: email);
    if (response.success && response.data != null) {
      return response.data!['available'] as bool;
    }
    return false;
  }

  Future<bool> checkNicknameAvailability(String nickname) async {
    final response = await authService.checkNickname(nickname: nickname);
    if (response.success && response.data != null) {
      return response.data!['available'] as bool;
    }
    return false;
  }
}

