import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../models/club_model.dart';
import '../models/api_response_model.dart';
import 'api_service.dart';
import '../../core/constants/api_endpoints.dart';

class AuthService {
  final ApiService apiService;

  AuthService({ApiService? apiService})
      : apiService = apiService ?? ApiService();

  Future<ApiResponseModel<AuthResponseModel>> signup({
    required String email,
    required String password,
    required String realName,
    String? phoneNumber,
    required String dateOfBirth,
    required bool isPnuStudent,
    String? department,
    String? studentId,
  }) async {
    return await apiService.post<AuthResponseModel>(
      ApiEndpoints.signup,
      body: {
        'email': email,
        'password': password,
        'realName': realName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth,
        'isPnuStudent': isPnuStudent,
        if (department != null) 'department': department,
        if (studentId != null) 'studentId': studentId,
      },
      fromJson: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    return await apiService.post<AuthResponseModel>(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
      },
      fromJson: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<AuthResponseModel>> kakaoLogin({
    required String accessToken,
  }) async {
    return await apiService.post<AuthResponseModel>(
      ApiEndpoints.kakaoLogin,
      body: {
        'accessToken': accessToken,
      },
      fromJson: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<AuthResponseModel>> googleLogin({
    required String idToken,
  }) async {
    return await apiService.post<AuthResponseModel>(
      ApiEndpoints.googleLogin,
      body: {
        'idToken': idToken,
      },
      fromJson: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<AuthResponseModel>> refreshToken({
    required String refreshToken,
  }) async {
    return await apiService.post<AuthResponseModel>(
      ApiEndpoints.refreshToken,
      body: {
        'refreshToken': refreshToken,
      },
      fromJson: (json) => AuthResponseModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<void>> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    return await apiService.post<void>(
      ApiEndpoints.logout,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      body: {
        'refreshToken': refreshToken,
      },
    );
  }

  Future<ApiResponseModel<UserModel>> getCurrentUser({
    required String accessToken,
  }) async {
    return await apiService.get<UserModel>(
      ApiEndpoints.me,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<Map<String, dynamic>>> checkEmail({
    required String email,
  }) async {
    return await apiService.get<Map<String, dynamic>>(
      '${ApiEndpoints.checkEmail}?email=$email',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponseModel<UserModel>> completeProfile({
    required String accessToken,
    required String? realName,
    required String dateOfBirth,
    required bool isPnuStudent,
    String? department,
    String? studentId,
  }) async {
    return await apiService.post<UserModel>(
      ApiEndpoints.completeProfile,
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        if (realName != null) 'realName': realName,
        'dateOfBirth': dateOfBirth,
        'isPnuStudent': isPnuStudent,
        if (department != null) 'department': department,
        if (studentId != null) 'studentId': studentId,
      },
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<ClubSelectionStatusModel>> getClubSelectionStatus({
    required String accessToken,
  }) async {
    return await apiService.get<ClubSelectionStatusModel>(
      ApiEndpoints.clubSelectionStatus,
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => ClubSelectionStatusModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponseModel<List<ClubModel>>> getClubs({
    required String accessToken,
  }) async {
    return await apiService.get<List<ClubModel>>(
      ApiEndpoints.clubs,
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (json) => (json as List)
          .map((e) => ClubModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponseModel<ClubSelectResultModel>> selectClub({
    required String accessToken,
    required String clubId,
    String? role,
  }) async {
    return await apiService.post<ClubSelectResultModel>(
      ApiEndpoints.clubSelect,
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'clubId': clubId,
        if (role != null) 'role': role,
      },
      fromJson: (json) => ClubSelectResultModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

