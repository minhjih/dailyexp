import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import '../../providers/user_provider.dart';
import 'profile_edit.dart';

class ProfileScreen extends StatefulWidget {
  final Function(ScrollDirection) onScroll;

  const ProfileScreen({
    super.key,
    required this.onScroll,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    // 프로필 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      userProvider.fetchUserProfile();
      userProvider.fetchProfileStats(); // 프로필 통계도 함께 로드
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userProvider.user;
        if (user == null) {
          return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
        }

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : const NetworkImage(
                                'https://via.placeholder.com/150'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${user.department ?? 'Department'} at ${user.institution ?? 'Institution'}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '${userProvider.followingCount} Following',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${userProvider.followersCount} Followers',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfileEditPage()), // 프로필 수정 페이지로 이동
                          );
                        },
                        child: Text(
                          '프로필 수정',
                          style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (user.bio != null)
                    Text(
                      user.bio!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: user.researchInterests
                        .map((interest) => _buildInterestTag(interest))
                        .toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Posts',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search my posts...',
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
                  ),
                  const SizedBox(height: 16),
                  _buildPostCard(
                    'Advancing AI in Healthcare: A Comprehensive Study',
                    'Published in Nature Medicine · 2023',
                    '234',
                    '45',
                  ),
                  _buildPostCard(
                    'Quantum Computing Applications in Medical Imaging',
                    'Published in Science · 2023',
                    '189',
                    '32',
                  ),
                  _buildPostCard(
                    '5G Security in Healthcare Systems',
                    'Published in IEEE · 2022',
                    '156',
                    '28',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInterestTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: GoogleFonts.poppins(
          color: Colors.green,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPostCard(
      String title, String publishInfo, String likes, String comments) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            publishInfo,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                likes,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline,
                  size: 20, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                comments,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
