import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/screens/profile/BasicInfoPage.dart';
import 'package:frontend/screens/profile/AffiliationInfoPage.dart';
import 'package:frontend/screens/profile/ResearchInfoPage.dart';
import 'package:frontend/screens/profile/ProfileInfoPage.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),  // 상단바 높이 조정
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () {
              Navigator.pop(context); // 뒤로가기 버튼
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            children: [
              //Expanded(child: Container()), // 왼쪽 빈 공간
              Text(
                '프로필 수정',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Expanded(child: Container()), // 오른쪽 빈 공간
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // "계정설정" 텍스트
            Text(
              '계정설정',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10), // 텍스트와 버튼 사이에 간격 추가

            // 버튼들을 묶는 테두리
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: <Widget>[
                  _buildSectionButton(context, '기본정보', Icons.info, _navigateToBasicInfo),
                  _buildSectionButton(context, '소속정보', Icons.business, _navigateToAffiliationInfo),
                  _buildSectionButton(context, '연구정보', Icons.science, _navigateToResearchInfo),
                  _buildSectionButton(context, '프로필정보', Icons.person, _navigateToProfileInfo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 버튼을 만드는 함수
  Widget _buildSectionButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: Colors.green), // 아이콘 추가
                SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.green),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 각각의 섹션에 대한 페이지로 이동하는 함수들
  void _navigateToBasicInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BasicInfoPage()),
    );
  }

  void _navigateToAffiliationInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AffiliationInfoPage()),
    );
  }

  void _navigateToResearchInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResearchInfoPage()),
    );
  }

  void _navigateToProfileInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileInfoPage()),
    );
  }
}
