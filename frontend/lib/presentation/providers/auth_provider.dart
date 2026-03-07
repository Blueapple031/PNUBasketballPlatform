import 'package:flutter/foundation.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/club_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthRepository? authRepository})
      : authRepository = authRepository ?? AuthRepository();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> initialize() async {
    if (!await authRepository.isLoggedIn()) {
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
      return false;
    }

    return fetchCurrentUser();
  }

  Future<bool> fetchCurrentUser() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await authRepository.getCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResponseModel?> signup({
    required String email,
    required String password,
    required String realName,
    String? phoneNumber,
    required String dateOfBirth,
    required bool isPnuStudent,
    String? department,
    String? studentId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await authRepository.signup(
        email: email,
        password: password,
        realName: realName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        isPnuStudent: isPnuStudent,
        department: department,
        studentId: studentId,
      );

      _currentUser = UserModel(
        userId: authResponse.user.userId,
        email: authResponse.user.email,
        realName: authResponse.user.realName,
        profileImageUrl: authResponse.user.profileImageUrl,
        loginType: authResponse.user.loginType,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return authResponse;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<AuthResponseModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await authRepository.login(
        email: email,
        password: password,
      );

      _currentUser = UserModel(
        userId: authResponse.user.userId,
        email: authResponse.user.email,
        realName: authResponse.user.realName,
        profileImageUrl: authResponse.user.profileImageUrl,
        loginType: authResponse.user.loginType,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return authResponse;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<AuthResponseModel?> kakaoLogin() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await authRepository.kakaoLogin();

      _currentUser = UserModel(
        userId: authResponse.user.userId,
        email: authResponse.user.email,
        realName: authResponse.user.realName,
        profileImageUrl: authResponse.user.profileImageUrl,
        loginType: authResponse.user.loginType,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return authResponse;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<AuthResponseModel?> googleLogin() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await authRepository.googleLogin();

      _currentUser = UserModel(
        userId: authResponse.user.userId,
        email: authResponse.user.email,
        realName: authResponse.user.realName,
        profileImageUrl: authResponse.user.profileImageUrl,
        loginType: authResponse.user.loginType,
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return authResponse;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await authRepository.logout();
      _currentUser = null;
      _errorMessage = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkEmailAvailability(String email) async {
    try {
      return await authRepository.checkEmailAvailability(email);
    } catch (e) {
      return false;
    }
  }

  Future<ClubSelectionStatusModel?> getClubSelectionStatus() async {
    try {
      return await authRepository.getClubSelectionStatus();
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> completeProfile({
    required String? realName,
    required String dateOfBirth,
    required bool isPnuStudent,
    String? department,
    String? studentId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await authRepository.completeProfile(
        realName: realName,
        dateOfBirth: dateOfBirth,
        isPnuStudent: isPnuStudent,
        department: department,
        studentId: studentId,
      );

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<List<ClubModel>?> getClubs() async {
    try {
      return await authRepository.getClubs();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// 내 동아리 조회. 동아리 미가입 시 null
  Future<ClubModel?> getMyClub() async {
    try {
      _errorMessage = null;
      final club = await authRepository.getMyClub();
      notifyListeners();
      return club;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  Future<ClubSelectResultModel?> selectClub(String clubId, {String? role}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await authRepository.selectClub(clubId, role: role);

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  String _extractErrorMessage(Object e) {
    final str = e.toString();
    if (str.startsWith('Exception: ')) {
      return str.substring('Exception: '.length);
    }
    return str;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

