import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/colors.dart';
import '../../widgets/screen_header.dart';

class WorkspaceScreen extends StatelessWidget {
  final ScrollController scrollController;

  const WorkspaceScreen({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(
          title: '워크스페이스',
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
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
        ),
      ],
    );
  }
}
