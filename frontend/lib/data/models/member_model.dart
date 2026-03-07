class MemberModel {
  final String name;
  final String role;
  final String profileImageUrl;

  const MemberModel({
    required this.name,
    required this.role,
    required this.profileImageUrl,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '동아리원',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
    );
  }
}
