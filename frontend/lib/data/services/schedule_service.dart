import '../models/schedule_model.dart';
import 'api_service.dart';
import '../../core/constants/api_endpoints.dart';

class ScheduleService {
  final ApiService apiService;

  ScheduleService({ApiService? apiService})
      : apiService = apiService ?? ApiService();

  Map<String, String> _authHeaders(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
      };

  Future<ScheduleListResult> getSchedules({
    required String accessToken,
    DateTime? startDate,
    DateTime? endDate,
    String? locationId,
  }) async {
    final params = <String, String>{};
    if (startDate != null) {
      params['startDate'] =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) {
      params['endDate'] =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    }
    if (locationId != null && locationId.isNotEmpty) {
      params['locationIds'] = locationId;
    }

    final query = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';

    final response = await apiService.get<Map<String, dynamic>>(
      '${ApiEndpoints.schedules}$query',
      headers: _authHeaders(accessToken),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final schedulesList = data['schedules'] as List<dynamic>? ?? [];
      final locationsList = data['locations'] as List<dynamic>? ?? [];

      return ScheduleListResult(
        schedules: schedulesList
            .map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        locations: locationsList
            .map((e) =>
                ScheduleLocationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw Exception(
        response.error?['message'] ?? '일정 목록 조회 실패');
  }
}

class ScheduleListResult {
  final List<ScheduleModel> schedules;
  final List<ScheduleLocationModel> locations;

  ScheduleListResult({
    required this.schedules,
    required this.locations,
  });
}
