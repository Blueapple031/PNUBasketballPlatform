import '../models/recruitment_model.dart';
import '../services/recruitment_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecruitmentRepository {
  final RecruitmentService service;
  final FlutterSecureStorage secureStorage;

  RecruitmentRepository({
    RecruitmentService? service,
    FlutterSecureStorage? secureStorage,
  })  : service = service ?? RecruitmentService(),
        secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<String> _getToken() async {
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) throw Exception('로그인이 필요합니다.');
    return token;
  }

  Future<List<RecruitmentListModel>> getList({
    String? status,
    String? locationId,
    String? gameFormat,
    int page = 0,
    int size = 20,
  }) async {
    final token = await _getToken();
    final response = await service.getList(
      accessToken: token,
      status: status,
      locationId: locationId,
      gameFormat: gameFormat,
      page: page,
      size: size,
    );

    if (response.success && response.data != null) {
      final content = response.data!['content'] as List<dynamic>? ?? [];
      return content
          .map((e) => RecruitmentListModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response.error?['message'] ?? '모집글 목록 조회 실패');
  }

  Future<RecruitmentDetailModel> getDetail(String id) async {
    final token = await _getToken();
    final response = await service.getDetail(accessToken: token, id: id);
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '모집글 상세 조회 실패');
  }

  Future<RecruitmentDetailModel> create({
    required String startAt,
    required String endAt,
    required String locationId,
    required int baseMembersCount,
    required int neededMembers,
    required String gameFormat,
    String? deadlineAt,
  }) async {
    final token = await _getToken();
    final response = await service.create(
      accessToken: token,
      body: {
        'startAt': startAt,
        'endAt': endAt,
        'locationId': locationId,
        'baseMembersCount': baseMembersCount,
        'neededMembers': neededMembers,
        'gameFormat': gameFormat,
        if (deadlineAt != null) 'deadlineAt': deadlineAt,
      },
    );
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '모집글 생성 실패');
  }

  Future<void> apply(String id, {String? message}) async {
    final token = await _getToken();
    final response = await service.apply(
      accessToken: token,
      id: id,
      message: message,
    );
    if (!response.success) {
      throw Exception(response.error?['message'] ?? '신청 실패');
    }
  }

  Future<void> acceptApplication(String recruitmentId, String applicationId) async {
    final token = await _getToken();
    final response = await service.acceptApplication(
      accessToken: token,
      recruitmentId: recruitmentId,
      applicationId: applicationId,
    );
    if (!response.success) {
      throw Exception(response.error?['message'] ?? '수락 실패');
    }
  }

  Future<void> rejectApplication(String recruitmentId, String applicationId) async {
    final token = await _getToken();
    final response = await service.rejectApplication(
      accessToken: token,
      recruitmentId: recruitmentId,
      applicationId: applicationId,
    );
    if (!response.success) {
      throw Exception(response.error?['message'] ?? '거절 실패');
    }
  }

  Future<RecruitmentDetailModel> confirm(String id) async {
    final token = await _getToken();
    final response = await service.confirm(accessToken: token, id: id);
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '확정 실패');
  }

  Future<void> cancel(String id) async {
    final token = await _getToken();
    final response = await service.cancel(accessToken: token, id: id);
    if (!response.success) {
      throw Exception(response.error?['message'] ?? '취소 실패');
    }
  }
}
