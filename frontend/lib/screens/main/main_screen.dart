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
import '../workspace/workspace_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../papers/paper_list_screen.dart';

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
  Map<String, dynamic>? _selectedWorkspace;
  int _selectedIndex = 0;

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
      value: 0.0,
    );

    // 슬라이드 애니메이션을 위한 Tween 설정
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 4.0), // y축으로 400% 이동 (더 아래로)
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

  void _goBackToWorkspaceList() {
    setState(() {
      _selectedWorkspace = null;
    });
  }

  void _handleScroll(ScrollDirection direction) {
    if (direction == ScrollDirection.reverse) {
      // 네비게이션 바 숨기기
    } else {
      // 네비게이션 바 보이기
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FeedScreen(scrollController: _scrollController, onScroll: _handleScroll),
      _selectedWorkspace == null
          ? WorkspaceScreen(
              scrollController: _scrollController,
              tabController: _tabController,
              onWorkspaceSelected: (workspace) {
                setState(() {
                  _selectedWorkspace = workspace;
                });
              },
            )
          : WorkspaceDetailScreen(
              workspace: _selectedWorkspace!,
              onBack: _goBackToWorkspaceList,
            ),
      PaperListScreen(scrollController: _scrollController),
      SocialScreen(
          scrollController: _scrollController, onScroll: _handleScroll),
      ProfileScreen(
          scrollController: _scrollController, onScroll: _handleScroll),
    ];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0, -1.5),
          ).animate(_hideController!),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -3), // y축으로 -10 픽셀 만큼 이동
                      child: Text(
                        'glimpse',
                        style: GoogleFonts.pacifico(
                          fontSize: 24,
                          color: const Color(0xFF43A047),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_outlined),
                          onPressed: null,
                        ),
                        IconButton(
                          icon: Icon(Icons.mail_outline),
                          onPressed: null,
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            _tabController?.index = 4;
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: const NetworkImage(
                                'https://via.placeholder.com/150'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _hideController!,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.only(
              top: kToolbarHeight + 20,
            ).copyWith(
              top: ((kToolbarHeight + 20) * (1 - _hideController!.value)),
              bottom: 44 * (1 - _hideController!.value),
            ),
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: screens,
            ),
          );
        },
      ),
      bottomNavigationBar: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.1),
          end: const Offset(0, 1.5),
        ).animate(_hideController!),
        child: MotionTabBar(
          controller: _tabController,
          initialSelectedTab: "Feed",
          labels: const ["Feed", "Workspace", "Explore", "Network", "Profile"],
          icons: const [
            Icons.home_outlined,
            Icons.work_outline,
            Icons.explore_outlined,
            Icons.people_outline,
            Icons.person_outline
          ],
          tabSize: 30,
          tabBarHeight: 40,
          textStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFF43A047),
            fontWeight: FontWeight.w500,
          ),
          tabIconColor: Colors.grey[600],
          tabIconSize: 24.0,
          tabIconSelectedSize: 22.0,
          tabSelectedColor: const Color(0xFF43A047),
          tabIconSelectedColor: Colors.white,
          tabBarColor: Colors.white,
          onTabItemSelected: (int value) {
            setState(() {
              _tabController?.index = value;
            });
          },
        ),
      ),
    );
  }
}
