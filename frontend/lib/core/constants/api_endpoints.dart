class ApiEndpoints {
  // Override with:
  // flutter run --dart-define=API_BASE_URL=https://ddalba.duckdns.org
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://ddalba.duckdns.org');
  
  // Auth endpoints
  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';
  static const String googleLogin = '/api/auth/google';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';
  static const String checkEmail = '/api/auth/check-email';
  static const String checkNickname = '/api/auth/check-nickname';

  // User endpoints
  static const String userProfile = '/api/user/profile';
}
