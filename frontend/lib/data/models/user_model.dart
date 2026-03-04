import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int userId;
  final String email;
  final String realName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String loginType;
  final String? dateOfBirth;
  final bool? isPnuStudent;
  final String? department;
  final String? studentId;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.realName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.loginType,
    this.dateOfBirth,
    this.isPnuStudent,
    this.department,
    this.studentId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

