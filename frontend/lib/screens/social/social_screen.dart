import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/colors.dart';
import '../../widgets/screen_header.dart';

class SocialScreen extends StatelessWidget {
  final ScrollController scrollController;

  const SocialScreen({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenHeader(title: '친구'),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: '친구 목록'),
                    Tab(text: '그룹'),
                  ],
                  labelColor: primaryColor,
                  unselectedLabelColor: secondaryTextColor,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildFriendsList(),
                      _buildGroupsList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsList() {
    return ListView.builder(
      controller: scrollController,
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(context, shrinkOffset, overlapsContent) => tabBar;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) => false;
}
