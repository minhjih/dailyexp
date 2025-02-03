import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../theme/colors.dart';
import '../../api/auth_api.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import '../../models/workspace.dart';
import '../../screens/social/workspace_detail_screen.dart';

class SocialScreen extends StatefulWidget {
  final ScrollController scrollController;
  final Function(ScrollDirection)? onScroll;

  const SocialScreen({
    Key? key,
    required this.scrollController,
    this.onScroll,
  }) : super(key: key);

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with AutomaticKeepAliveClientMixin {
  bool isResearcherMode = true;
  List<User> recommendedUsers = [];
  List<Workspace> recommendedWorkspaces = [];
  bool isLoading = true;
  // 각 탭별로 별도의 스크롤 컨트롤러 사용
  final ScrollController _researcherScrollController = ScrollController();
  final ScrollController _workspaceScrollController = ScrollController();

  @override
  bool get wantKeepAlive => true; // 화면 유지

  @override
  void initState() {
    super.initState();
    _loadRecommendedUsers();
    _researcherScrollController.addListener(_scrollListener);
    _workspaceScrollController.addListener(_scrollListener);
    if (!isResearcherMode) {
      _loadRecommendedWorkspaces();
    }
  }

  void _scrollListener() {
    if (widget.onScroll != null) {
      final controller = isResearcherMode
          ? _researcherScrollController
          : _workspaceScrollController;
      if (controller.position.userScrollDirection == ScrollDirection.reverse) {
        widget.onScroll!(ScrollDirection.reverse);
      } else if (controller.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.onScroll!(ScrollDirection.forward);
      }
    }
  }

  @override
  void dispose() {
    _researcherScrollController.removeListener(_scrollListener);
    _researcherScrollController.dispose();
    _workspaceScrollController.removeListener(_scrollListener);
    _workspaceScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 사용시 필수
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onTabChanged(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isResearcherMode
                          ? const Color(0xFF00BFA5)
                          : Colors.grey[200],
                      foregroundColor:
                          isResearcherMode ? Colors.white : Colors.grey[600],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Researchers'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onTabChanged(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isResearcherMode
                          ? const Color(0xFF00BFA5)
                          : Colors.grey[200],
                      foregroundColor:
                          !isResearcherMode ? Colors.white : Colors.grey[600],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Workspaces'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isResearcherMode
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              'Recommended Researchers',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed:
                                  isLoading ? null : _loadRecommendedUsers,
                              color: const Color(0xFF00BFA5),
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            controller: _researcherScrollController,
                            padding: EdgeInsets.zero,
                            itemCount: recommendedUsers.length,
                            itemBuilder: (context, index) {
                              final user = recommendedUsers[index];
                              return ResearcherListTile(user: user);
                            },
                          ),
                        ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              'Recommended Workspaces',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed:
                                  isLoading ? null : _loadRecommendedWorkspaces,
                              color: const Color(0xFF00BFA5),
                            ),
                          ],
                        ),
                      ),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        Expanded(
                          child: buildWorkspaceList(),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadRecommendedUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;

      // 팔로잉 목록 가져오기
      final followingIds = await AuthAPI().getFollowingIds();

      List<User> users = [];
      List<MapEntry<User, int>> userScores = [];

      for (int i = 1; i <= 10; i++) {
        if (currentUser?.id != i && !followingIds.contains(i)) {
          // 팔로우하지 않은 사용자만 포함
          try {
            User user = await userProvider.loadUserProfile(i);

            // 매칭 점수 계산
            int score = 0;

            if (user.researchField == currentUser?.researchField) {
              score += 3;
            }

            if (user.institution == currentUser?.institution) {
              score += 2;
            }

            final commonInterests = user.researchInterests
                .where((interest) =>
                    currentUser?.researchInterests.contains(interest) ?? false)
                .length;
            score += commonInterests;

            userScores.add(MapEntry(user, score));
          } catch (e) {
            print('Failed to load user $i: $e');
          }
        }
      }

      userScores.sort((a, b) => b.value.compareTo(a.value));
      users = userScores.take(5).map((entry) => entry.key).toList();

      if (mounted) {
        setState(() {
          recommendedUsers = users;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading recommended users: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildWorkspaceList() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ListView.builder(
      controller: _workspaceScrollController,
      padding: EdgeInsets.zero,
      itemCount: recommendedWorkspaces.length,
      itemBuilder: (context, index) {
        final workspace = recommendedWorkspaces[index];
        return WorkspaceListTile(
          workspace: workspace,
          onWorkspaceUpdated: _loadRecommendedWorkspaces,
        );
      },
    );
  }

  Future<void> _loadRecommendedWorkspaces() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;

      // API 호출하여 추천 워크스페이스 가져오기
      final workspaces = await AuthAPI().getRecommendedWorkspaces(
        researchField: currentUser?.researchField,
        interests: currentUser?.researchInterests,
      );

      setState(() {
        recommendedWorkspaces = workspaces;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading recommended workspaces: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 탭 전환 시 데이터 로드
  void _onTabChanged(bool isResearcher) {
    setState(() {
      isResearcherMode = isResearcher;
      if (isResearcher) {
        _loadRecommendedUsers();
      } else {
        _loadRecommendedWorkspaces();
      }
    });
  }
}

class ResearcherListTile extends StatefulWidget {
  final User user;

  const ResearcherListTile({Key? key, required this.user}) : super(key: key);

  @override
  State<ResearcherListTile> createState() => _ResearcherListTileState();
}

class _ResearcherListTileState extends State<ResearcherListTile> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isFollowing = userProvider.followingIds.contains(widget.user.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: widget.user.profileImageUrl != null
                ? NetworkImage(widget.user.profileImageUrl!)
                : null,
            child: widget.user.profileImageUrl == null
                ? Text(widget.user.fullName[0],
                    style: const TextStyle(fontSize: 20))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${widget.user.fullName}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.user.researchField} - ${widget.user.institution}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '12 papers in ${widget.user.researchField}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF00BFA5),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFollowing ? Icons.check_circle : Icons.person_add_outlined,
              color: isFollowing ? const Color(0xFF00BFA5) : Colors.grey[600],
            ),
            onPressed: isFollowing ? null : () => _followUser(userProvider),
          ),
        ],
      ),
    );
  }

  Future<void> _followUser(UserProvider userProvider) async {
    try {
      await userProvider.followUser(widget.user.id!);
      await userProvider.loadProfileStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to follow user: $e')),
      );
    }
  }
}

