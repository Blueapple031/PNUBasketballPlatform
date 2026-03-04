import 'package:json_annotation/json_annotation.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
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

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

@JsonSerializable()
class UserInfo {
  final int userId;
  final String email;
  final String realName;
  final String? profileImageUrl;
  final String loginType;
  final bool? isNewUser;
  final bool? needsClubSelection;

  UserInfo({
    required this.userId,
    required this.email,
    required this.realName,
    this.profileImageUrl,
    required this.loginType,
    this.isNewUser,
    this.needsClubSelection,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

