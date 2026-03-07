import 'member_model.dart';

import 'package:json_annotation/json_annotation.dart';

part 'club_model.g.dart';

enum ClubCategory {
  central,
  department,
  smallGroup,
}

@JsonSerializable()
class ClubModel {
  final String clubId;
  final String name;
  final String? logoUrl;
  final String? introduction;
  final int memberCount;
  final String? captainName;
  final String? captainProfileImageUrl;
  final bool? isCaptain;

  ClubModel({
    required this.clubId,
    required this.name,
    this.logoUrl,
    this.introduction,
    required this.memberCount,
    this.captainName,
    this.captainProfileImageUrl,
    this.isCaptain,
  });

  ClubModel copyWith({
    String? clubId,
    String? name,
    String? logoUrl,
    String? introduction,
    int? memberCount,
    String? captainName,
    String? captainProfileImageUrl,
    bool? isCaptain,
  }) {
    return ClubModel(
      clubId: clubId ?? this.clubId,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      introduction: introduction ?? this.introduction,
      memberCount: memberCount ?? this.memberCount,
      captainName: captainName ?? this.captainName,
      captainProfileImageUrl: captainProfileImageUrl ?? this.captainProfileImageUrl,
      isCaptain: isCaptain ?? this.isCaptain,
    );
  }

  factory ClubModel.fromJson(Map<String, dynamic> json) =>
      _$ClubModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClubModelToJson(this);
}

@JsonSerializable()
class ClubSelectionStatusModel {
  final bool needsClubSelection;

  ClubSelectionStatusModel({required this.needsClubSelection});

  factory ClubSelectionStatusModel.fromJson(Map<String, dynamic> json) =>
      _$ClubSelectionStatusModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClubSelectionStatusModelToJson(this);
}

@JsonSerializable()
class ClubSelectResultModel {
  final String clubId;
  final String clubName;
  final String role;

  ClubSelectResultModel({
    required this.clubId,
    required this.clubName,
    required this.role,
  });

  factory ClubSelectResultModel.fromJson(Map<String, dynamic> json) =>
      _$ClubSelectResultModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClubSelectResultModelToJson(this);
}
