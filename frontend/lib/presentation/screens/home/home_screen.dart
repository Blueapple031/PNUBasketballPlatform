import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainFeedScreen();
  }
}


class MainFeedScreen extends StatefulWidget {
  const MainFeedScreen({super.key});
  
  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  // 임시 프로필 데이터
  final List<Map<String, dynamic>> _profiles = [
    {
      'nickname': '농구왕되고싶다',
      'age': 24,
      'location': '부산 금정구',
      'bio': '주 3회 농구하고 싶어요! 같이 할 사람 구합니다~',
      'isOnline': true,
      'isNew': false,
    },
    {
      'nickname': '슛신',
      'age': 28,
      'location': '부산 해운대구',
      'bio': '3점슛 전문. 편하게 게임하실 분 찾아요',
      'isOnline': false,
      'isNew': true,
    },
    {
      'nickname': '리바운드킹',
      'age': 22,
      'location': '부산 연제구',
      'bio': '리바운드와 수비 자신있습니다',
      'isOnline': true,
      'isNew': false,
    },
    {
      'nickname': '가드맨',
      'age': 26,
      'location': '부산 남구',
      'bio': '포인트가드 포지션 선호합니다',
      'isOnline': false,
      'isNew': false,
    },
    {
      'nickname': '센터포지션',
      'age': 30,
      'location': '부산 사하구',
      'bio': '주말 저녁에 게임 원합니다',
      'isOnline': true,
      'isNew': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.sports_basketball, color: Colors.orange[700], size: 28),
            const SizedBox(width: 8),
            const Text(
              '딸바',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림 기능 준비 중입니다')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('필터 기능 준비 중입니다')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 칩 영역
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('내 지역', Icons.location_on),
                  const SizedBox(width: 8),
                  _buildFilterChip('나이대', Icons.cake),
                  const SizedBox(width: 8),
                  _buildFilterChip('실력', Icons.sports_score),
                  const SizedBox(width: 8),
                  _buildFilterChip('포지션', Icons.sports_basketball),
                  const SizedBox(width: 8),
                  _buildFilterChip('접속 중', Icons.circle, isActive: true),
                ],
              ),
            ),
          ),
          // 프로필 리스트
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                return _buildProfileCard(profile);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, {bool isActive = false}) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isActive,
      onSelected: (bool value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label 필터 준비 중입니다')),
        );
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.black87,
        fontSize: 13,
      ),
      side: BorderSide(color: isActive ? Colors.blue : Colors.grey[300]!),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${profile['nickname']} 프로필 상세 보기 준비 중')),
          );
        },
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 사진
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[200],
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                if (profile['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // 프로필 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile['nickname'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (profile['isNew'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile['age']}세 · ${profile['location']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile['bio'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // 좋아요 버튼
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${profile['nickname']}님에게 관심 표시!')),
                          );
                        },
                        icon: Icon(Icons.favorite_border, size: 18, color: Colors.red[400]),
                        label: const Text('관심 표시'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${profile['nickname']}님에게 메시지 보내기 준비 중')),
                          );
                        },
                        icon: Icon(Icons.message_outlined, size: 18, color: Colors.blue[400]),
                        label: const Text('메시지'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 더보기 아이콘
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('더보기 메뉴 준비 중입니다')),
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}
