import 'package:flutter/foundation.dart';
import '../../core/utils/error_message_util.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/schedule_repository.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleRepository scheduleRepository;

  ScheduleProvider({ScheduleRepository? scheduleRepository})
      : scheduleRepository = scheduleRepository ?? ScheduleRepository();

  List<ScheduleModel> _schedules = [];
  List<ScheduleLocationModel> _locations = [];
  String? _selectedLocationId;
  bool _isLoading = false;
  String? _errorMessage;

  /// 3주치 데이터의 시작일 (이번 주 월요일)
  DateTime _weekBase = _getStartOfWeek(DateTime.now());

  static DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  List<ScheduleModel> get schedules => _schedules;
  List<ScheduleLocationModel> get locations => _locations;
  String? get selectedLocationId => _selectedLocationId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 3주치 데이터의 시작일
  DateTime get weekBase => _weekBase;

  /// index번째 주의 시작일 (0: 이번 주, 1: 다음 주, 2: 다다음 주)
  DateTime getWeekStart(int index) {
    return _weekBase.add(Duration(days: index * 7));
  }

  Future<void> loadSchedules({bool refresh = true}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    if (refresh) {
      _weekBase = _getStartOfWeek(DateTime.now());
    }
    notifyListeners();

    try {
      final startDate = _weekBase;
      final endDate = _weekBase.add(const Duration(days: 21));

      if (_selectedLocationId == null) {
        final initial = await scheduleRepository.getSchedules(
          startDate: startDate,
          endDate: endDate,
        );
        _locations = initial.locations;
        if (_locations.isNotEmpty) {
          _selectedLocationId = _locations.first.id;
        }
      }

      final result = await scheduleRepository.getSchedules(
        startDate: startDate,
        endDate: endDate,
        locationId: _selectedLocationId,
      );

      _schedules = result.schedules;
      _locations = result.locations;
    } catch (e) {
      _errorMessage = toUserFriendlyMessage(e);
      _schedules = [];
      _locations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedLocationId(String? locationId) {
    _selectedLocationId = locationId;
    notifyListeners();
  }

  List<ScheduleModel> getSchedulesForDate(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _schedules.where((s) {
      final sStr =
          '${s.scheduleDate.year}-${s.scheduleDate.month.toString().padLeft(2, '0')}-${s.scheduleDate.day.toString().padLeft(2, '0')}';
      return sStr == dateStr;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Map<String, List<ScheduleModel>> getSchedulesGroupedByLocation(
      DateTime date) {
    final list = getSchedulesForDate(date);
    final map = <String, List<ScheduleModel>>{};
    for (final s in list) {
      map.putIfAbsent(s.locationName, () => []).add(s);
    }
    for (final loc in _locations) {
      map.putIfAbsent(loc.name, () => []);
    }
    return map;
  }
}
