import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/club_model.dart';
import '../../../data/models/member_model.dart';
import '../../providers/auth_provider.dart';
import 'widgets/club_header.dart';
import 'widgets/club_info_section.dart';
import 'widgets/club_member_list.dart';
import 'club_detail_screen.dart';

class ClubScreen extends StatefulWidget {
  const ClubScreen({super.key});

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  ClubModel? _myClub;
  List<ClubModel> _allClubs = [];
  List<MemberModel> _myClubMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 데이터 로드: 내 동아리 정보, 전체 동아리 순위 목록, 멤버 목록
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();

    // API 호출: 내 동아리 조회
    final myClub = await authProvider.getMyClub();

    // 전체 동아리 목록(승리 수 기준 순위) 항상 조회
    final allClubs = await authProvider.getClubs() ?? [];

    List<MemberModel> myClubMembers = [];
    if (myClub != null) {
      myClubMembers = await authProvider.getClubMembers(myClub.clubId) ?? [];
    }

    if (mounted) {
      setState(() {
        _myClub = myClub;
        _allClubs = allClubs;
        _myClubMembers = myClubMembers;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 내 동아리가 있다면 탭 뷰(정보, 멤버, 순위)를 포함한 상세 화면
    if (_myClub != null) {
      return _buildMyClubDetailView(_myClub!);
    }

    // 내 동아리가 없다면 전체 동아리 순위 목록을 보여줌
    return _buildClubRankingView();
  }

  // --- 1. 내 동아리 상세 뷰 (가입된 경우) ---
  Widget _buildMyClubDetailView(ClubModel club) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          backgroundColor: AppColors.headerGrey,
          elevation: 0,
          title: const Text(
            '내 동아리',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.activeBlue,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.subText,
            tabs: [
              Tab(text: '정보'),
              Tab(text: '멤버'),
              Tab(text: '순위'),
            ],
          ),
        ),
        body: Column(
          children: [
            ClubHeader(club: club),
            Expanded(
              child: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ClubInfoSection(
                        club: club,
                        onClubUpdated: (updated) =>
                            setState(() => _myClub = updated),
                      ),
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: _loadData,
                    child: ClubMemberList(members: _myClubMembers),
                  ),
                  RefreshIndicator(
                    onRefresh: _loadData,
                    child: _buildClubRankingList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. 전체 동아리 순위 뷰 (가입 안 된 경우 또는 순위 탭) ---
  Widget _buildClubRankingView() {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.headerGrey,
        title: const Text('전체 동아리 순위', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildClubRankingList(),
      ),
    );
  }

  Widget _buildClubRankingList() {
    if (_allClubs.isEmpty) {
      return const Center(
        child: Text('등록된 동아리가 없습니다.'),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: _allClubs.length,
      itemBuilder: (context, index) {
        final club = _allClubs[index];
        return _RankedClubTile(
          club: club,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
          ),
        );
      },
    );
  }
}

// --- 보조 위젯 ---

class _RankedClubTile extends StatelessWidget {
  final ClubModel club;
  final VoidCallback onTap;

  const _RankedClubTile({required this.club, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rank = club.rank > 0 ? club.rank : 0;
    final rankColor = rank <= 3
        ? (rank == 1
            ? const Color(0xFFFFD700) // 금
            : rank == 2
                ? const Color(0xFFC0C0C0) // 은
                : const Color(0xFFCD7F32)) // 동
        : AppColors.subText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: rankColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 24,
              backgroundImage: club.logoUrl != null && club.logoUrl!.isNotEmpty
                  ? NetworkImage(club.logoUrl!)
                  : null,
              child: club.logoUrl == null || club.logoUrl!.isEmpty
                  ? const Icon(Icons.group, color: AppColors.subText)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '승리 ${club.wins}승',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.subText),
          ],
        ),
      ),
    );
  }
}