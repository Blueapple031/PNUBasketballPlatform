import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _realNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _departmentController = TextEditingController();
  final _studentIdController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool _isPnuStudent = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _realNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _departmentController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final dateInput = _dateOfBirthController.text.trim().replaceAll(RegExp(r'\D'), '');
    final dateOfBirth = dateInput.length == 8
        ? '${dateInput.substring(0, 4)}-${dateInput.substring(4, 6)}-${dateInput.substring(6, 8)}'
        : _dateOfBirthController.text.trim();
    final phoneInput = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    final phoneNumber = phoneInput.isEmpty
        ? null
        : (phoneInput.length == 11 && phoneInput.startsWith('010') ? phoneInput : null);

    final authResponse = await authProvider.signup(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      realName: _realNameController.text.trim(),
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      isPnuStudent: _isPnuStudent,
      department: _isPnuStudent ? _departmentController.text.trim() : null,
      studentId: _isPnuStudent ? _studentIdController.text.trim() : null,
    );

    if (authResponse != null && mounted) {
      if (authResponse.user.needsClubSelection == true) {
        Navigator.of(context).pushReplacementNamed('/club-selection');
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '회원가입 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    hintText: 'example@email.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!value.contains('@')) {
                      return '유효한 이메일 형식이 아닙니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '8자 이상, 영문/숫자/특수문자 포함',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 8) {
                      return '비밀번호는 8자 이상이어야 합니다';
                    }
                    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
                      return '비밀번호에 영문을 포함해주세요';
                    }
                    if (!RegExp(r'\d').hasMatch(value)) {
                      return '비밀번호에 숫자를 포함해주세요';
                    }
                    if (!RegExp(r'[@$!%*#?&]').hasMatch(value)) {
                      return '비밀번호에 특수문자(@\$!%*#?&)를 포함해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmController,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePasswordConfirm = !_obscurePasswordConfirm;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePasswordConfirm,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력해주세요';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _realNameController,
                  decoration: const InputDecoration(
                    labelText: '본명',
                    hintText: '2-50자',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '본명을 입력해주세요';
                    }
                    if (value.length < 2 || value.length > 50) {
                      return '본명은 2-50자 사이여야 합니다';
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: '전화번호 (선택)',
                    hintText: '01012345678',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final digits = value.replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 11 || !digits.startsWith('010')) {
                        return '010으로 시작하는 11자리 숫자를 입력해주세요 (예: 01012345678)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('회원가입'),
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

