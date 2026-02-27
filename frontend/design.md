# 📘 PNU Plato Design System (Modern UI for Flutter)

> **문서 개요:** 본 문서는 부산대학교 '플라토(Plato)' 앱의 익숙한 경험(UX)과 최신 앱의 모던한 디자인(UI)을 결합한 **'모던 플라토(Modern Plato)' 구현 가이드라인**입니다.
> **목표:** 학생들에게 친숙한 컬러 아이덴티티를 유지하면서도, 부드러운 형태와 명확한 시맨틱 컬러를 통해 세련된 앱을 구축합니다.

---

## 1. 🎨 Color Palette (Design Tokens)

**주의:** 하드코딩된 색상(예: `Colors.blue`) 사용을 금지하며, 반드시 아래 정의된 변수를 사용하세요.

### 🔹 Primary Colors (핵심 테마)

| Token Name       | Hex Code      | Preview | 용도                                     |
| :--------------- | :------------ | :------ | :--------------------------------------- |
| **`HeaderGrey`** | **`#545454`** | 🔘      | 앱바(AppBar) 및 탭바 배경색              |
| **`ActiveBlue`** | **`#005BAA`** | 🔵      | [PNU Blue] 주요 버튼, 활성 탭, 진행 상태 |
| **`PointCyan`**  | **`#29B6F6`** | 💠      | 상단 앱바의 '오늘 날짜' 강조 포인트      |

### 🔸 Semantic & Status Colors (상태 및 의미)

| Token Name        | Hex Code      | Preview | 용도                                            |
| :---------------- | :------------ | :------ | :---------------------------------------------- |
| **`ClassTeal`**   | **`#26A69A`** | 🟢      | 긍정 (예약 완료, 참여 확정, 정규 교과목)        |
| **`ClassLime`**   | **`#9CCC65`** | 🥎      | 서브 긍정 (비교과, 친선 매치, 공지 배너 포인트) |
| **`AlertOrange`** | **`#FF7043`** | 🟠      | 주의/강조 (new 뱃지, 마감 임박 알림)            |
| **`ErrorRed`**    | **`#E53935`** | 🔴      | 부정/경고 (취소, 삭제, 에러 발생)               |

### ▫️ Base Colors (배경 및 텍스트)

| Token Name      | Hex Code      | 용도                                       |
| :-------------- | :------------ | :----------------------------------------- |
| **`TitleText`** | **`#212121`** | 메인 제목, 본문 (완전 검정 `#000000` 지양) |
| **`SubText`**   | **`#9E9E9E`** | 리스트 내 작성일자, 부가 설명 (연한 회색)  |
| **`PageBg`**    | **`#F5F5F5`** | `Scaffold` 전체 배경색 (아주 연한 회색)    |
| **`BoxBorder`** | **`#E0E0E0`** | 박스 테두리, 리스트 하단 실선              |

---

## 2. 📐 Layout & Component Rules (모던 플라토 규칙)

플라토 디자인의 핵심인 **"Dark Header"**를 유지하되, 하단 콘텐츠는 **"8-Point Grid"**와 **"부드러운 모서리"**를 통해 현대적으로 구성합니다.

### ① 8-Point Grid System (여백 규칙)

앱의 정돈된 느낌을 위해 모든 여백(Padding, Margin)과 요소 간 간격은 **8의 배수**(8, 16, 24, 32...)를 사용합니다. 애매한 숫자(예: 13, 21) 사용을 엄격히 금지합니다.

### ② Header (App Bar)

상단 영역은 무겁고 진한 회색으로 눌러주어 하단 콘텐츠를 돋보이게 합니다.

- **Background:** 무조건 `HeaderGrey (#545454)` 사용. (파란색/흰색 AppBar 금지)
- **Elevation:** `0` (그림자 없음).
- **Tab Bar:** AppBar와 동일한 배경색. 선택된 탭(Indicator)만 `ActiveBlue (#005BAA)`로 강조.

### ③ 형태의 분리: List vs Card (★중요)

연속된 목록과 독립된 박스는 디자인 규칙을 철저히 다르게 적용합니다.

- **연속된 리스트 (List):** 강의 목록, 매치 목록, 알림 목록 등.
  - 둥근 모서리나 그림자를 쓰지 않고, **하단 실선(`BorderBottom`)**으로만 구분하여 플라토 특유의 정갈함을 유지합니다.
- **독립된 컴포넌트 (Card/Box):** 공지 배너, 필터 버튼, 팝업창 등.
  - 화면에 독립적으로 배치되는 요소들은 모서리를 **`12px ~ 16px`**로 부드럽게 둥글게 처리(`BorderRadius.circular(16)`)하여 모던한 느낌을 줍니다.

### ④ 태그 컴포넌트 (Soft Tint 기법)

상태를 나타내는 작은 뱃지나 태그(Chip)는 배경을 진한 원색으로 칠하지 않고, **해당 색상의 투명도(Opacity) 10%**를 주어 세련되게 표현합니다. (공용 `PlatoTag` 위젯 사용)

---

## 3. ✍️ Typography Guidelines

가독성을 위해 폰트의 크기와 색상 위계(Hierarchy)를 철저히 지킵니다.

| 구분            | Size    | Weight           | Color         | 비고                                                   |
| :-------------- | :------ | :--------------- | :------------ | :----------------------------------------------------- |
| **Main Title**  | `16.0`+ | **Bold (w600+)** | `TitleText`   | 메인 콘텐츠 제목, 매치 이름                            |
| **Sub Caption** | `12.0`  | Regular          | `SubText`     | **리스트 내 작성일자**, 부가 설명, 영문 텍스트         |
| **Header Date** | `24.0`  | **Bold**         | `PointCyan`   | **오직 상단 앱바(Header)의 '오늘 날짜' 강조에만 사용** |
| **Badge**       | `11.0`  | **Bold**         | `AlertOrange` | 텍스트 'new', '마감 임박' 표기 시 사용                 |

