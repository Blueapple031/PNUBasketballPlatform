import 'package:flutter/foundation.dart';
import '../../core/utils/error_message_util.dart';
import '../../data/models/club_match_model.dart';
import '../../data/repositories/club_match_repository.dart';

class ClubMatchProvider with ChangeNotifier {
  final ClubMatchRepository repository;

  List<ClubMatchRequestModel> _requests = [];
  ClubMatchRequestModel? _selectedRequest;
  bool _isLoading = false;
  String? _errorMessage;

  ClubMatchProvider({ClubMatchRepository? repository})
      : repository = repository ?? ClubMatchRepository();

  List<ClubMatchRequestModel> get requests => _requests;
  ClubMatchRequestModel? get selectedRequest => _selectedRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRequests() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _requests = await repository.getRequests();
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedRequest = await repository.getRequest(id);
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ClubMatchRequestModel?> create({
    required String startAt,
    required String endAt,
    required String locationId,
    String? awayClubId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await repository.create(
        startAt: startAt,
        endAt: endAt,
        locationId: locationId,
        awayClubId: awayClubId,
      );
      await loadRequests();
      return result;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> attend(String id) async {
    try {
      _errorMessage = null;
      await repository.attend(id);
      await loadDetail(id);
      return true;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> matchOpponent(String id, String awayClubId) async {
    try {
      _errorMessage = null;
      await repository.matchOpponent(id, awayClubId);
      await loadDetail(id);
      return true;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<ClubMatchResultModel?> submitResult(
    String id, {
    required int homeScore,
    required int awayScore,
  }) async {
    try {
      _errorMessage = null;
      final result = await repository.submitResult(
        id,
        homeScore: homeScore,
        awayScore: awayScore,
      );
      await loadDetail(id);
      return result;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> approveResult(String id) async {
    try {
      _errorMessage = null;
      await repository.approveResult(id);
      await loadDetail(id);
      return true;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
