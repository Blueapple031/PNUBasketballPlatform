import 'member_model.dart';

class ClubModel {
  final String logoUrl;
  final String clubName;
  final String schoolName;
  final int memberCount;
  final int foundedYear;
  final String homeCourt;
  final String intro;
  final MemberModel captain;
  final List<MemberModel> members;

  const ClubModel({
    required this.logoUrl,
    required this.clubName,
    required this.schoolName,
    required this.memberCount,
    required this.foundedYear,
    required this.homeCourt,
    required this.intro,
    required this.captain,
    required this.members,
  });

  factory ClubModel.dummy() {
    const captain = MemberModel(
      name: '김주장',
      role: '주장',
      profileImageUrl: 'https://i.pravatar.cc/150?img=11',
    );

    return ClubModel(
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
