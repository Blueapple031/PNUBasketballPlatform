import '../models/match_model.dart';
import '../services/match_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MatchRepository {
  final MatchService service;
  final FlutterSecureStorage secureStorage;

  MatchRepository({
    MatchService? service,
    FlutterSecureStorage? secureStorage,
  })  : service = service ?? MatchService(),
        secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<String> _getToken() async {
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) throw Exception('로그인이 필요합니다.');
    return token;
  }

  Future<List<MatchModel>> getMyMatches() async {
    final token = await _getToken();
    final response = await service.getMyMatches(accessToken: token);
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '경기 목록 조회 실패');
  }

  Future<MatchModel> getMatch(String id) async {
    final token = await _getToken();
    final response = await service.getMatch(accessToken: token, id: id);
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '경기 조회 실패');
  }

  Future<void> complete(String id) async {
    final token = await _getToken();
    final response = await service.complete(accessToken: token, id: id);
    if (!response.success) {
      throw Exception(response.error?['message'] ?? '경기 완료 처리 실패');
    }
  }

  Future<ReviewFormModel> getReviewForm(String id) async {
    final token = await _getToken();
    final response = await service.getReviewForm(accessToken: token, id: id);
    if (response.success && response.data != null) return response.data!;
    throw Exception(response.error?['message'] ?? '리뷰 폼 조회 실패');
  }

  Future<void> submitReview(
    String id, {
    required List<int> thumbsUpUserIds,
    required List<int> noShowUserIds,
  }) async {
    final token = await _getToken();
    final response = await service.submitReview(
      accessToken: token,
      id: id,
      thumbsUpUserIds: thumbsUpUserIds,
      noShowUserIds: noShowUserIds,
    );
    if (!response.success) {
      throw Exception(response.error?['message'] ?? '리뷰 제출 실패');
    }
  }
}
