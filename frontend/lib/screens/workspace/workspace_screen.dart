import 'package:flutter/material.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('워크스페이스'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // 새 워크스페이스 추가
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text('워크스페이스 ${index + 1}'),
              subtitle: const Text('3개의 논문'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 워크스페이스 상세 페이지로 이동
              },
            ),
          );
        },
      ),
    );
  }
}
