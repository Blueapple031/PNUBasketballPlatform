class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8080';
  
  // Auth endpoints
  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';
  static const String googleLogin = '/api/auth/google';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';
  static const String checkEmail = '/api/auth/check-email';
  static const String checkNickname = '/api/auth/check-nickname';
}

