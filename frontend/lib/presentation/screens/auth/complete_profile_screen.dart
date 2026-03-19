import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _realNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _departmentController = TextEditingController();
  final _studentIdController = TextEditingController();
  bool _isPnuStudent = true;
  String? _selectedPosition;

  static const _positions = [
    {'value': 'GUARD', 'label': '가드'},
    {'value': 'FORWARD', 'label': '포워드'},
    {'value': 'CENTER', 'label': '센터'},
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _realNameController.dispose();
    _dateOfBirthController.dispose();
    _departmentController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final dateInput = _dateOfBirthController.text.trim().replaceAll(RegExp(r'\D'), '');
    final dateOfBirth = dateInput.length == 8
        ? '${dateInput.substring(0, 4)}-${dateInput.substring(4, 6)}-${dateInput.substring(6, 8)}'
        : _dateOfBirthController.text.trim();

    final user = await authProvider.completeProfile(
      nickname: _nicknameController.text.trim(),
      position: _selectedPosition!,
      realName: _realNameController.text.trim().isEmpty
          ? null
          : _realNameController.text.trim(),
      dateOfBirth: dateOfBirth,
      isPnuStudent: _isPnuStudent,
      department: _isPnuStudent ? _departmentController.text.trim() : null,
      studentId: _isPnuStudent ? _studentIdController.text.trim() : null,
    );

    if (user != null && mounted) {
      final status = await authProvider.getClubSelectionStatus();
      if (!mounted) return;
      if (status?.needsClubSelection == true) {
        Navigator.of(context).pushReplacementNamed('/club-selection');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '추가 정보 저장 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('추가 정보 입력'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '서비스 이용을 위해 추가 정보를 입력해주세요.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임 *',
                    hintText: '2~30자, 앱 내 활동에 사용됩니다',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    if (value.trim().length < 2 || value.trim().length > 30) {
                      return '닉네임은 2~30자 사이여야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  '주 포지션 *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _positions.map((pos) {
                    final isSelected = _selectedPosition == pos['value'];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: pos != _positions.last ? 8.0 : 0,
                        ),
                        child: ChoiceChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(
                              pos['label']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.titleText,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.activeBlue,
                          onSelected: (_) {
                            setState(() => _selectedPosition = pos['value']);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_selectedPosition == null) ...[
                  const SizedBox(height: 4),
                ],
                Builder(builder: (context) {
                  return const SizedBox.shrink();
                }),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _realNameController,
                  decoration: const InputDecoration(
                    labelText: '본명 (선택)',
                    hintText: '2-50자',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 2 || value.length > 50) {
                        return '본명은 2-50자 사이여야 합니다';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateOfBirthController,
                  decoration: const InputDecoration(
                    labelText: '생년월일',
                    hintText: '20021001',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '생년월일을 입력해주세요';
                    }
                    final digits = value.replaceAll(RegExp(r'\D'), '');
                    if (digits.length != 8) {
                      return 'YYYYMMDD 형식으로 8자리 입력해주세요 (예: 20021001)';
                    }
                    final y = int.tryParse(digits.substring(0, 4));
                    final m = int.tryParse(digits.substring(4, 6));
                    final d = int.tryParse(digits.substring(6, 8));
                    if (y == null || m == null || d == null || m < 1 || m > 12 || d < 1 || d > 31) {
                      return '올바른 날짜를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('부산대 학생'),
                  value: _isPnuStudent,
                  onChanged: (v) => setState(() => _isPnuStudent = v),
                ),
                if (_isPnuStudent) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: '학과',
                      hintText: '컴퓨터공학과',
                      border: OutlineInputBorder(),
                    ),
                    validator: _isPnuStudent
                        ? (value) {
                            if (value == null || value.isEmpty) {
                              return '학과를 입력해주세요';
                            }
                            return null;
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: '학번',
                      hintText: '20241234',
                      border: OutlineInputBorder(),
                    ),
                    validator: _isPnuStudent
                        ? (value) {
                            if (value == null || value.isEmpty) {
                              return '학번을 입력해주세요';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              if (_selectedPosition == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('포지션을 선택해주세요'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              _handleComplete();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('완료'),
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
}
