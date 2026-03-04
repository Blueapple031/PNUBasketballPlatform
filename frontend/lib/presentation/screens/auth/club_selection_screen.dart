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

  Future<void> _selectClub(String clubId) async {
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.selectClub(clubId);

    if (result != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.clubName}에 가입되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
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
      body: _buildBody(),
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
            onTap: () => _selectClub(club.clubId),
          ),
        );
      },
    );
  }
}
