import 'package:json_annotation/json_annotation.dart';
import 'member_model.dart';

part 'club_model.g.dart';

@JsonSerializable()
class ClubModel {
  final String clubId;
  final String name;
  final String? logoUrl;
  final int memberCount;
  final String? clubName;
  final String? schoolName;
  final int? foundedYear;
  final String? homeCourt;
  final String? intro;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final MemberModel? captain;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<MemberModel>? members;

  ClubModel({
    required this.clubId,
    required this.name,
    this.logoUrl,
    required this.memberCount,
    this.clubName,
    this.schoolName,
    this.foundedYear,
    this.homeCourt,
    this.intro,
    this.captain,
    this.members,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) =>
      _$ClubModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClubModelToJson(this);

  factory ClubModel.dummy() {
    const captain = MemberModel(
      name: '김주장',
      role: '주장',
      profileImageUrl: 'https://i.pravatar.cc/150?img=11',
    );

    return ClubModel(
      clubId: 'dummy-club-id',
      name: 'PNU Hoopers',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png',
      clubName: 'PNU Hoopers',
      schoolName: '부산대학교',
      memberCount: 18,
      foundedYear: 2017,
      homeCourt: '부산대학교 대운동장 농구코트',
      intro:
          'PNU Hoopers는 학내/교내 농구 교류전을 중심으로 활동하는 동아리입니다. 매주 정기 훈련과 친선 경기를 운영합니다.',
      captain: captain,
      members: const [
        captain,
        MemberModel(
          name: '이부주장',
          role: '부주장',
          profileImageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        MemberModel(
          name: '박멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=13',
        ),
        MemberModel(
          name: '최멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=14',
        ),
        MemberModel(
          name: '정멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=15',
        ),
      ],
    );
  }
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
