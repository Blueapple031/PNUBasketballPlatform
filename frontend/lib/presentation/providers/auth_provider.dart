import 'package:flutter/foundation.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/user_model.dart';
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
    try {
      _isLoading = true;
      notifyListeners();

      if (await authRepository.isLoggedIn()) {
        _currentUser = await authRepository.getCurrentUser();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String nickname,
    String? phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await authRepository.signup(
        email: email,
        password: password,
        nickname: nickname,
        phoneNumber: phoneNumber,
      );

      _currentUser = UserModel(
        userId: authResponse.user.userId,
        email: authResponse.user.email,
        nickname: authResponse.user.nickname,
        profileImageUrl: authResponse.user.profileImageUrl,
        loginType: authResponse.user.loginType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
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
        nickname: authResponse.user.nickname,
        profileImageUrl: authResponse.user.profileImageUrl,
        loginType: authResponse.user.loginType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> googleLogin() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await authRepository.googleLogin();

      _currentUser = UserModel(
        userId: authResponse.user.userId,
        email: authResponse.user.email,
        nickname: authResponse.user.nickname,
        profileImageUrl: authResponse.user.profileImageUrl,
        loginType: authResponse.user.loginType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
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

  Future<bool> checkNicknameAvailability(String nickname) async {
    try {
      return await authRepository.checkNicknameAvailability(nickname);
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

