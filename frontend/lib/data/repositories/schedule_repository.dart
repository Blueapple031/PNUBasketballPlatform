import '../models/schedule_model.dart';
import '../services/schedule_service.dart';
import 'auth_repository.dart';

class ScheduleRepository {
  final ScheduleService scheduleService;
  final AuthRepository authRepository;

  ScheduleRepository({
    ScheduleService? scheduleService,
    AuthRepository? authRepository,
  })  : scheduleService = scheduleService ?? ScheduleService(),
        authRepository = authRepository ?? AuthRepository();

  Future<String?> _getAccessToken() async {
    var token = await authRepository.getAccessToken();
    if (token != null && token.isNotEmpty) return token;
    token = await authRepository.refreshAccessToken();
    return token;
  }

  Future<ScheduleListResult> getSchedules({
    DateTime? startDate,
    DateTime? endDate,
    String? location,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    return scheduleService.getSchedules(
      accessToken: token,
      startDate: startDate,
      endDate: endDate,
      location: location,
    );
  }
}
