class ClubMatchRequestModel {
  final String id;
  final String homeClubId;
  final String homeClubName;
  final String? awayClubId;
  final String? awayClubName;
  final DateTime startAt;
  final DateTime endAt;
  final String locationName;
  final String status;
  final int homeAttendanceCount;
  final int awayAttendanceCount;
  final DateTime createdAt;

  ClubMatchRequestModel({
    required this.id,
    required this.homeClubId,
    required this.homeClubName,
    this.awayClubId,
    this.awayClubName,
    required this.startAt,
    required this.endAt,
    required this.locationName,
    required this.status,
    required this.homeAttendanceCount,
    required this.awayAttendanceCount,
    required this.createdAt,
  });

  factory ClubMatchRequestModel.fromJson(Map<String, dynamic> json) {
    return ClubMatchRequestModel(
      id: json['id']?.toString() ?? '',
      homeClubId: json['homeClubId']?.toString() ?? '',
      homeClubName: json['homeClubName'] as String? ?? '',
      awayClubId: json['awayClubId']?.toString(),
      awayClubName: json['awayClubName'] as String?,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      locationName: json['locationName'] as String? ?? '',
      status: json['status'] as String? ?? 'GATHERING',
      homeAttendanceCount: (json['homeAttendanceCount'] as num?)?.toInt() ?? 0,
      awayAttendanceCount: (json['awayAttendanceCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'GATHERING':
        return '모집중';
      case 'READY':
        return '준비완료';
      case 'MATCHED':
        return '매칭완료';
      case 'CONFIRMED':
        return '확정';
      case 'DONE':
        return '완료';
      case 'CANCELLED':
        return '취소';
      default:
        return status;
    }
  }

  bool get hasAway => awayClubId != null && awayClubName != null;
  bool get isGathering => status == 'GATHERING';
  bool get isReady => status == 'READY';
  bool get isMatched => status == 'MATCHED';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isDone => status == 'DONE';
}

class ClubMatchResultModel {
  final String id;
  final String requestId;
  final String homeClubName;
  final String awayClubName;
  final int homeScore;
  final int awayScore;
  final bool homeApproved;
  final bool awayApproved;
  final bool adminApproved;

  ClubMatchResultModel({
    required this.id,
    required this.requestId,
    required this.homeClubName,
    required this.awayClubName,
    required this.homeScore,
    required this.awayScore,
    required this.homeApproved,
    required this.awayApproved,
    required this.adminApproved,
  });

  factory ClubMatchResultModel.fromJson(Map<String, dynamic> json) {
    return ClubMatchResultModel(
      id: json['id']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
      homeClubName: json['homeClubName'] as String? ?? '',
      awayClubName: json['awayClubName'] as String? ?? '',
      homeScore: (json['homeScore'] as num?)?.toInt() ?? 0,
      awayScore: (json['awayScore'] as num?)?.toInt() ?? 0,
      homeApproved: json['homeApproved'] as bool? ?? false,
      awayApproved: json['awayApproved'] as bool? ?? false,
      adminApproved: json['adminApproved'] as bool? ?? false,
    );
  }

  bool get isFullyApproved => homeApproved && awayApproved;
}
