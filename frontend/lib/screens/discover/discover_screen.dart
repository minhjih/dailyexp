import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/colors.dart';
import '../../widgets/screen_header.dart';

class DiscoverScreen extends StatelessWidget {
  final ScrollController scrollController;

  const DiscoverScreen({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(
          title: '논문 추천',
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 논문 제목 ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '저자 정보가 들어갑니다',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '논문 초록이나 요약 내용이 들어갑니다.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
