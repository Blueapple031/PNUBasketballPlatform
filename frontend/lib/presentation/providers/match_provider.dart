import 'package:flutter/foundation.dart';
import '../../core/utils/error_message_util.dart';
import '../../data/models/match_model.dart';
import '../../data/repositories/match_repository.dart';

class MatchProvider with ChangeNotifier {
  final MatchRepository repository;

  List<MatchModel> _matches = [];
  MatchModel? _selectedMatch;
  ReviewFormModel? _reviewForm;
  bool _isLoading = false;
  String? _errorMessage;

  MatchProvider({MatchRepository? repository})
      : repository = repository ?? MatchRepository();

  List<MatchModel> get matches => _matches;
  MatchModel? get selectedMatch => _selectedMatch;
  ReviewFormModel? get reviewForm => _reviewForm;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MatchModel> get pendingReviewMatches =>
      _matches.where((m) => m.isEnded).toList();

  Future<void> loadMyMatches() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _matches = await repository.getMyMatches();
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMatch(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedMatch = await repository.getMatch(id);
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeMatch(String id) async {
    try {
      _errorMessage = null;
      await repository.complete(id);
      await loadMyMatches();
      return true;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<ReviewFormModel?> loadReviewForm(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _reviewForm = await repository.getReviewForm(id);
      return _reviewForm;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview(
    String matchId, {
    required List<int> thumbsUpUserIds,
    required List<int> noShowUserIds,
  }) async {
    try {
      _errorMessage = null;
      await repository.submitReview(
        matchId,
        thumbsUpUserIds: thumbsUpUserIds,
        noShowUserIds: noShowUserIds,
      );
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