---

## 4. 💻 Flutter Implementation Code

프로젝트의 `lib/core/constants/` 또는 `lib/core/theme/` 경로에 아래 파일들을 생성하여 팀원들과 공유하세요.

### `plato_theme.dart` (색상 정의)

````dart
import 'package:flutter/material.dart';

abstract class PlatoColors {
  // Main Theme
  static const Color headerGrey = Color(0xFF545454);
  static const Color activeBlue = Color(0xFF005BAA);
  static const Color pointCyan  = Color(0xFF29B6F6);

  // Semantic & Status
  static const Color alertOrange = Color(0xFFFF7043);
  static const Color alertRed    = Color(0xFFE53935); // 에러, 경고
  static const Color classTeal   = Color(0xFF26A69A); // 긍정, 완료
  static const Color classLime   = Color(0xFF9CCC65); // 서브 긍정

  // Base
  static const Color titleText  = Color(0xFF212121);
  static const Color subText    = Color(0xFF9E9E9E);
  static const Color pageBg     = Color(0xFFF5F5F5);
  static const Color border     = Color(0xFFE0E0E0);
}

### `plato_widgets.dart` (공용 컴포넌트 예시)

**1. 모던 태그 (PlatoTag)**
```dart
class PlatoTag extends StatelessWidget {
  final String text;
  final Color baseColor;

  const PlatoTag({Key? key, required this.text, required this.baseColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1), // 투명도 10%로 파스텔톤 효과
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: baseColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

**2. 리스트 아이템  (PlatoListItem)**
Container(
  padding: const EdgeInsets.all(16),
  decoration: const BoxDecoration(
    color: Colors.white,
    border: Border(bottom: BorderSide(color: PlatoColors.border)), // 리스트는 하단 실선만!
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '플랩풋살파크 1호점',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PlatoColors.titleText),
          ),
          // 상태에 따른 시맨틱 태그 사용
          const PlatoTag(text: '마감임박', baseColor: PlatoColors.alertOrange),
        ],
      ),
      const SizedBox(height: 8), // 8-Point Grid 여백
      const Text(
        '2026.02.15 (일) 18:00', // 리스트 내의 날짜는 연한 회색
        style: TextStyle(fontSize: 12, color: PlatoColors.subText),
      ),
    ],
  ),
)

## 5. 🎬 Motion & Interaction

앱 내의 모든 애니메이션과 터치 피드백은 아래의 통일된 규격을 따릅니다. 이를 통해 사용자에게 일관되고 고급스러운 조작감을 제공합니다.

### ① Animation (화면 전환 및 요소 움직임)
* **기본 속도 (Duration):** * `200ms`: 탭, 토글, 상태 변경 등 즉각적이고 빠른 피드백이 필요할 때.
  * `300ms`: 바텀 시트(Bottom Sheet)가 올라오거나, 새로운 페이지로 전환되는 등 일반적인 화면 이동 시.
* **애니메이션 곡선 (Curve):** * `Curves.easeInOut` (부드러운 가속 및 감속)을 기본으로 사용하여 기계적이지 않고 자연스러운 움직임을 연출합니다.

### ② Touch Feedback (터치 피드백)
* **Ripple Effect (물결 효과):** * 클릭 가능한 모든 요소(버튼, 리스트 아이템 등)는 `InkWell` 위젯을 사용하여 터치 피드백을 반드시 제공해야 합니다.
  * **Splash Color:** 기본 회색이 아닌 메인 컬러를 활용하여 아이덴티티를 살립니다.
  * `splashColor: PlatoColors.activeBlue.withValues(alpha: 0.1)`
  * `highlightColor: PlatoColors.activeBlue.withValues(alpha: 0.05)`

## 6. ✅ Design Checklist

Pull Request (코드 리뷰) 전 반드시 확인하세요.

- [ ] **AppBar 배경색**이 무거운 회색(`#545454`)인가? (흰색/파란색 금지)
- [ ] **날짜 색상 구분:** 상단 AppBar의 '오늘 날짜'는 **`Cyan`**, 리스트 내부의 '작성일자/시간'은 **`연한 회색`**으로 명확히 구분했는가?
- [ ] **형태 구분:** 연속된 리스트는 **'하단 실선'**, 화면에 떠 있는 독립 컴포넌트(버튼, 배너)는 **'둥근 모서리(12~16px)'**를 적용했는가?
- [ ] **여백 규칙:** 위젯 간의 간격과 패딩이 **8의 배수**(8, 16, 24...)로 떨어지는가?
- [ ] **시맨틱 태그:** 뱃지나 태그(Chip) 사용 시 원색 배경이 아닌 **투명도 10%(`withValues(alpha: 0.1)`)**를 적용했는가?
- [ ] **터치 피드백:** 클릭 가능한 요소(버튼, 카드 등)에 `InkWell`을 적용하고, 물결 색상을 `ActiveBlue.withValues(alpha: 0.1)`로 지정했는가?
- [ ] **모션 통일성:** 화면 전환이나 애니메이션 발생 시 규정된 속도(`200~300ms`)와 곡선(`Curves.easeInOut`)을 준수했는가?
- [ ] 텍스트와 배경의 명암비가 WCAG AA 기준(4.5:1) 이상인가?
- [ ] 터치 영역이 최소 44x44pt 이상인가?
- [ ] 색상만으로 정보를 전달하지 않는가? (색맹 사용자 고려)
````
