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
  final String? nickname;
  final String? position;
  final int exp;
  final int noShowCount;
  final int participationCount;

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
    this.nickname,
    this.position,
    this.exp = 0,
    this.noShowCount = 0,
    this.participationCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as int,
      email: json['email'] as String? ?? '',
      realName: json['realName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      loginType: json['loginType'] as String? ?? 'EMAIL',
      dateOfBirth: json['dateOfBirth'] as String?,
      isPnuStudent: json['isPnuStudent'] as bool?,
      department: json['department'] as String?,
      studentId: json['studentId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      nickname: json['nickname'] as String?,
      position: json['position'] as String?,
      exp: (json['exp'] as num?)?.toInt() ?? 0,
      noShowCount: (json['noShowCount'] as num?)?.toInt() ?? 0,
      participationCount: (json['participationCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'realName': realName,
        'phoneNumber': phoneNumber,
        'profileImageUrl': profileImageUrl,
        'loginType': loginType,
        'dateOfBirth': dateOfBirth,
        'isPnuStudent': isPnuStudent,
        'department': department,
        'studentId': studentId,
        'createdAt': createdAt.toIso8601String(),
        'nickname': nickname,
        'position': position,
        'exp': exp,
        'noShowCount': noShowCount,
        'participationCount': participationCount,
      };

  String get positionDisplayName {
    switch (position) {
      case 'GUARD':
        return '가드';
      case 'FORWARD':
        return '포워드';
      case 'CENTER':
        return '센터';
      default:
        return position ?? '미설정';
    }
  }

  String get expLevelName {
    if (exp >= 300) return '올스타';
    if (exp >= 100) return '슈터';
    return '루키';
  }
}
