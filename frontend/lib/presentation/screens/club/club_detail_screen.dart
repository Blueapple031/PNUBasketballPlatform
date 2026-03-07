import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/club_model.dart';
import '../../../data/models/member_model.dart';
import '../../providers/auth_provider.dart';
import 'widgets/club_header.dart';
import 'widgets/club_info_section.dart';
import 'widgets/club_member_list.dart';

class ClubDetailScreen extends StatefulWidget {
  final ClubModel club;

  const ClubDetailScreen({
    super.key,
    required this.club,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  List<MemberModel> _members = [];
  bool _membersLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final authProvider = context.read<AuthProvider>();
    final members = await authProvider.getClubMembers(widget.club.clubId);

    if (mounted) {
      setState(() {
        _members = members ?? [];
        _membersLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: AppBar(
          backgroundColor: AppColors.headerGrey,
          elevation: 0,
          title: Text(
            widget.club.name,
            style: const TextStyle(
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
              Tab(text: '정보'),
              Tab(text: '멤버'),
            ],
          ),
        ),
        body: Column(
          children: [
            ClubHeader(club: widget.club),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: ClubInfoSection(club: widget.club),
                  ),
                  _membersLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ClubMemberList(members: _members),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
