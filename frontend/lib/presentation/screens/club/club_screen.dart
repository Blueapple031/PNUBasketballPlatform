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

  // 데이터 로드: 내 동아리 정보와 탐색용 동아리 목록을 가져옵니다.
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();

    // API 호출: 내 동아리 조회
    final myClub = await authProvider.getMyClub();

    // 내 동아리가 없으면 전체 동아리 목록 조회 (탐색용)
    List<ClubModel> allClubs = [];
    List<MemberModel> myClubMembers = [];
    if (myClub == null) {
      allClubs = await authProvider.getClubs() ?? [];
    } else {
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

    // 내 동아리가 있다면 탭 뷰를 포함한 상세 화면을 보여줌
    if (_myClub != null) {
      return _buildMyClubDetailView(_myClub!);
    }

    // 내 동아리가 없다면 동아리 탐색 목록을 보여줌
    return _buildClubDiscoveryView();
  }

  // --- 1. 내 동아리 상세 뷰 (가입된 경우) ---
  Widget _buildMyClubDetailView(ClubModel club) {
    return DefaultTabController(
      length: 2,
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
            ],
          ),
        ),
        body: Column(
          children: [
            ClubHeader(club: club), // 별도 구현된 위젯
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: ClubInfoSection(
                      club: club,
                      onClubUpdated: (updated) =>
                          setState(() => _myClub = updated),
                    ),
                  ),
                  ClubMemberList(members: _myClubMembers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. 동아리 탐색 뷰 (가입 안 된 경우) ---
  Widget _buildClubDiscoveryView() {
    final sections = [
      _ClubSectionData(
        title: '중앙동아리',
        subtitle: '학교 대표 동아리',
        accentColor: AppColors.activeBlue,
        icon: Icons.verified,
        clubs: _allClubs, // 실제로는 필터링 로직 추가 (e.g. .where(...) 사용)
      ),
      _ClubSectionData(
        title: '과동아리',
        subtitle: '학과 중심 동아리',
        accentColor: Colors.teal,
        icon: Icons.school,
        clubs: [],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.headerGrey,
        title: const Text('동아리 탐색', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          itemCount: sections.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildDiscoveryHeader();
            return _ClubSection(
              data: sections[index - 1],
              onTapClub: (club) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiscoveryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.headerGrey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '가입된 동아리가 없습니다.\n아래 카테고리에서 새로운 팀을 찾아보세요!',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// --- 보조 위젯 및 데이터 모델 ---

class _ClubSectionData {
  final String title, subtitle;
  final Color accentColor;
  final IconData icon;
  final List<ClubModel> clubs;

  _ClubSectionData({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.clubs,
  });
}

class _ClubSection extends StatelessWidget {
  final _ClubSectionData data;
  final ValueChanged<ClubModel> onTapClub;

  const _ClubSection({required this.data, required this.onTapClub});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.accentColor.withValues(alpha: 0.15), Colors.transparent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(data.icon, color: data.accentColor),
                const SizedBox(width: 8),
                Text(data.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: data.clubs.isEmpty
                ? const Center(child: Text('해당 카테고리에 동아리가 없습니다.'))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: data.clubs.length,
              itemBuilder: (context, i) => _ClubTile(
                club: data.clubs[i],
                color: data.accentColor,
                onTap: () => onTapClub(data.clubs[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  final ClubModel club;
  final Color color;
  final VoidCallback onTap;

  const _ClubTile({required this.club, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: club.logoUrl != null ? NetworkImage(club.logoUrl!) : null,
              child: club.logoUrl == null ? const Icon(Icons.group) : null,
            ),
            const SizedBox(height: 8),
            Text(
              club.name, // 모델의 name 필드 사용
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}