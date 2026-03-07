class ApiEndpoints {
  // 개발: localhost (기본값)
  // 배포: flutter run --dart-define=API_BASE_URL=https://ddalba.duckdns.org
  // Android 에뮬레이터: http://10.0.2.2:8080
  // 실제 기기: http://<PC IP>:8080
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://ddalba.duckdns.org');
      //String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');
  
  // Auth endpoints
  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';
  static const String googleLogin = '/api/auth/google';
  static const String kakaoLogin = '/api/auth/kakao';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';
  static const String checkEmail = '/api/auth/check-email';
  static const String completeProfile = '/api/auth/complete-profile';
  static const String clubSelectionStatus = '/api/auth/club-selection/status';

  // Club endpoints
  static const String clubs = '/api/clubs';
  static const String clubMe = '/api/clubs/me';
  static const String clubSelect = '/api/clubs/select';

  // User endpoints
  static const String userMe = '/api/users/me';
  static const String userPassword = '/api/users/me/password';
}
