import '../models/club_match_model.dart';
import '../services/club_match_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClubMatchRepository {
  final ClubMatchService service;
  final FlutterSecureStorage secureStorage;

  ClubMatchRepository({
    ClubMatchService? service,
    FlutterSecureStorage? secureStorage,
  })  : service = service ?? ClubMatchService(),
        secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<String> _getToken() async {
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) throw Exception('로그인이 필요합니다.');
    return token;
  }

  Future<List<ClubMatchRequestModel>> getRequests() async {
    final token = await _getToken();
    final response = await service.getRequests(accessToken: token);
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '친선전 목록 조회 실패');
  }

  Future<ClubMatchRequestModel> getRequest(String id) async {
    final token = await _getToken();
    final response = await service.getRequest(accessToken: token, id: id);
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '친선전 상세 조회 실패');
  }

  Future<ClubMatchRequestModel> create({
    required String startAt,
    required String endAt,
    required String locationId,
    String? awayClubId,
  }) async {
    final token = await _getToken();
    final response = await service.create(
      accessToken: token,
      body: {
        'startAt': startAt,
        'endAt': endAt,
        'locationId': locationId,
        if (awayClubId != null) 'awayClubId': awayClubId,
      },
    );
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '친선전 신청 실패');
  }

  Future<void> attend(String id) async {
    final token = await _getToken();
    final response = await service.attend(accessToken: token, id: id);
    if (!response.success) {
      throw Exception(response.error?['message'] ?? '참가 의사 등록 실패');
    }
  }

  Future<ClubMatchRequestModel> matchOpponent(String id, String awayClubId) async {
    final token = await _getToken();
    final response = await service.matchOpponent(
      accessToken: token,
      id: id,
      awayClubId: awayClubId,
    );
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '상대 지정 실패');
  }

  Future<ClubMatchResultModel> submitResult(
    String id, {
    required int homeScore,
    required int awayScore,
  }) async {
    final token = await _getToken();
    final response = await service.submitResult(
      accessToken: token,
      id: id,
      homeScore: homeScore,
      awayScore: awayScore,
    );
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '결과 입력 실패');
  }

  Future<void> approveResult(String id) async {
    final token = await _getToken();
    final response = await service.approveResult(accessToken: token, id: id);
    if (!response.success) {
      throw Exception(response.error?['message'] ?? '결과 승인 실패');
    }
  }
}
