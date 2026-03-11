import 'package:flutter/foundation.dart';
import '../../data/models/schedule_model.dart';
import '../../data/repositories/schedule_repository.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleRepository scheduleRepository;

  ScheduleProvider({ScheduleRepository? scheduleRepository})
      : scheduleRepository = scheduleRepository ?? ScheduleRepository();

  List<ScheduleModel> _schedules = [];
  List<ScheduleLocationModel> _locations = [];
  DateTime _selectedDate = DateTime.now();
  String? _selectedLocation;
  bool _isLoading = false;
  String? _errorMessage;

  List<ScheduleModel> get schedules => _schedules;
  List<ScheduleLocationModel> get locations => _locations;
  DateTime get selectedDate => _selectedDate;
  String? get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const List<ScheduleLocationModel> defaultLocations = [
    ScheduleLocationModel(id: 'NUNGNEUNG_BON', displayName: '넉넉한터 본관 방향'),
    ScheduleLocationModel(id: 'NUNGNEUNG_PARK', displayName: '넉넉한터 공원 방향'),
    ScheduleLocationModel(id: 'ONCHEON_BUSAN', displayName: '온천천 부산대역 농구장'),
  ];

  Future<void> loadSchedules({bool refresh = true}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);

      final result = await scheduleRepository.getSchedules(
        startDate: startDate,
        endDate: endDate,
        location: _selectedLocation,
      );

      _schedules = result.schedules;
      _locations = result.locations.isNotEmpty
          ? result.locations
          : defaultLocations;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _schedules = [];
      _locations = defaultLocations;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedLocation(String? location) {
    _selectedLocation = location;
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
      map.putIfAbsent(s.location, () => []).add(s);
    }
    for (final loc in defaultLocations) {
      map.putIfAbsent(loc.displayName, () => []);
    }
    return map;
  }
}
