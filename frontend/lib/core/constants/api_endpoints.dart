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
  static String clubMembers(String clubId) => '/api/clubs/$clubId/members';

  // User endpoints
  static const String userMe = '/api/users/me';
  static const String userPassword = '/api/users/me/password';
  static const String fcmToken = '/api/users/me/fcm-token';

  // Post (Community) endpoints
  static const String posts = '/api/posts';
  static String post(String postId) => '/api/posts/$postId';
  static String postPin(String postId) => '/api/posts/$postId/pin';
  static String postComments(String postId) => '/api/posts/$postId/comments';
  static String postComment(String postId, String commentId) =>
      '/api/posts/$postId/comments/$commentId';
  static String postPollVote(String postId) =>
      '/api/posts/$postId/polls/vote';

  // Schedule endpoints
  static const String schedules = '/api/schedules';
  static const String scheduleLocations = '/api/schedules/locations';
  static String schedule(String id) => '/api/schedules/$id';

  // Recruitment endpoints
  static const String recruitments = '/api/recruitments';
  static String recruitment(String id) => '/api/recruitments/$id';
  static String recruitmentApply(String id) => '/api/recruitments/$id/apply';
  static String recruitmentApplicationAccept(String id, String applicationId) =>
      '/api/recruitments/$id/applications/$applicationId/accept';
  static String recruitmentApplicationReject(String id, String applicationId) =>
      '/api/recruitments/$id/applications/$applicationId/reject';
  static String recruitmentConfirm(String id) => '/api/recruitments/$id/confirm';
  static String recruitmentCancel(String id) => '/api/recruitments/$id/cancel';

  // Match endpoints
  static const String matches = '/api/matches';
  static String match(String id) => '/api/matches/$id';
  static String matchComplete(String id) => '/api/matches/$id/complete';
  static String matchReviewForm(String id) => '/api/matches/$id/review-form';
  static String matchReview(String id) => '/api/matches/$id/review';

  // Club Match endpoints
  static const String clubMatchRequests = '/api/club-matches/requests';
  static String clubMatchRequest(String id) => '/api/club-matches/requests/$id';
  static String clubMatchAttend(String id) => '/api/club-matches/requests/$id/attend';
  static String clubMatchMatch(String id) => '/api/club-matches/requests/$id/match';
  static String clubMatchResult(String id) => '/api/club-matches/requests/$id/result';
  static String clubMatchApproveResult(String id) =>
      '/api/club-matches/requests/$id/approve-result';
}
