import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/user_provider.dart';
import '../../providers/post_provider.dart';
import '../../models/post.dart';
import 'profile_edit.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../api/auth_api.dart';

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
    _loadProfileData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 표시될 때마다 프로필 정보를 다시 로드
    _loadProfileData();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      widget.onScroll(_scrollController.position.userScrollDirection);
    }
  }

  void _loadProfileData() {
    // 프로필 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      userProvider.fetchUserProfile().then((_) {
        // 사용자 정보가 로드된 후에 포스트 로드
        final user = userProvider.user;
        if (user != null && user.id != null && user.id! > 0) {
          final postProvider = context.read<PostProvider>();
          postProvider.fetchUserPosts(user.id!);
        }
      });
      userProvider.fetchProfileStats(); // 프로필 통계도 함께 로드
    });
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

        // 디버깅 정보 출력
        print('Building ProfileScreen with user: ${user.fullName}');
        print('Profile image URL: ${user.profileImageUrl}');

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _showImageOptions(context),
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: user.profileImageUrl !=
                                                    null &&
                                                user.profileImageUrl!.isNotEmpty
                                            ? (() {
                                                final String imageUrl =
                                                    user.profileImageUrl!;
                                                print(
                                                    'Using profile image URL: $imageUrl');
                                                // 이미지 URL이 http로 시작하지 않으면 .env 파일의 API_URL을 추가
                                                final String apiUrl =
                                                    dotenv.env['API_URL'] ??
                                                        'http://10.0.2.2:8000';
                                                // 캐시 무효화를 위해 타임스탬프 추가
                                                final String fullUrl = imageUrl
                                                        .startsWith('http')
                                                    ? '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}'
                                                    : '$apiUrl$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
                                                print(
                                                    'Full image URL with cache busting: $fullUrl');
                                                return NetworkImage(fullUrl);
                                              })()
                                            : (() {
                                                print(
                                                    'Using placeholder image');
                                                return const NetworkImage(
                                                    'https://via.placeholder.com/150');
                                              })(),
                                        backgroundColor: Colors.grey[200],
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF43A047),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  .map(
                                      (interest) => _buildInterestTag(interest))
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
                            Consumer<PostProvider>(
                              builder: (context, postProvider, child) {
                                if (postProvider.isLoadingUserPosts) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                if (postProvider.hasErrorUserPosts) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        '포스트를 불러오는 중 오류가 발생했습니다.',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                if (postProvider.userPosts.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        '작성한 포스트가 없습니다.',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  children: postProvider.userPosts
                                      .map((post) => _buildUserPostCard(post))
                                      .toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (post.paperTitle != null) ...[
            Text(
              '논문: ${post.paperTitle}',
              style: GoogleFonts.poppins(
                color: Colors.green,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            _formatDate(post.createdAt),
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
                '${post.likeCount}',
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
                '${post.commentCount}',
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

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일').format(date);
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

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCropImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCropImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        _uploadProfileImage(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      print('Uploading profile image: ${imageFile.path}');

      // 이미지 업로드
      final authAPI = AuthAPI();
      final profileImageUrl = await authAPI.uploadProfileImage(imageFile);

      print('Received profile image URL: $profileImageUrl');

      // 사용자 정보 업데이트
      final userProvider = context.read<UserProvider>();
      await userProvider.updateProfileImage(profileImageUrl);

      print(
          'Updated user profile with image URL: ${userProvider.user?.profileImageUrl}');

      // 로딩 닫기
      Navigator.pop(context);

      // 화면 갱신을 위해 setState 호출
      setState(() {});

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 사진이 업데이트되었습니다.')),
      );
    } catch (e) {
      // 로딩 닫기
      Navigator.pop(context);

      print('Error in _uploadProfileImage: $e');

      // 오류 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 사진 업로드 중 오류가 발생했습니다: $e')),
      );
    }
  }
}
