import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import '../../providers/post_provider.dart';
import '../../models/post.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedScreen extends StatefulWidget {
  final Function(ScrollDirection) onScroll;

  const FeedScreen({
    super.key,
    required this.onScroll,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  Map<int, bool> _isCommentsVisible = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);

    // 포스트 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false)
          .fetchFeedPosts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      widget.onScroll(_scrollController.position.userScrollDirection);
    }

    // 무한 스크롤 구현
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<PostProvider>(context, listen: false).fetchFeedPosts();
    }
  }

  void _toggleComments(int postId) {
    setState(() {
      _isCommentsVisible[postId] = !(_isCommentsVisible[postId] ?? false);
    });

    // 댓글이 표시될 때 댓글 데이터 로드
    if (_isCommentsVisible[postId] ?? false) {
      Provider.of<PostProvider>(context, listen: false).fetchComments(postId);
    }
  }

  void _toggleLike(int postId) {
    Provider.of<PostProvider>(context, listen: false).toggleLike(postId);
  }

  void _toggleSave(int postId) {
    Provider.of<PostProvider>(context, listen: false).toggleSave(postId);
  }

  void _submitComment(int postId) {
    if (_commentController.text.trim().isNotEmpty) {
      Provider.of<PostProvider>(context, listen: false)
          .addComment(postId, _commentController.text.trim());
      _commentController.clear();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('yyyy년 MM월 dd일').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색창
        Container(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 4, // 하단 패딩을 줄임
          ),
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
            decoration: InputDecoration(
              hintText: '논문과 연구자 검색...',
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
            cursorColor: const Color(0xFF43A047),
          ),
        ),

        // 검색창과 포스트 목록 사이의 간격 조정
        const SizedBox(height: 2),

        // 피드 목록
        Expanded(
          child: Consumer<PostProvider>(
            builder: (context, postProvider, child) {
              if (postProvider.isLoading && postProvider.posts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF43A047),
                  ),
                );
              }

              if (postProvider.hasError && postProvider.posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '데이터를 불러오는 중 오류가 발생했습니다',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          postProvider.fetchFeedPosts(refresh: true);
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                );
              }

              if (postProvider.posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.feed_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '팔로우한 사용자의 포스트가 없습니다',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '관심 있는 연구자를 팔로우하여 최신 소식을 받아보세요',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await postProvider.fetchFeedPosts(refresh: true);
                },
                color: const Color(0xFF43A047),
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
                          padding: EdgeInsets.zero, // 리스트뷰의 기본 패딩 제거
                          itemCount: postProvider.posts.length +
                              (postProvider.hasMorePosts ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == postProvider.posts.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF43A047),
                                  ),
                                ),
                              );
                            }

                            final post = postProvider.posts[index];
                            return buildPostCard(post);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildPostCard(Post post) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
        top: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: (() {
                final String imageUrl = post.authorProfileImage ??
                    'https://via.placeholder.com/150';
                // 이미지 URL이 http로 시작하지 않으면 .env 파일의 API_URL을 추가
                if (imageUrl.startsWith('http') ||
                    imageUrl == 'https://via.placeholder.com/150') {
                  return NetworkImage(imageUrl);
                } else {
                  final String apiUrl =
                      dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
                  return NetworkImage('$apiUrl$imageUrl');
                }
              })(),
            ),
            title: Text(
              post.authorName ?? '익명',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '연구자 ID: ${post.authorId}',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
            trailing: Text(
              _formatDate(post.createdAt),
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (post.paperTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '논문: ${post.paperTitle}',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF43A047),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                  ),
                ),
                if (post.keyInsights != null &&
                    post.keyInsights!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '주요 인사이트:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...post.keyInsights!
                      .map((insight) => _buildKeyInsight(insight))
                      .toList(),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildInteractionButton(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  '${post.likeCount}',
                  () => _toggleLike(post.id),
                  post.isLiked ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 24),
                _buildInteractionButton(
                  Icons.comment_outlined,
                  '${post.commentCount}',
                  () => _toggleComments(post.id),
                  Colors.grey,
                ),
                const Spacer(),
                _buildInteractionButton(
                  post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  '저장',
                  () => _toggleSave(post.id),
                  post.isSaved ? const Color(0xFF43A047) : Colors.grey,
                ),
              ],
            ),
          ),
          if (_isCommentsVisible[post.id] ?? false) buildCommentsSection(post),
        ],
      ),
    );
  }

  Widget _buildKeyInsight(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String text,
    VoidCallback onPressed,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: iconColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCommentsSection(Post post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '댓글',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        if (post.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '첫 번째 댓글을 남겨보세요',
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
              ),
            ),
          ),
        ...post.comments.map((comment) => ListTile(
              leading: CircleAvatar(
                backgroundImage: (() {
                  final String imageUrl = comment.userProfileImage ??
                      'https://via.placeholder.com/150';
                  // 이미지 URL이 http로 시작하지 않으면 .env 파일의 API_URL을 추가
                  if (imageUrl.startsWith('http') ||
                      imageUrl == 'https://via.placeholder.com/150') {
                    return NetworkImage(imageUrl);
                  } else {
                    final String apiUrl =
                        dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
                    return NetworkImage('$apiUrl$imageUrl');
                  }
                })(),
              ),
              title: Row(
                children: [
                  Text(
                    comment.userName ?? '익명',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(comment.createdAt),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  comment.content,
                  style: GoogleFonts.poppins(),
                ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: '댓글 작성...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _submitComment(post.id),
                icon: const Icon(
                  Icons.send,
                  color: Color(0xFF43A047),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
