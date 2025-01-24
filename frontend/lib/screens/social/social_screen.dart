import 'package:flutter/material.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('친구'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '친구 목록'),
              Tab(text: '그룹'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFriendsList(),
            _buildGroupsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('친구 ${index + 1}'),
            subtitle: const Text('상태 메시지'),
            trailing: TextButton(
              child: const Text('팔로우'),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupsList() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.group),
            ),
            title: Text('연구 그룹 ${index + 1}'),
            subtitle: const Text('5명의 멤버'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        );
      },
    );
  }
}
