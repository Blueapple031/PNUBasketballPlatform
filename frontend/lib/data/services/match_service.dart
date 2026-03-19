import '../models/api_response_model.dart';
import '../models/match_model.dart';
import 'api_service.dart';
import '../../core/constants/api_endpoints.dart';

class MatchService {
  final ApiService apiService;

  MatchService({ApiService? apiService})
      : apiService = apiService ?? ApiService();

  Future<ApiResponseModel<List<MatchModel>>> getMyMatches({
    required String accessToken,
  }) async {
    return await apiService.get<List<MatchModel>>(
      ApiEndpoints.matches,
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => (json as List)
          .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponseModel<MatchModel>> getMatch({
    required String accessToken,
    required String id,
  }) async {
    return await apiService.get<MatchModel>(
      ApiEndpoints.match(id),
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => MatchModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<void>> complete({
    required String accessToken,
    required String id,
  }) async {
    return await apiService.post<void>(
      ApiEndpoints.matchComplete(id),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<ApiResponseModel<ReviewFormModel>> getReviewForm({
    required String accessToken,
    required String id,
  }) async {
    return await apiService.get<ReviewFormModel>(
      ApiEndpoints.matchReviewForm(id),
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) =>
          ReviewFormModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<void>> submitReview({
    required String accessToken,
    required String id,
    required List<int> thumbsUpUserIds,
    required List<int> noShowUserIds,
  }) async {
    return await apiService.post<void>(
      ApiEndpoints.matchReview(id),
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'thumbsUpUserIds': thumbsUpUserIds,
        'noShowUserIds': noShowUserIds,
      },
    );
  }
}
