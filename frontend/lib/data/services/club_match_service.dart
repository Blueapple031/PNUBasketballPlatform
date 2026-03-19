import '../models/api_response_model.dart';
import '../models/club_match_model.dart';
import 'api_service.dart';
import '../../core/constants/api_endpoints.dart';

class ClubMatchService {
  final ApiService apiService;

  ClubMatchService({ApiService? apiService})
      : apiService = apiService ?? ApiService();

  Future<ApiResponseModel<List<ClubMatchRequestModel>>> getRequests({
    required String accessToken,
  }) async {
    return await apiService.get<List<ClubMatchRequestModel>>(
      ApiEndpoints.clubMatchRequests,
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => (json as List)
          .map((e) =>
              ClubMatchRequestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponseModel<ClubMatchRequestModel>> getRequest({
    required String accessToken,
    required String id,
  }) async {
    return await apiService.get<ClubMatchRequestModel>(
      ApiEndpoints.clubMatchRequest(id),
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) =>
          ClubMatchRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<ClubMatchRequestModel>> create({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    return await apiService.post<ClubMatchRequestModel>(
      ApiEndpoints.clubMatchRequests,
      headers: {'Authorization': 'Bearer $accessToken'},
      body: body,
      fromJson: (json) =>
          ClubMatchRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<void>> attend({
    required String accessToken,
    required String id,
  }) async {
    return await apiService.post<void>(
      ApiEndpoints.clubMatchAttend(id),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<ApiResponseModel<ClubMatchRequestModel>> matchOpponent({
    required String accessToken,
    required String id,
    required String awayClubId,
  }) async {
    return await apiService.post<ClubMatchRequestModel>(
      ApiEndpoints.clubMatchMatch(id),
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'awayClubId': awayClubId},
      fromJson: (json) =>
          ClubMatchRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<ClubMatchResultModel>> submitResult({
    required String accessToken,
    required String id,
    required int homeScore,
    required int awayScore,
  }) async {
    return await apiService.post<ClubMatchResultModel>(
      ApiEndpoints.clubMatchResult(id),
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {'homeScore': homeScore, 'awayScore': awayScore},
      fromJson: (json) =>
          ClubMatchResultModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<void>> approveResult({
    required String accessToken,
    required String id,
  }) async {
    return await apiService.post<void>(
      ApiEndpoints.clubMatchApproveResult(id),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}
