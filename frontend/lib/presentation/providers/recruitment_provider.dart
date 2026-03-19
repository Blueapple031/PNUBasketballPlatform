import 'package:flutter/foundation.dart';
import '../../core/utils/error_message_util.dart';
import '../../data/models/recruitment_model.dart';

import '../../data/repositories/recruitment_repository.dart';

class RecruitmentProvider with ChangeNotifier {
  final RecruitmentRepository repository;

  List<RecruitmentListModel> _recruitments = [];
  RecruitmentDetailModel? _selectedRecruitment;
  bool _isLoading = false;
  String? _errorMessage;
  String? _filterStatus;
  String? _filterLocationId;
  String? _filterGameFormat;

  RecruitmentProvider({RecruitmentRepository? repository})
      : repository = repository ?? RecruitmentRepository();

  List<RecruitmentListModel> get recruitments => _recruitments;
  RecruitmentDetailModel? get selectedRecruitment => _selectedRecruitment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get filterStatus => _filterStatus;
  String? get filterLocationId => _filterLocationId;
  String? get filterGameFormat => _filterGameFormat;

  void setFilter({String? status, String? locationId, String? gameFormat}) {
    _filterStatus = status;
    _filterLocationId = locationId;
    _filterGameFormat = gameFormat;
    notifyListeners();
    loadRecruitments();
  }

  void clearFilters() {
    _filterStatus = null;
    _filterLocationId = null;
    _filterGameFormat = null;
    notifyListeners();
    loadRecruitments();
  }

  Future<void> loadRecruitments() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _recruitments = await repository.getList(
        status: _filterStatus,
        locationId: _filterLocationId,
        gameFormat: _filterGameFormat,
      );
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

      _selectedRecruitment = await repository.getDetail(id);
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RecruitmentDetailModel?> create({
    required String startAt,
    required String endAt,
    required String locationId,
    required int baseMembersCount,
    required int neededMembers,
    required String gameFormat,
    String? deadlineAt,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await repository.create(
        startAt: startAt,
        endAt: endAt,
        locationId: locationId,
        baseMembersCount: baseMembersCount,
        neededMembers: neededMembers,
        gameFormat: gameFormat,
        deadlineAt: deadlineAt,
      );
      await loadRecruitments();
      return result;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> apply(String id, {String? message}) async {
    try {
      _errorMessage = null;
      await repository.apply(id, message: message);
      await loadDetail(id);
      return true;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptApplication(String recruitmentId, String applicationId) async {
    try {
      _errorMessage = null;
      await repository.acceptApplication(recruitmentId, applicationId);
      await loadDetail(recruitmentId);
      return true;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectApplication(String recruitmentId, String applicationId) async {
    try {
      _errorMessage = null;
      await repository.rejectApplication(recruitmentId, applicationId);
      await loadDetail(recruitmentId);
      return true;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirm(String id) async {
    try {
      _errorMessage = null;
      await repository.confirm(id);
      await loadDetail(id);
      await loadRecruitments();
      return true;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancel(String id) async {
    try {
      _errorMessage = null;
      await repository.cancel(id);
      await loadRecruitments();
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