class WorkspaceListTile extends StatelessWidget {
  final Workspace workspace;
  final Function? onWorkspaceUpdated;

  const WorkspaceListTile({
    Key? key,
    required this.workspace,
    this.onWorkspaceUpdated,
  }) : super(key: key);

  String _getFollowingMembersText(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    if (currentUser == null) return '';

    // 팔로우하는 멤버들 찾기
    final followingIds = userProvider.followingIds;
    final followingMembers = workspace.members
        .where((member) => followingIds.contains(member.userId))
        .map((member) => member.user.fullName)
        .toList();

    if (followingMembers.isEmpty) return '';
    if (followingMembers.length == 1) {
      return '${followingMembers[0]} is a member';
    }
    if (followingMembers.length == 2) {
      return '${followingMembers[0]} and ${followingMembers[1]} are members';
    }
    return '${followingMembers[0]} and ${followingMembers.length - 1} others are members';
  }

  @override
  Widget build(BuildContext context) {
    final followingMembersText = _getFollowingMembersText(context);

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkspaceDetailScreen(workspace: workspace),
          ),
        );
        if (result == true && onWorkspaceUpdated != null) {
          onWorkspaceUpdated!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 워크스페이스 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.group_work_outlined,
                color: Colors.green[400],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // 워크스페이스 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workspace.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${workspace.memberCount} members',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Text(' · '),
                      Text(
                        '${workspace.papers.length} papers',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (followingMembersText.isNotEmpty)
                    Text(
                      followingMembersText,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF00BFA5),
                      ),
                    ),
                  Text(
                    'Last updated ${_getTimeAgo()}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // 더보기 버튼
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[400]),
              onPressed: () {
                // 더보기 메뉴 처리
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(workspace.updatedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}
