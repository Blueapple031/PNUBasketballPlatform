import 'package:json_annotation/json_annotation.dart';

part 'club_model.g.dart';

@JsonSerializable()
class ClubModel {
  final String clubId;
  final String name;
  final String? logoUrl;
ㅎㅎ  final String? introduction;
  final int memberCount;

  ClubModel({
    required this.clubId,
    required this.name,
    this.logoUrl,
    this.introduction,
    required this.memberCount,
  });

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
