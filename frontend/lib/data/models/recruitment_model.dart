class RecruitmentListModel {
  final String id;
  final String authorNickname;
  final DateTime startAt;
  final DateTime endAt;
  final String locationName;
  final int baseMembersCount;
  final int neededMembers;
  final int acceptedCount;
  final String gameFormat;
  final String status;
  final DateTime? deadlineAt;
  final DateTime createdAt;
  final bool isFull;

  RecruitmentListModel({
    required this.id,
    required this.authorNickname,
    required this.startAt,
    required this.endAt,
    required this.locationName,
    required this.baseMembersCount,
    required this.neededMembers,
    required this.acceptedCount,
    required this.gameFormat,
    required this.status,
    this.deadlineAt,
    required this.createdAt,
    required this.isFull,
  });

  /// ISO-8601 문자열 또는 epoch ms 지원. null/빈값/실패 시 DateTime.now() 반환 (크래시 방지)
  static DateTime _parseDateTime(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is num) {
      final ms = v.toInt();
      return DateTime.fromMillisecondsSinceEpoch(ms > 9999999999 ? ms : ms * 1000);
    }
    final s = (v as String?)?.toString().trim();
    if (s == null || s.isEmpty) return DateTime.now();
    return DateTime.tryParse(s) ?? DateTime.now();
  }

  factory RecruitmentListModel.fromJson(Map<String, dynamic> json) {
    return RecruitmentListModel(
      id: json['id']?.toString() ?? '',
      authorNickname: (json['authorNickname'] as String?) ?? '',
      startAt: _parseDateTime(json['startAt']),
      endAt: _parseDateTime(json['endAt']),
      locationName: (json['locationName'] as String?) ?? '',
      baseMembersCount: (json['baseMembersCount'] as num?)?.toInt() ?? 0,
      neededMembers: (json['neededMembers'] as num?)?.toInt() ?? 0,
      acceptedCount: (json['acceptedCount'] as num?)?.toInt() ?? 0,
      gameFormat: (json['gameFormat'] as String?) ?? 'FLEXIBLE',
      status: (json['status'] as String?) ?? 'OPEN',
      deadlineAt: json['deadlineAt'] != null
          ? _parseDateTime(json['deadlineAt'])
          : null,
      createdAt: _parseDateTime(json['createdAt']),
      isFull: (json['isFull'] as bool?) ?? (json['full'] as bool?) ?? false,
    );
  }

  int get totalNeeded => baseMembersCount + neededMembers;
  int get currentCount => baseMembersCount + acceptedCount;
  double get progressRatio =>
      neededMembers > 0 ? (acceptedCount / neededMembers).clamp(0.0, 1.0) : 0.0;

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
        return gameFormat;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'OPEN':
        return '모집중';
      case 'CONFIRMED':
        return '확정';
      case 'CLOSED':
        return '마감';
      case 'CANCELLED':
        return '취소';
      default:
        return status;
    }
  }

  bool get isOpen => status == 'OPEN';
}

class RecruitmentDetailModel {
  final String id;
  final int authorId;
  final String authorNickname;
  final DateTime startAt;
  final DateTime endAt;
  final String locationId;
  final String locationName;
  final int baseMembersCount;
  final int neededMembers;
  final int acceptedCount;
  final String gameFormat;
  final String status;
  final DateTime? deadlineAt;
  final DateTime createdAt;
  final bool isFull;
  final List<ApplicationModel> applications;

  RecruitmentDetailModel({
    required this.id,
    required this.authorId,
    required this.authorNickname,
    required this.startAt,
    required this.endAt,
    required this.locationId,
    required this.locationName,
    required this.baseMembersCount,
    required this.neededMembers,
    required this.acceptedCount,
    required this.gameFormat,
    required this.status,
    this.deadlineAt,
    required this.createdAt,
    required this.isFull,
    required this.applications,
  });

  factory RecruitmentDetailModel.fromJson(Map<String, dynamic> json) {
    final appsList = json['applications'] as List<dynamic>? ?? [];
    return RecruitmentDetailModel(
      id: json['id']?.toString() ?? '',
      authorId: (json['authorId'] as num?)?.toInt() ?? 0,
      authorNickname: (json['authorNickname'] as String?) ?? '',
      startAt: RecruitmentListModel._parseDateTime(json['startAt']),
      endAt: RecruitmentListModel._parseDateTime(json['endAt']),
      locationId: json['locationId']?.toString() ?? '',
      locationName: (json['locationName'] as String?) ?? '',
      baseMembersCount: (json['baseMembersCount'] as num?)?.toInt() ?? 0,
      neededMembers: (json['neededMembers'] as num?)?.toInt() ?? 0,
      acceptedCount: (json['acceptedCount'] as num?)?.toInt() ?? 0,
      gameFormat: (json['gameFormat'] as String?) ?? 'FLEXIBLE',
      status: (json['status'] as String?) ?? 'OPEN',
      deadlineAt: json['deadlineAt'] != null
          ? RecruitmentListModel._parseDateTime(json['deadlineAt'])
          : null,
      createdAt: RecruitmentListModel._parseDateTime(json['createdAt']),
      isFull: (json['isFull'] as bool?) ?? (json['full'] as bool?) ?? false,
      applications: appsList
          .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get currentCount => baseMembersCount + acceptedCount;
  int get totalNeeded => baseMembersCount + neededMembers;
  double get progressRatio =>
      neededMembers > 0 ? (acceptedCount / neededMembers).clamp(0.0, 1.0) : 0.0;

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
        return gameFormat;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'OPEN':
        return '모집중';
      case 'CONFIRMED':
        return '확정';
      case 'CLOSED':
        return '마감';
      case 'CANCELLED':
        return '취소';
      default:
        return status;
    }
  }

  bool get isOpen => status == 'OPEN';
}

class ApplicationModel {
  final String applicationId;
  final int applicantId;
  final String applicantNickname;
  final String? applicantPosition;
  final int applicantExp;
  final int applicantNoShowCount;
  final int applicantParticipationCount;
  final String status;
  final String? message;
  final DateTime createdAt;

  ApplicationModel({
    required this.applicationId,
    required this.applicantId,
    required this.applicantNickname,
    this.applicantPosition,
    required this.applicantExp,
    required this.applicantNoShowCount,
    required this.applicantParticipationCount,
    required this.status,
    this.message,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['applicationId']?.toString() ?? '',
      applicantId: (json['applicantId'] as num?)?.toInt() ?? 0,
      applicantNickname: (json['applicantNickname'] as String?) ?? '',
      applicantPosition: json['applicantPosition'] as String?,
      applicantExp: (json['applicantExp'] as num?)?.toInt() ?? 0,
      applicantNoShowCount: (json['applicantNoShowCount'] as num?)?.toInt() ?? 0,
      applicantParticipationCount:
          (json['applicantParticipationCount'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'PENDING',
      message: json['message'] as String?,
      createdAt: RecruitmentListModel._parseDateTime(json['createdAt']),
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';

  String get positionDisplay {
    switch (applicantPosition) {
      case 'GUARD':
        return '가드';
      case 'FORWARD':
        return '포워드';
      case 'CENTER':
        return '센터';
      default:
        return applicantPosition ?? '미설정';
    }
  }
}
