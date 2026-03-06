import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/club_model.dart';

class ClubSelectionScreen extends StatefulWidget {
  const ClubSelectionScreen({super.key});

  @override
  State<ClubSelectionScreen> createState() => _ClubSelectionScreenState();
}

class _ClubSelectionScreenState extends State<ClubSelectionScreen> {
  List<ClubModel>? _clubs;
  String? _errorMessage;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    final authProvider = context.read<AuthProvider>();
    final clubs = await authProvider.getClubs();
    if (mounted) {
      setState(() {
        _clubs = clubs;
        _errorMessage = clubs == null ? (authProvider.errorMessage ?? '동아리 목록을 불러올 수 없습니다') : null;
      });
    }
  }

  void _showRoleSelection(String clubId, String clubName) {
    showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$clubName 가입',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '동아리 내 역할을 선택해주세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              _buildRoleOption(context, 'MEMBER', '동아리원', '재학생 멤버'),
              _buildRoleOption(context, 'MANAGER', '매니저', '행정·운영 보조'),
              _buildRoleOption(context, 'OB', 'OB', '졸업생/휴학생'),
            ],
          ),
        ),
      ),
    ).then((role) {
      if (role != null) _selectClub(clubId, role);
    });
  }

  Widget _buildRoleOption(BuildContext context, String value, String roleName, String roleDesc) {
    return ListTile(
      title: Text(roleName),
      subtitle: Text(roleDesc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      onTap: () => Navigator.of(context).pop(value),
    );
  }

  Future<void> _selectClub(String clubId, [String role = 'MEMBER']) async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();

    setState(() => _isSelecting = true);
    final result = await authProvider.selectClub(clubId, role: role);

    if (!mounted) return;
    setState(() => _isSelecting = false);

    if (result != null) {
      Navigator.of(context).pushReplacementNamed('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.clubName}에 가입되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '동아리 가입 실패'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('동아리 선택'),
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isSelecting)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_clubs == null && _errorMessage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadClubs,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final clubs = _clubs!;
    if (clubs.isEmpty) {
      return const Center(
        child: Text('등록된 동아리가 없습니다.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: club.logoUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(club.logoUrl!),
                  )
                : CircleAvatar(
                    child: Text(club.name.isNotEmpty ? club.name[0] : '?'),
                  ),
            title: Text(club.name),
            subtitle: Text('${club.memberCount}명'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showRoleSelection(club.clubId, club.name),
          ),
        );
      },
    );
  }
}
