class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserInfo user;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return AuthResponseModel(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      tokenType: (json['tokenType'] ?? 'Bearer').toString(),
      expiresIn: json['expiresIn'] is num
          ? (json['expiresIn'] as num).toInt()
          : 0,
      user: userJson is Map<String, dynamic>
          ? UserInfo.fromJson(userJson)
          : UserInfo.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'expiresIn': expiresIn,
        'user': user.toJson(),
      };
}

class UserInfo {
  final int userId;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final String loginType;
  final bool? isNewUser;

  UserInfo({
    required this.userId,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    required this.loginType,
    this.isNewUser,
  });

  factory UserInfo.empty() => UserInfo(
        userId: 0,
        email: '',
        nickname: '사용자',
        profileImageUrl: null,
        loginType: 'EMAIL',
        isNewUser: null,
      );

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    final email = (json['email'] ?? '').toString();
    final nicknameRaw = json['nickname'];
    final realNameRaw = json['realName'];
    final fallbackName = email.isNotEmpty ? email.split('@').first : '사용자';

    final resolvedNickname =
        (nicknameRaw is String && nicknameRaw.trim().isNotEmpty)
            ? nicknameRaw
            : (realNameRaw is String && realNameRaw.trim().isNotEmpty)
                ? realNameRaw
                : fallbackName;

    return UserInfo(
      userId: json['userId'] is num ? (json['userId'] as num).toInt() : 0,
      email: email,
      nickname: resolvedNickname,
      profileImageUrl: json['profileImageUrl']?.toString(),
      loginType: (json['loginType'] ?? 'EMAIL').toString(),
      isNewUser: json['isNewUser'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'nickname': nickname,
        'profileImageUrl': profileImageUrl,
        'loginType': loginType,
        'isNewUser': isNewUser,
      };
}

