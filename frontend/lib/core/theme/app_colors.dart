import 'package:flutter/material.dart';

/// PNU Basketball Platform - Design System Color Palette
/// 
/// PNU Plato 디자인 시스템을 기반으로 한 색상 정의
/// 
/// 주의: 하드코딩된 색상(예: Colors.blue, Color(0xFF...)) 사용 금지
/// 반드시 이 파일에 정의된 상수를 사용하세요
class AppColors {
  AppColors._(); // private constructor (인스턴스 생성 방지)

  // ===== Primary Colors (핵심 테마) =====
  
  /// [PNU Blue] 주요 버튼, 활성 탭, 진행 상태
  static const Color activeBlue = Color(0xFF005BAA);
  
  /// 앱바(AppBar) 및 탭바 배경색
  static const Color headerGrey = Color(0xFF545454);
  
  /// 상단 앱바의 '오늘 날짜' 강조 포인트
  static const Color pointCyan = Color(0xFF29B6F6);
  
  // ===== Semantic & Status Colors (상태 및 의미) =====
  
  /// 긍정 (예약 완료, 참여 확정, 정규 교과목)
  static const Color classTeal = Color(0xFF26A69A);
  
  /// 서브 긍정 (비교과, 친선 매치, 공지 배너 포인트)
  static const Color classLime = Color(0xFF9CCC65);
  
  /// 주의/강조 (new 뱃지, 마감 임박 알림)
  static const Color alertOrange = Color(0xFFFF7043);
  
  /// 부정/경고 (취소, 삭제, 에러 발생)
  static const Color errorRed = Color(0xFFE53935);
  
  // ===== Base Colors (배경 및 텍스트) =====
  
  /// 메인 제목, 본문 (완전 검정 #000000 지양)
  static const Color titleText = Color(0xFF212121);
  
  /// 리스트 내 작성일자, 부가 설명 (연한 회색)
  static const Color subText = Color(0xFF9E9E9E);
  
  /// Scaffold 전체 배경색 (아주 연한 회색)
  static const Color pageBg = Color(0xFFF5F5F5);
  
  /// 박스 테두리, 리스트 하단 실선
  static const Color border = Color(0xFFE0E0E0);
  
  // ===== Additional Colors =====
  
  /// 온라인 상태 표시
  static const Color onlineGreen = Color(0xFF4CAF50);
  
  /// 배경 - 순수 흰색
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  
  /// 텍스트 - 보조 (더 진한 회색)
  static const Color textSecondary = Color(0xFF757575);
  
  /// 텍스트 - 비활성화
  static const Color textDisabled = Color(0xFFBDBDBD);
}
