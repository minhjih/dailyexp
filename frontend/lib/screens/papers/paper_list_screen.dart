import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class PaperListScreen extends StatelessWidget {
  const PaperListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyExp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 검색 기능 구현
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? primaryLightColor : primaryColor,
              ),
              child: const Text(
                'DailyExp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('논문 목록'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('스크랩'),
              onTap: () {
                // TODO: 스크랩 화면으로 이동
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('그룹'),
              onTap: () {
                // TODO: 그룹 화면으로 이동
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('논문 목록이 여기에 표시됩니다.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 논문 추가 기능 구현
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
