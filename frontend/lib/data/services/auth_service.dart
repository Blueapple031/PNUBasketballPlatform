import '../models/auth_response_model.dart';
import '../models/user_model.dart';
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
    required String nickname,
    String? phoneNumber,
  }) async {
    return await apiService.post<AuthResponseModel>(
      ApiEndpoints.signup,
      body: {
        'email': email,
        'password': password,
        'nickname': nickname,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
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

  Future<ApiResponseModel<Map<String, dynamic>>> checkNickname({
    required String nickname,
  }) async {
    return await apiService.get<Map<String, dynamic>>(
      '${ApiEndpoints.checkNickname}?nickname=$nickname',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}

