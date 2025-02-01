import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';
import '../../theme/colors.dart';
import '../../api/auth_api.dart';

class SocialScreen extends StatefulWidget {
  final ScrollController scrollController;

  const SocialScreen({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with AutomaticKeepAliveClientMixin {
  bool isResearcherMode = true; // true: Researchers, false: Workspaces
  List<User> recommendedUsers = [];
  bool isLoading = true; // 다시 true로 변경

  @override
  bool get wantKeepAlive => true; // 화면 유지

  @override
  void initState() {
    super.initState();
    _loadRecommendedUsers();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 사용시 필수
    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          onPressed: () =>
                              setState(() => isResearcherMode = true),
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
                          onPressed: () =>
                              setState(() => isResearcherMode = false),
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
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final user = recommendedUsers[index];
              return ResearcherListTile(user: user);
            },
            childCount: recommendedUsers.length,
          ),
        ),
      ],
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
}

class ResearcherListTile extends StatefulWidget {
  final User user;

  const ResearcherListTile({Key? key, required this.user}) : super(key: key);

  @override
  State<ResearcherListTile> createState() => _ResearcherListTileState();
}

class _ResearcherListTileState extends State<ResearcherListTile> {
  bool isFollowing = false;

  Future<void> _followUser() async {
    try {
      await AuthAPI().followUser(widget.user.id!);

      // 프로필 통계 업데이트
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadProfileStats();

      setState(() {
        isFollowing = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to follow user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: isFollowing ? null : _followUser,
          ),
        ],
      ),
    );
  }
}
