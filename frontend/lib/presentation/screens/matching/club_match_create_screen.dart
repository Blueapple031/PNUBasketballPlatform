import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/club_match_provider.dart';
import '../../providers/schedule_provider.dart';

class ClubMatchCreateScreen extends StatefulWidget {
  const ClubMatchCreateScreen({super.key});

  @override
  State<ClubMatchCreateScreen> createState() => _ClubMatchCreateScreenState();
}

class _ClubMatchCreateScreenState extends State<ClubMatchCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startAt;
  DateTime? _endAt;
  String? _selectedLocationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final schedProv = context.read<ScheduleProvider>();
      if (schedProv.locations.isEmpty) {
        schedProv.loadSchedules();
      }
    });
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          initial ?? DateTime.now().add(const Duration(hours: 1))),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startAt == null || _endAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시작/종료 시각을 선택해주세요'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장소를 선택해주세요'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_startAt!.isAfter(_endAt!) || _startAt!.isAtSameMomentAs(_endAt!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종료 시각은 시작 시각 이후여야 합니다'), backgroundColor: Colors.red),
      );
      return;
    }

    final provider = context.read<ClubMatchProvider>();
    final fmt = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

    final result = await provider.create(
      startAt: fmt.format(_startAt!),
      endAt: fmt.format(_endAt!),
      locationId: _selectedLocationId!,
    );

    if (result != null && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친선전이 신청되었습니다')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '신청 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M/d(E) HH:mm', 'ko');

    return Scaffold(
      appBar: AppBar(title: const Text('친선전 신청')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.stadium,
                            size: 28, color: AppColors.activeBlue),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('홈 동아리',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.subText)),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                return FutureBuilder(
                                  future: auth.getMyClub(),
                                  builder: (context, snapshot) {
                                    final club = snapshot.data;
                                    return Text(
                                      club?.name ?? '동아리 정보 로딩중...',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '5:5 경기를 위해 동아리 멤버 5명 이상이 참가 의사를 등록해야 합니다.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                _buildDateTimePicker(
                  label: '시작 시각 *',
                  value: _startAt,
                  dateFormat: dateFormat,
                  onTap: () async {
                    final dt = await _pickDateTime(_startAt);
                    if (dt != null) setState(() => _startAt = dt);
                  },
                ),
                const SizedBox(height: 16),
                _buildDateTimePicker(
                  label: '종료 시각 *',
                  value: _endAt,
                  dateFormat: dateFormat,
                  onTap: () async {
                    final dt = await _pickDateTime(_endAt ?? _startAt);
                    if (dt != null) setState(() => _endAt = dt);
                  },
                ),
                const SizedBox(height: 16),
                const Text('장소 *',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Consumer<ScheduleProvider>(
                  builder: (context, schedProv, _) {
                    final locations = schedProv.locations;
                    return DropdownButtonFormField<String>(
                      value: _selectedLocationId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '장소 선택',
                      ),
                      items: locations
                          .map((loc) => DropdownMenuItem(
                                value: loc.id,
                                child: Text(loc.name),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedLocationId = v),
                      validator: (v) => v == null ? '장소를 선택해주세요' : null,
                    );
                  },
                ),
                const SizedBox(height: 32),
                Consumer<ClubMatchProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.activeBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('친선전 신청',
                              style: TextStyle(fontSize: 16)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required DateTime? value,
    required DateFormat dateFormat,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: AppColors.subText),
                const SizedBox(width: 8),
                Text(
                  value != null ? dateFormat.format(value) : '선택하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: value != null
                        ? AppColors.titleText
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
