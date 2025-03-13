import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../../models/post.dart';
import '../../providers/post_provider.dart';
import '../../models/comment.dart';
import '../../utils/image_utils.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoadingComments = true;
    });

    try {
      await Provider.of<PostProvider>(context, listen: false)
          .fetchComments(widget.post.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글을 불러오는 중 오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      print(
          '상세 화면에서 댓글 추가 시도: 포스트 ID=${widget.post.id}, 내용=${_commentController.text.trim()}');

      await Provider.of<PostProvider>(context, listen: false)
          .addComment(widget.post.id, _commentController.text.trim());

      _commentController.clear();
      print('상세 화면에서 댓글 추가 성공');
    } catch (e) {
      print('상세 화면에서 댓글 추가 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 추가 중 오류가 발생했습니다: $e')),
      );
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          // 현재 포스트 찾기
          final currentPost = postProvider.posts.firstWhere(
            (p) => p.id == widget.post.id,
            orElse: () => widget.post,
          );

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // 상단 작성자 정보 및 뒤로가기 버튼
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            getFullImageUrl(currentPost.authorProfileImage),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentPost.authorName ?? '익명',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _formatDate(currentPost.createdAt),
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 포스트 내용
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 포스트 제목
                        Text(
                          currentPost.title,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 포스트 내용
                        Text(
                          currentPost.content,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 논문 정보 (있는 경우)
                        if (currentPost.paperTitle != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '관련 논문',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentPost.paperTitle!,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 주요 인사이트 (있는 경우)
                        if (currentPost.keyInsights != null &&
                            currentPost.keyInsights!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '주요 인사이트',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...currentPost.keyInsights!
                                    .map((insight) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '• ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  insight,
                                                  style: GoogleFonts.poppins(
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 좋아요, 저장, 댓글 버튼
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            currentPost.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: currentPost.isLiked ? Colors.red : null,
                          ),
                          onPressed: () {
                            postProvider.toggleLike(currentPost.id);
                          },
                        ),
                        Text(
                          currentPost.likeCount.toString(),
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(
                            currentPost.isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: currentPost.isSaved ? Colors.blue : null,
                          ),
                          onPressed: () {
                            postProvider.toggleSave(currentPost.id);
                          },
                        ),
                        Text(
                          currentPost.saveCount.toString(),
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment_outlined),
                        const SizedBox(width: 4),
                        Text(
                          currentPost.commentCount.toString(),
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: Divider(thickness: 1, height: 32),
                ),

                // 댓글 섹션
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '댓글',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 댓글 입력
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  hintText: '댓글을 입력하세요...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _addComment,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 댓글 목록
                if (_isLoadingComments)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (currentPost.comments.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          '아직 댓글이 없습니다.\n첫 번째 댓글을 남겨보세요!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comment = currentPost.comments[index];
                        return _buildCommentItem(comment);
                      },
                      childCount: currentPost.comments.length,
                    ),
                  ),

                // 하단 여백
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              getFullImageUrl(comment.authorProfileImage),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.authorName ?? '익명',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(comment.createdAt),
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comment.content,
                    style: GoogleFonts.poppins(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
