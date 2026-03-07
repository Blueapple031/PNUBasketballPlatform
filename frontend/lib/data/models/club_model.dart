import 'member_model.dart';

enum ClubCategory {
  central,
  department,
  smallGroup,
}

class ClubModel {
  final int clubId;
  final String slug;
  final ClubCategory category;
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
    required this.clubId,
    required this.slug,
    required this.category,
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
      clubId: 1,
      slug: 'pnu-hoopers',
      category: ClubCategory.central,
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

  static List<ClubModel> dummyList() {
    final firstClub = ClubModel.dummy();

    const alphaCaptain = MemberModel(
      name: '문주장',
      role: '주장',
      profileImageUrl: 'https://i.pravatar.cc/150?img=21',
    );

    const betaCaptain = MemberModel(
      name: '오주장',
      role: '주장',
      profileImageUrl: 'https://i.pravatar.cc/150?img=31',
    );

    final secondClub = ClubModel(
      clubId: 2,
      slug: 'blue-rim',
      category: ClubCategory.department,
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png',
      clubName: 'Blue Rim',
      schoolName: '부산대학교',
      memberCount: 14,
      foundedYear: 2019,
      homeCourt: '금정체육관 보조코트',
      intro: 'Blue Rim은 3대3 교류전 중심으로 활동하는 동아리입니다.',
      captain: alphaCaptain,
      members: const [
        alphaCaptain,
        MemberModel(
          name: '강부주장',
          role: '부주장',
          profileImageUrl: 'https://i.pravatar.cc/150?img=22',
        ),
        MemberModel(
          name: '윤멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=23',
        ),
      ],
    );

    final thirdClub = ClubModel(
      clubId: 3,
      slug: 'campus-five',
      category: ClubCategory.smallGroup,
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png',
      clubName: 'Campus Five',
      schoolName: '부산대학교',
      memberCount: 20,
      foundedYear: 2015,
      homeCourt: '문창회관 실내 코트',
      intro: 'Campus Five는 학내 대회 출전을 목표로 정기 훈련을 운영합니다.',
      captain: betaCaptain,
      members: const [
        betaCaptain,
        MemberModel(
          name: '한부주장',
          role: '부주장',
          profileImageUrl: 'https://i.pravatar.cc/150?img=32',
        ),
        MemberModel(
          name: '백멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=33',
        ),
        MemberModel(
          name: '남멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=34',
        ),
      ],
    );

    final fourthClub = ClubModel(
      clubId: 4,
      slug: 'rim-rangers',
      category: ClubCategory.central,
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png',
      clubName: 'Rim Rangers',
      schoolName: '부산대학교',
      memberCount: 16,
      foundedYear: 2018,
      homeCourt: '효원문화회관 코트',
      intro: 'Rim Rangers는 교내 교류전 중심으로 운영되는 중앙 동아리입니다.',
      captain: const MemberModel(
        name: '권주장',
        role: '주장',
        profileImageUrl: 'https://i.pravatar.cc/150?img=41',
      ),
      members: const [
        MemberModel(
          name: '권주장',
          role: '주장',
          profileImageUrl: 'https://i.pravatar.cc/150?img=41',
        ),
        MemberModel(
          name: '신멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=42',
        ),
      ],
    );

    final fifthClub = ClubModel(
      clubId: 5,
      slug: 'mechanic-dribblers',
      category: ClubCategory.department,
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png',
      clubName: '기계과 Dribblers',
      schoolName: '부산대학교',
      memberCount: 12,
      foundedYear: 2020,
      homeCourt: '공대 농구장',
      intro: '기계과 Dribblers는 학과 교류전과 친선 경기를 운영합니다.',
      captain: const MemberModel(
        name: '조주장',
        role: '주장',
        profileImageUrl: 'https://i.pravatar.cc/150?img=51',
      ),
      members: const [
        MemberModel(
          name: '조주장',
          role: '주장',
          profileImageUrl: 'https://i.pravatar.cc/150?img=51',
        ),
        MemberModel(
          name: '노멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=52',
        ),
      ],
    );

    final sixthClub = ClubModel(
      clubId: 6,
      slug: 'night-shot',
      category: ClubCategory.smallGroup,
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png',
      clubName: 'Night Shot',
      schoolName: '부산대학교',
      memberCount: 10,
      foundedYear: 2021,
      homeCourt: '야간 체육관 코트',
      intro: 'Night Shot은 야간 훈련 중심의 친목 소모임입니다.',
      captain: const MemberModel(
        name: '임주장',
        role: '주장',
        profileImageUrl: 'https://i.pravatar.cc/150?img=61',
      ),
      members: const [
        MemberModel(
          name: '임주장',
          role: '주장',
          profileImageUrl: 'https://i.pravatar.cc/150?img=61',
        ),
        MemberModel(
          name: '서멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=62',
        ),
      ],
    );

    final seventhClub = ClubModel(
      clubId: 7,
      slug: 'eagles-united',
      category: ClubCategory.central,
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png',
      clubName: 'Eagles United',
      schoolName: '부산대학교',
      memberCount: 22,
      foundedYear: 2014,
      homeCourt: '효원체육관 A코트',
      intro: 'Eagles United는 교내외 대회 참가 중심의 중앙 동아리입니다.',
      captain: const MemberModel(
        name: '장주장',
        role: '주장',
        profileImageUrl: 'https://i.pravatar.cc/150?img=71',
      ),
      members: const [
        MemberModel(
          name: '장주장',
          role: '주장',
          profileImageUrl: 'https://i.pravatar.cc/150?img=71',
        ),
        MemberModel(
          name: '배멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=72',
        ),
      ],
    );

    final eighthClub = ClubModel(
      clubId: 8,
      slug: 'fastbreakers',
      category: ClubCategory.central,
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png',
      clubName: 'Fastbreakers',
      schoolName: '부산대학교',
      memberCount: 19,
      foundedYear: 2016,
      homeCourt: '학생회관 뒤 코트',
      intro: 'Fastbreakers는 주 2회 정기전으로 운영되는 중앙 동아리입니다.',
      captain: const MemberModel(
        name: '고주장',
        role: '주장',
        profileImageUrl: 'https://i.pravatar.cc/150?img=81',
      ),
      members: const [
        MemberModel(
          name: '고주장',
          role: '주장',
          profileImageUrl: 'https://i.pravatar.cc/150?img=81',
        ),
        MemberModel(
          name: '민멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=82',
        ),
      ],
    );

    final ninthClub = ClubModel(
      clubId: 9,
      slug: 'pnu-dynamo',
      category: ClubCategory.central,
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png',
      clubName: 'PNU Dynamo',
      schoolName: '부산대학교',
      memberCount: 17,
      foundedYear: 2022,
      homeCourt: '중앙광장 농구코트',
      intro: 'PNU Dynamo는 신규 중앙 동아리로 리그전을 준비 중입니다.',
      captain: const MemberModel(
        name: '류주장',
        role: '주장',
        profileImageUrl: 'https://i.pravatar.cc/150?img=91',
      ),
      members: const [
        MemberModel(
          name: '류주장',
          role: '주장',
          profileImageUrl: 'https://i.pravatar.cc/150?img=91',
        ),
        MemberModel(
          name: '진멤버',
          role: '일반',
          profileImageUrl: 'https://i.pravatar.cc/150?img=92',
        ),
      ],
    );

    return [
      firstClub,
      secondClub,
      thirdClub,
      fourthClub,
      fifthClub,
      sixthClub,
      seventhClub,
      eighthClub,
      ninthClub,
    ];
  }
}
