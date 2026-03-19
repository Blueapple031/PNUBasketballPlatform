import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';

import '../../providers/recruitment_provider.dart';
import '../../providers/schedule_provider.dart';

class RecruitmentCreateScreen extends StatefulWidget {
  const RecruitmentCreateScreen({super.key});

  @override
  State<RecruitmentCreateScreen> createState() =>
      _RecruitmentCreateScreenState();
}

class _RecruitmentCreateScreenState extends State<RecruitmentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startAt;
  DateTime? _endAt;
  DateTime? _deadlineAt;
  String? _selectedLocationId;
  String _gameFormat = 'FIVE_VS_FIVE';
  final _baseMembersController = TextEditingController(text: '1');
  final _neededMembersController = TextEditingController(text: '5');

  static const _gameFormats = [
    {'value': 'THREE_VS_THREE', 'label': '3:3'},
    {'value': 'FOUR_VS_FOUR', 'label': '4:4'},
    {'value': 'FIVE_VS_FIVE', 'label': '5:5'},
    {'value': 'FLEXIBLE', 'label': '자유'},
  ];

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

  @override
  void dispose() {
    _baseMembersController.dispose();
    _neededMembersController.dispose();
    super.dispose();
  }

  /// 휠 스타일 날짜·시간 선택 (Cupertino 스타일, 더 직관적)
  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    var picked = initial ?? DateTime.now().add(const Duration(hours: 1));
    if (picked.isBefore(DateTime.now())) {
      picked = DateTime.now().add(const Duration(hours: 1));
    }

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 320,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, picked),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: picked,
                minimumDate: DateTime.now(),
                maximumDate: DateTime.now().add(const Duration(days: 90)),
                onDateTimeChanged: (dt) => picked = dt,
              ),
            ),
          ],
        ),
      ),
    );
    return result;
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

    final provider = context.read<RecruitmentProvider>();
    final fmt = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

    final result = await provider.create(
      startAt: fmt.format(_startAt!),
      endAt: fmt.format(_endAt!),
      locationId: _selectedLocationId!,
      baseMembersCount: int.parse(_baseMembersController.text),
      neededMembers: int.parse(_neededMembersController.text),
      gameFormat: _gameFormat,
      deadlineAt: _deadlineAt != null ? fmt.format(_deadlineAt!) : null,
    );

    if (result != null && mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모집글이 생성되었습니다')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '생성 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M/d(E) HH:mm', 'ko');

    return Scaffold(
      appBar: AppBar(title: const Text('모집글 작성')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('경기 형태 *',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: _gameFormats
                      .map((f) => ButtonSegment(
                            value: f['value']!,
                            label: Text(f['label']!),
                          ))
                      .toList(),
                  selected: {_gameFormat},
                  onSelectionChanged: (v) =>
                      setState(() => _gameFormat = v.first),
                ),
                const SizedBox(height: 20),
                _buildDateTimePicker(
                  label: '시작 시각 *',
                  value: _startAt,
                  dateFormat: dateFormat,
                  onTap: () async {
                    final dt = await _pickDateTime(_startAt);
                    if (dt != null) {
                      setState(() {
                        _startAt = dt;
                        // 시작 시간 설정 시 마감을 자동으로 30분 전으로 설정 (수동 수정 가능)
                        var deadline = dt.subtract(const Duration(minutes: 30));
                        _deadlineAt = deadline.isBefore(DateTime.now())
                            ? DateTime.now()
                            : deadline;
                      });
                    }
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _baseMembersController,
                        decoration: const InputDecoration(
                          labelText: '기본 인원 *',
                          hintText: '이미 확보된 인원',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1) return '1 이상 입력';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _neededMembersController,
                        decoration: const InputDecoration(
                          labelText: '모집 인원 *',
                          hintText: '추가로 필요한 인원',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1) return '1 이상 입력';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDateTimePicker(
                  label: '마감 시각 (선택)',
                  value: _deadlineAt,
                  dateFormat: dateFormat,
                  onTap: () async {
                    final dt = await _pickDateTime(_deadlineAt ?? _startAt);
                    if (dt != null) setState(() => _deadlineAt = dt);
                  },
                ),
                const SizedBox(height: 32),
                Consumer<RecruitmentProvider>(
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
                          : const Text('모집 시작',
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
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                const Icon(Icons.calendar_today, size: 18, color: AppColors.subText),
                const SizedBox(width: 8),
                Text(
                  value != null ? dateFormat.format(value) : '선택하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: value != null ? AppColors.titleText : AppColors.textDisabled,
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
