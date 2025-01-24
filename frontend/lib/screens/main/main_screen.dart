import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../feed/feed_screen.dart';
import '../workspace/workspace_screen.dart';
import '../discover/discover_screen.dart';
import '../social/social_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  MotionTabBarController? _tabController;
  final ScrollController _scrollController = ScrollController();
  AnimationController? _hideController;
  bool _isVisible = true;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = MotionTabBarController(
      initialIndex: 0,
      length: 5,
      vsync: this,
    );

    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.5,
    );

    // 슬라이드 애니메이션을 위한 Tween 설정
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 3.0), // y축으로 300% 이동
    ).animate(_hideController!);

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible) {
          _isVisible = false;
          _hideController?.forward(); // 아래로 스크롤 시 숨김
        }
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_isVisible) {
          _isVisible = true;
          _hideController?.reverse(); // 위로 스크롤 시 보임
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    _hideController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _tabController?.index == 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, -1.5), // 위로 슬라이드
                ).animate(_hideController!),
                child: CustomAppBar(
                  title: 'DailyExp',
                  actions: [
                    IconButton(
                      icon: Icon(Icons.search, color: secondaryTextColor),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_outlined,
                          color: secondaryTextColor),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          FeedScreen(scrollController: _scrollController),
          WorkspaceScreen(scrollController: _scrollController),
          DiscoverScreen(scrollController: _scrollController),
          SocialScreen(scrollController: _scrollController),
          ProfileScreen(scrollController: _scrollController),
        ],
      ),
      bottomNavigationBar: SlideTransition(
        position: _slideAnimation!,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: surfaceColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -20),
              ),
            ],
          ),
          child: MotionTabBar(
            controller: _tabController,
            initialSelectedTab: "피드",
            labels: const ["피드", "워크스페이스", "발견", "친구", "프로필"],
            icons: const [
              Icons.home_rounded,
              Icons.work_rounded,
              Icons.explore_rounded,
              Icons.people_rounded,
              Icons.person_rounded,
            ],
            tabSize: 50,
            tabBarHeight: 55,
            textStyle: TextStyle(
              fontSize: 11,
              color: primaryTextColor,
              fontWeight: FontWeight.w500,
            ),
            tabIconColor: secondaryTextColor,
            tabIconSize: 24.0,
            tabIconSelectedSize: 22.0,
            tabSelectedColor: primaryColor,
            tabIconSelectedColor: surfaceColor,
            tabBarColor: surfaceColor,
            onTabItemSelected: (int value) {
              setState(() {
                _tabController?.index = value;
              });
            },
          ),
        ),
      ),
    );
  }
}
