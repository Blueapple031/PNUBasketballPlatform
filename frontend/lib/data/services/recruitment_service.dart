import '../models/api_response_model.dart';
import '../models/recruitment_model.dart';
import 'api_service.dart';
import '../../core/constants/api_endpoints.dart';

class RecruitmentService {
  final ApiService apiService;

  RecruitmentService({ApiService? apiService})
      : apiService = apiService ?? ApiService();

  Future<ApiResponseModel<Map<String, dynamic>>> getList({
    required String accessToken,
    String? status,
    String? locationId,
    String? gameFormat,
    String? startFrom,
    String? startTo,
    int page = 0,
    int size = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (status != null) params['status'] = status;
    if (locationId != null) params['locationId'] = locationId;
    if (gameFormat != null) params['gameFormat'] = gameFormat;
    if (startFrom != null) params['startFrom'] = startFrom;
    if (startTo != null) params['startTo'] = startTo;

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');

    return await apiService.get<Map<String, dynamic>>(
      '${ApiEndpoints.recruitments}?$query',
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel<RecruitmentDetailModel>> getDetail({
    required String accessToken,
    required String id,
  }) async {
    return await apiService.get<RecruitmentDetailModel>(
      ApiEndpoints.recruitment(id),
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) =>
          RecruitmentDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<RecruitmentDetailModel>> create({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    return await apiService.post<RecruitmentDetailModel>(
      ApiEndpoints.recruitments,
      headers: {'Authorization': 'Bearer $accessToken'},
      body: body,
      fromJson: (json) =>
          RecruitmentDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<void>> apply({
    required String accessToken,
    required String id,
    String? message,
  }) async {
    return await apiService.post<void>(
      ApiEndpoints.recruitmentApply(id),
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {if (message != null) 'message': message},
    );
  }

  Future<ApiResponseModel<void>> acceptApplication({
    required String accessToken,
    required String recruitmentId,
    required String applicationId,
  }) async {
    return await apiService.post<void>(
      ApiEndpoints.recruitmentApplicationAccept(recruitmentId, applicationId),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<ApiResponseModel<void>> rejectApplication({
    required String accessToken,
    required String recruitmentId,
    required String applicationId,
  }) async {
    return await apiService.post<void>(
      ApiEndpoints.recruitmentApplicationReject(recruitmentId, applicationId),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<ApiResponseModel<RecruitmentDetailModel>> confirm({
    required String accessToken,
    required String id,
  }) async {
    return await apiService.post<RecruitmentDetailModel>(
      ApiEndpoints.recruitmentConfirm(id),
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) =>
          RecruitmentDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<void>> cancel({
    required String accessToken,
    required String id,
  }) async {
    return await apiService.post<void>(
      ApiEndpoints.recruitmentCancel(id),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}
