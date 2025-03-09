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
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocialScreen extends StatefulWidget {
  final Function(ScrollDirection) onScroll;

  const SocialScreen({
    super.key,
    required this.onScroll,
  });

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with AutomaticKeepAliveClientMixin {
  bool isResearcherMode = true;
  List<User> recommendedUsers = [];
  List<User> filteredUsers = [];
  List<Workspace> recommendedWorkspaces = [];
  List<Workspace> filteredWorkspaces = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true; // 화면 유지

  @override
  void initState() {
    super.initState();
    _loadRecommendedUsers();
    _scrollController.addListener(_handleScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      widget.onScroll(_scrollController.position.userScrollDirection);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        filteredUsers = recommendedUsers;
        filteredWorkspaces = recommendedWorkspaces;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isResearcherMode) {
        final results = await AuthAPI().searchUsers(query);
        if (mounted) {
          setState(() {
            filteredUsers = results;
            isLoading = false;
          });
        }
      } else {
        final results = await AuthAPI().searchWorkspaces(query);
        if (mounted) {
          setState(() {
            filteredWorkspaces = results;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error searching: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 고정된 상단 부분
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // 검색창
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    enabled: true,
                    decoration: InputDecoration(
                      hintText: isResearcherMode
                          ? 'Search researchers...'
                          : 'Search workspaces...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterItems,
                  ),
                ),
                // 탭 버튼
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
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
                            foregroundColor: isResearcherMode
                                ? Colors.white
                                : Colors.grey[600],
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
                            foregroundColor: !isResearcherMode
                                ? Colors.white
                                : Colors.grey[600],
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
              ],
            ),
          ),
          // 스크롤 가능한 리스트 부분
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      if (isResearcherMode) {
                        await _loadRecommendedUsers();
                      } else {
                        await _loadRecommendedWorkspaces();
                      }
                    },
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: isResearcherMode
                                  ? filteredUsers.length
                                  : filteredWorkspaces.length,
                              itemBuilder: (context, index) {
                                if (filteredUsers.isEmpty && isResearcherMode) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('No researchers found'),
                                    ),
                                  );
                                }
                                return isResearcherMode
                                    ? ResearcherListTile(
                                        user: filteredUsers[index])
                                    : WorkspaceListTile(
                                        workspace: filteredWorkspaces[index],
                                        onWorkspaceUpdated:
                                            _loadRecommendedWorkspaces,
                                      );
                              },
                            ),
                          ),
                        );
                      },
                    ),
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

      // 팔로잉 목록 새로 가져오기
      await userProvider.loadProfileStats(); // 팔로잉 상태 업데이트
      final followingIds = await AuthAPI().getFollowingIds();

      // 모든 사용자 목록 가져오기
      final allUsers = await AuthAPI().getAllUsers();
      List<MapEntry<User, int>> userScores = [];

      // 현재 사용자와 이미 팔로우 중인 사용자 제외
      for (var user in allUsers) {
        if (user.id != currentUser?.id && !followingIds.contains(user.id)) {
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
        }
      }

      userScores.sort((a, b) => b.value.compareTo(a.value));
      final users = userScores.take(5).map((entry) => entry.key).toList();

      if (mounted) {
        setState(() {
          recommendedUsers = users;
          filteredUsers = users;
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
      controller: _scrollController,
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
        filteredWorkspaces = workspaces;
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
      _searchController.clear();
      if (isResearcher) {
        filteredUsers = recommendedUsers;
      } else {
        filteredWorkspaces = recommendedWorkspaces;
        if (filteredWorkspaces.isEmpty) {
          _loadRecommendedWorkspaces();
        }
      }
    });
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        // 검색어가 비어있으면 모든 항목 표시
        filteredUsers = recommendedUsers;
        filteredWorkspaces = recommendedWorkspaces;
      } else {
        // 검색어에 따라 필터링
        if (isResearcherMode) {
          filteredUsers = recommendedUsers.where((user) {
            return user.fullName.toLowerCase().contains(query.toLowerCase()) ||
                (user.institution
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false) ||
                (user.researchField
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false);
          }).toList();
        } else {
          filteredWorkspaces = recommendedWorkspaces.where((workspace) {
            return workspace.name.toLowerCase().contains(query.toLowerCase()) ||
                workspace.description
                    .toLowerCase()
                    .contains(query.toLowerCase());
          }).toList();
        }
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
                ? (() {
                    final String imageUrl = widget.user.profileImageUrl!;
                    // 이미지 URL이 http로 시작하지 않으면 .env 파일의 API_URL을 추가
                    final String apiUrl =
                        dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
                    final String fullUrl = imageUrl.startsWith('http')
                        ? imageUrl
                        : '$apiUrl$imageUrl';
                    return NetworkImage(fullUrl);
                  })()
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

  // 팔로우하는 멤버 목록 가져오기
  List<WorkspaceMember> _getFollowingMembers(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final followingIds = userProvider.followingIds;
    return workspace.members
        .where((member) => followingIds.contains(member.userId))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final followingMembersText = _getFollowingMembersText(context);
    final followingMembers = _getFollowingMembers(context);

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
                    Row(
                      children: [
                        // 멤버 프로필 이미지 표시
                        SizedBox(
                          height: 30,
                          child: Stack(
                            children: [
                              for (int i = 0;
                                  i < followingMembers.length && i < 3;
                                  i++)
                                Positioned(
                                  left: i * 20.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundImage: followingMembers[i]
                                                  .user
                                                  .profileImageUrl !=
                                              null
                                          ? (() {
                                              final String imageUrl =
                                                  followingMembers[i]
                                                      .user
                                                      .profileImageUrl!;
                                              // 이미지 URL이 http로 시작하지 않으면 .env 파일의 API_URL을 추가
                                              final String apiUrl =
                                                  dotenv.env['API_URL'] ??
                                                      'http://10.0.2.2:8000';
                                              final String fullUrl =
                                                  imageUrl.startsWith('http')
                                                      ? imageUrl
                                                      : '$apiUrl$imageUrl';
                                              return NetworkImage(fullUrl);
                                            })()
                                          : null,
                                      child: followingMembers[i]
                                                  .user
                                                  .profileImageUrl ==
                                              null
                                          ? Text(
                                              followingMembers[i]
                                                  .user
                                                  .fullName[0],
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              if (followingMembers.length > 3)
                                Positioned(
                                  left: 3 * 20.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      color: Colors.grey[300],
                                    ),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        '+${followingMembers.length - 3}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            followingMembersText,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF00BFA5),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
