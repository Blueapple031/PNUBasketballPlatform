/// API/네트워크 오류 시 사용자에게 보여줄 메시지
const String networkErrorMessage = '인터넷 연결을 확인해주세요';

/// 네트워크 관련 오류인지 판별 후, 적절한 메시지 반환
String toUserFriendlyMessage(Object e) {
  final msg = e.toString().toLowerCase();
  final isNetworkError = msg.contains('socketexception') ||
      msg.contains('clientexception') ||
      msg.contains('host lookup') ||
      msg.contains('connection refused') ||
      msg.contains('failed host lookup') ||
      msg.contains('timeoutexception') ||
      msg.contains('connection timed out') ||
      msg.contains('network is unreachable');
  return isNetworkError
      ? networkErrorMessage
      : e.toString().replaceFirst('Exception: ', '');
}
