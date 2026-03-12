class ScheduleModel {
  final String id;
  final String locationId;
  final String locationName;
  final DateTime scheduleDate;
  final String startTime;
  final String endTime;
  final String status;
  final String scheduleType; // REGULAR, TRAINING
  final String? title;
  final String? description;
  final String? matchId;

  ScheduleModel({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.scheduleDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.scheduleType = 'REGULAR',
    this.title,
    this.description,
    this.matchId,
  });

  bool get isTraining => scheduleType == 'TRAINING';

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final dateStr = json['scheduleDate'] as String?;
    final startRaw = json['startTime'];
    final endRaw = json['endTime'];

    String startStr = '00:00';
    if (startRaw != null) {
      if (startRaw is String) {
        startStr = startRaw.length >= 5 ? startRaw.substring(0, 5) : startRaw;
      } else if (startRaw is List && startRaw.length >= 2) {
        startStr =
            '${(startRaw[0] as num).toInt().toString().padLeft(2, '0')}:${(startRaw[1] as num).toInt().toString().padLeft(2, '0')}';
      }
    }

    String endStr = '00:00';
    if (endRaw != null) {
      if (endRaw is String) {
        endStr = endRaw.length >= 5 ? endRaw.substring(0, 5) : endRaw;
      } else if (endRaw is List && endRaw.length >= 2) {
        endStr =
            '${(endRaw[0] as num).toInt().toString().padLeft(2, '0')}:${(endRaw[1] as num).toInt().toString().padLeft(2, '0')}';
      }
    }

    return ScheduleModel(
      id: json['id']?.toString() ?? '',
      locationId: json['locationId']?.toString() ?? '',
      locationName: json['locationName'] as String? ?? '',
      scheduleDate: dateStr != null ? DateTime.parse(dateStr) : DateTime.now(),
      startTime: startStr,
      endTime: endStr,
      status: json['status'] as String? ?? 'SCHEDULED',
      scheduleType: json['scheduleType'] as String? ?? 'REGULAR',
      title: json['title'] as String?,
      description: json['description'] as String?,
      matchId: json['matchId']?.toString(),
    );
  }

  bool get isAvailable => status == 'AVAILABLE';
  bool get isScheduled => status == 'SCHEDULED';
  bool get isCancelled => status == 'CANCELLED';

  String get statusDisplayText {
    switch (status) {
      case 'AVAILABLE':
        return '비어있음';
      case 'SCHEDULED':
        return '사용중';
      case 'CANCELLED':
        return '사용 예정';
      default:
        return status;
    }
  }
}

class ScheduleLocationModel {
  final String id;
  final String name;

  ScheduleLocationModel({required this.id, required this.name});

  factory ScheduleLocationModel.fromJson(Map<String, dynamic> json) {
    return ScheduleLocationModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['displayName'] as String? ?? '',
    );
  }
}
