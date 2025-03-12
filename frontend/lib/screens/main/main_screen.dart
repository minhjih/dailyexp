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
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  MotionTabBarController? _tabController;
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

    // 사용자 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadCurrentUser();
    });

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

    _hideController?.addListener(() {
      if (_hideController!.value == 1.0) {
        setState(() {
          _isVisible = false;
        });
      } else if (_hideController!.value == 0.0) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _hideController?.dispose();
    super.dispose();
  }

  void _goBackToWorkspaceList() {
    setState(() {
      _selectedWorkspace = null;
    });
  }

  void handleScroll(ScrollDirection direction) {
    if (direction == ScrollDirection.reverse) {
      if (_isVisible) {
        setState(() {
          _isVisible = false;
          _hideController?.forward();
        });
      }
    }
    if (direction == ScrollDirection.forward) {
      if (!_isVisible) {
        setState(() {
          _isVisible = true;
          _hideController?.reverse();
        });
      }
    }
  }

  // 터치 시 네비게이션 바와 앱바를 원상복귀하는 메소드
  void showNavigationBars() {
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
        _hideController?.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight + statusBarHeight;

    // 네비게이션 바 높이 계산 (모션탭바 높이 + 하단 안전 영역)
    final double motionTabBarHeight =
        40.0; // MotionTabBar의 실제 높이 (tabBarHeight: 40)
    final double bottomPadding =
        MediaQuery.of(context).padding.bottom; // 하단 안전 영역 (노치 등)
    final double bottomNavHeight = motionTabBarHeight + bottomPadding;

    return GestureDetector(
      onTap: showNavigationBars,
      child: Scaffold(
        extendBody: true, // 네비게이션 바가 컨텐츠 위에 겹쳐지도록 설정
        extendBodyBehindAppBar: true, // 앱바가 컨텐츠 위에 겹쳐지도록 설정
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
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
                        offset: Offset(0, -3), // y축으로 -3 픽셀 만큼 이동
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
                            child: Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                final user = userProvider.user;
                                String? profileImageUrl = user?.profileImageUrl;

                                return CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: (profileImageUrl != null &&
                                          profileImageUrl.isNotEmpty)
                                      ? (() {
                                          // 이미지 URL이 http로 시작하지 않으면 .env 파일의 API_URL을 추가
                                          final String apiUrl =
                                              dotenv.env['API_URL'] ??
                                                  'http://10.0.2.2:8000';
                                          final String fullUrl =
                                              profileImageUrl.startsWith('http')
                                                  ? profileImageUrl
                                                  : '$apiUrl$profileImageUrl';
                                          return NetworkImage(fullUrl);
                                        })()
                                      : const NetworkImage(
                                          'https://via.placeholder.com/150'),
                                );
                              },
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
            return SafeArea(
              top: false, // 상단 SafeArea는 비활성화하여 앱바 아래부터 시작하도록 함
              bottom: false, // 하단 SafeArea도 비활성화하여 컨텐츠가 전체 화면을 차지하도록 함
              child: Stack(
                children: [
                  // 컨텐츠 영역은 앱바 아래부터 화면 전체를 차지하도록 설정
                  Positioned.fill(
                    top: appBarHeight *
                        (1 -
                            _hideController!
                                .value), // 앱바 애니메이션에 맞춰 동적으로 상단 여백 조정
                    // 하단 여백 없이 화면 끝까지 컨텐츠 표시 (네비게이션 바는 컨텐츠 위에 겹쳐짐)
                    bottom: 0,
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        FeedScreen(onScroll: handleScroll),
                        _selectedWorkspace == null
                            ? WorkspaceScreen(
                                onScroll: handleScroll,
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
                        PaperListScreen(onScroll: handleScroll),
                        SocialScreen(onScroll: handleScroll),
                        ProfileScreen(onScroll: handleScroll),
                      ],
                    ),
                  ),
                ],
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
            labels: const [
              "Feed",
              "Workspace",
              "Explore",
              "Network",
              "Profile"
            ],
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
      ),
    );
  }
}
