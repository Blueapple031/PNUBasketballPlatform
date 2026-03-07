import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/club_model.dart';
import '../../../data/models/member_model.dart';
import '../../providers/auth_provider.dart';
import 'widgets/club_header.dart';
import 'widgets/club_info_section.dart';
import 'widgets/club_member_list.dart';

class ClubScreen extends StatefulWidget {
  const ClubScreen({super.key});

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  ClubModel? _club;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyClub();
  }

  Future<void> _loadMyClub() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final club = await authProvider.getMyClub();
    if (mounted) {
      setState(() {
        _club = club;
        _isLoading = false;
        _errorMessage = club == null ? authProvider.errorMessage : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          backgroundColor: AppColors.headerGrey,
          elevation: 0,
          title: const Text(
            '동아리',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_club == null) {
      return Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          backgroundColor: AppColors.headerGrey,
          elevation: 0,
          title: const Text(
            '동아리',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadMyClub,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off, size: 64, color: AppColors.subText),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage != null && _errorMessage!.isNotEmpty
                            ? _errorMessage!
                            : '가입한 동아리가 없습니다.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.subText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '학생 회원은 동아리 선택 화면에서 동아리에 가입할 수 있습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subText.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final club = _club!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          backgroundColor: AppColors.headerGrey,
          elevation: 0,
          title: const Text(
            '동아리',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.activeBlue,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.subText,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Members'),
            ],
          ),
        ),
        body: Column(
          children: [
            ClubHeader(club: club),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: ClubInfoSection(club: club),
                  ),
                  ClubMemberList(members: <MemberModel>[]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
