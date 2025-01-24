import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/colors.dart';
import '../../widgets/screen_header.dart';

class ProfileScreen extends StatelessWidget {
  final ScrollController scrollController;

  const ProfileScreen({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(
          title: '프로필',
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 16),
              Text(
                '사용자 이름',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '소속 기관',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildStatRow(),
              const Divider(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(label: '논문', value: '15'),
        _StatItem(label: '팔로워', value: '128'),
        _StatItem(label: '팔로잉', value: '91'),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      children: [
        ActionChip(
          avatar: const Icon(Icons.edit),
          label: const Text('프로필 수정'),
          onPressed: () {},
        ),
        ActionChip(
          avatar: const Icon(Icons.share),
          label: const Text('프로필 공유'),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 활동',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.article),
              title: Text('활동 ${index + 1}'),
              subtitle: const Text('2시간 전'),
            );
          },
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }
}
