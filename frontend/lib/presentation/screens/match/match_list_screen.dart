import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/plato_tag.dart';

class MatchListScreen extends StatefulWidget {
  const MatchListScreen({super.key});

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  // 방 만들기 폼 상태
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // 스켈레톤을 위한 더미 데이터 (스타크래프트 방 목록 스타일)
  final List<Map<String, dynamic>> _dummyMatches = [
    {'title': '경암체육관 초보만 오세요~', 'current': 10, 'max': 12, 'type': '남녀모두', 'location': '경암체육관', 'date': '02.22', 'time': '18:00'},
    {'title': '넉넉한터 빡겜 하실분', 'current': 12, 'max': 12, 'type': '남성매치', 'location': '넉넉한터', 'date': '02.23', 'time': '20:00'},
    {'title': '대운동장 매너겜 ㄱㄱㄱ', 'current': 3, 'max': 18, 'type': '친선매치', 'location': '대운동장', 'date': '02.25', 'time': '22:00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.headerGrey,
        title: const Text(
          '매치 목록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        actions: [
          // 방 만들기 (생성) 버튼
          TextButton.icon(
            onPressed: _showCreateMatchSheet,
            icon: const Icon(Icons.add_box, color: AppColors.pointCyan),
            label: const Text('방 만들기', style: TextStyle(color: AppColors.pointCyan, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 상단: 검색 및 필터 영역 (스타크래프트 방 검색 느낌)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.pageBg,
                      borderRadius: BorderRadius.circular(8), // 검색창은 둥글게
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: AppColors.subText),
                        hintText: '매치 이름 검색...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: AppColors.headerGrey),
                  onPressed: () {
                    // 필터 기능 
                  },
                ),
              ],
            ),
          ),
          
          // 리스트 헤더 (인원 | 방 이름 | 유형 | 장소/시간) - 생략 가능하지만 스타크래프트 느낌을 위해 추가
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.pageBg,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: const [
                SizedBox(width: 50, child: Text('인원', style: TextStyle(fontSize: 12, color: AppColors.subText))),
                Expanded(child: Text('방 이름', style: TextStyle(fontSize: 12, color: AppColors.subText))),
                SizedBox(width: 70, child: Text('장소', style: TextStyle(fontSize: 12, color: AppColors.subText), textAlign: TextAlign.center)),
                SizedBox(width: 80, child: Text('날짜/시간', style: TextStyle(fontSize: 12, color: AppColors.subText), textAlign: TextAlign.right)),
              ],
            ),
          ),

          // 하단: 매치 리스트 (가이드라인 준수: 하단 실선 플랫 리스트)
          Expanded(
            child: ListView.builder(
              itemCount: _dummyMatches.length,
              itemBuilder: (context, index) {
                final match = _dummyMatches[index];
                final isFull = match['current'] == match['max'];

                return InkWell( // 🎬 모션 가이드 적용: 터치 피드백
                  onTap: () {},
                  splashColor: AppColors.activeBlue.withValues(alpha: 0.1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        // 1. 인원 (스타크래프트의 2/4 느낌)
                        SizedBox(
                          width: 50,
                          child: Text(
                            '${match['current']}/${match['max']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isFull ? AppColors.alertOrange : AppColors.activeBlue,
                            ),
                          ),
                        ),
                        // 2. 방 제목 및 태그
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                match['title'],
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.titleText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              PlatoTag( // 위젯 가이드 적용
                                text: match['type'], 
                                baseColor: isFull ? AppColors.subText : AppColors.classLime,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 3. 장소
                        SizedBox(
                          width: 70,
                          child: Text(
                            match['location'],
                            style: const TextStyle(fontSize: 12, color: AppColors.titleText, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 4. 날짜/시간
                        SizedBox(
                          width: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${match['date']} (${_getDayOfWeek(match['date'])})', style: const TextStyle(fontSize: 11, color: AppColors.subText)),
                              const SizedBox(height: 2),
                              Text(match['time'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.titleText)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 방 만들기 다이얼로그 (Bottom Sheet)
  // ==========================================
  void _showCreateMatchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드 올라올 때 대비
      backgroundColor: Colors.transparent, // 모서리 둥글기를 위해 투명으로 설정
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // 키보드 높이만큼 여백
            top: 24, left: 24, right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), // 둥근 모서리 가이드 적용
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 높이 차지
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('새 매치 만들기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.titleText)),
              const SizedBox(height: 24),
              
              // 1. 방 이름 (Create Name)
              const Text('방 이름', style: TextStyle(fontSize: 13, color: AppColors.subText)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'ex) 1:1 투혼 초보만 (경암체육관 빡겜)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // 2. 장소 (Map)
              const Text('장소', style: TextStyle(fontSize: 13, color: AppColors.subText)),
              const SizedBox(height: 8),
              // 스켈레톤용 더미 드롭다운
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                child: const Text('장소 선택 (경암체육관 등)', style: TextStyle(color: AppColors.subText)),
              ),
              const SizedBox(height: 16),

              // 3. 날짜 및 시간 (Row로 배치)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('날짜', style: TextStyle(fontSize: 13, color: AppColors.subText)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedDate != null
                                      ? '${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.day.toString().padLeft(2, '0')} (${_getDayOfWeekFromDate(_selectedDate!)})'
                                      : '날짜 선택',
                                  style: TextStyle(
                                    color: _selectedDate != null ? AppColors.titleText : AppColors.subText,
                                  ),
                                ),
                                const Icon(Icons.calendar_today, size: 18, color: AppColors.subText),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('시간', style: TextStyle(fontSize: 13, color: AppColors.subText)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedTime != null
                                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                      : '시간 선택',
                                  style: TextStyle(
                                    color: _selectedTime != null ? AppColors.titleText : AppColors.subText,
                                  ),
                                ),
                                const Icon(Icons.access_time, size: 18, color: AppColors.subText),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. 모집 인원
              const Text('모집 인원', style: TextStyle(fontSize: 13, color: AppColors.subText)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                child: const Text('12 명', style: TextStyle(color: AppColors.titleText)),
              ),
              const SizedBox(height: 32),

              // 확인 버튼 (Ok)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.activeBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 버튼 모서리 둥글게
                  ),
                  onPressed: () {
                    Navigator.pop(context); // 시트 닫기
                  },
                  child: const Text('방 만들기 (Ok)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // 날짜 선택기
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.activeBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 시간 선택기
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.activeBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // 날짜에서 요일 구하기
  String _getDayOfWeekFromDate(DateTime date) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return weekdays[date.weekday % 7];
  }

  // 문자열 날짜(MM.DD)에서 요일 구하기 (2026년 기준)
  String _getDayOfWeek(String dateStr) {
    try {
      final parts = dateStr.split('.');
      if (parts.length == 2) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final date = DateTime(2026, month, day);
        return _getDayOfWeekFromDate(date);
      }
    } catch (e) {
      // 파싱 실패 시 빈 문자열 반환
    }
    return '';
  }
}