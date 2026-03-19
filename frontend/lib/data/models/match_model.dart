class MatchModel {
  final String id;
  final String sourceType;
  final String? recruitmentId;
  final String locationName;
  final DateTime startAt;
  final DateTime endAt;
  final String? gameFormat;
  final DateTime createdAt;

  MatchModel({
    required this.id,
    required this.sourceType,
    this.recruitmentId,
    required this.locationName,
    required this.startAt,
    required this.endAt,
    this.gameFormat,
    required this.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id']?.toString() ?? '',
      sourceType: json['sourceType'] as String? ?? '',
      recruitmentId: json['recruitmentId']?.toString(),
      locationName: json['locationName'] as String? ?? '',
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      gameFormat: json['gameFormat'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isRecruitment => sourceType == 'RECRUITMENT';
  bool get isClubMatch => sourceType == 'CLUB_MATCH';
  bool get isEnded => DateTime.now().isAfter(endAt);

  String get gameFormatDisplay {
    switch (gameFormat) {
      case 'THREE_VS_THREE':
        return '3:3';
      case 'FOUR_VS_FOUR':
        return '4:4';
      case 'FIVE_VS_FIVE':
        return '5:5';
      case 'FLEXIBLE':
        return '자유';
      default:
        return gameFormat ?? '5:5';
    }
  }
}

class ReviewFormModel {
  final String matchId;
  final DateTime startAt;
  final DateTime endAt;
  final String locationName;
  final bool alreadySubmitted;
  final List<ParticipantModel> participants;

  ReviewFormModel({
    required this.matchId,
    required this.startAt,
    required this.endAt,
    required this.locationName,
    required this.alreadySubmitted,
    required this.participants,
  });

  factory ReviewFormModel.fromJson(Map<String, dynamic> json) {
    final list = json['participants'] as List<dynamic>? ?? [];
    return ReviewFormModel(
      matchId: json['matchId']?.toString() ?? '',
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      locationName: json['locationName'] as String? ?? '',
      alreadySubmitted: json['alreadySubmitted'] as bool? ?? false,
      participants: list
          .map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ParticipantModel {
  final int userId;
  final String nickname;
  final String? position;
  final int exp;

  ParticipantModel({
    required this.userId,
    required this.nickname,
    this.position,
    required this.exp,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      nickname: json['nickname'] as String? ?? '',
      position: json['position'] as String?,
      exp: (json['exp'] as num?)?.toInt() ?? 0,
    );
  }

  String get positionDisplay {
    switch (position) {
      case 'GUARD':
        return '가드';
      case 'FORWARD':
        return '포워드';
      case 'CENTER':
        return '센터';
      default:
        return position ?? '';
    }
  }
}
