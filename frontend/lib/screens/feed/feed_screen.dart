import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class FeedScreen extends StatefulWidget {
  final ScrollController scrollController;

  const FeedScreen({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _isSaved = false; // 저장 상태 추가
  bool _isLiked = false; // 좋아요 상태 추가
  int _likeCount = 245; // 좋아요 개수 추가
  bool _isCommentsVisible = false; // 댓글 섹션의 확장 상태 추가

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색창
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              hintText: 'Search papers and researchers...',
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
        // 피드 목록
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: 10,
            itemBuilder: (context, index) {
              return buildPostCard();
            },
          ),
        ),
      ],
    );
  }

  Widget buildPostCard() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://via.placeholder.com/150',
              ),
            ),
            title: Text(
              'Dr. Sarah Chen',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Stanford University',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novel Approaches in Quantum Computing: A Review',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A comprehensive analysis of recent developments in quantum computing architectures and their implications for scalable quantum systems.',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Key Insights:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _buildKeyInsight(
                    'New error correction methods show 50% improvement'),
                _buildKeyInsight(
                    'Hybrid quantum-classical systems emerge as promising'),
                _buildKeyInsight(
                    'Scalability challenges require novel approaches'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildInteractionButton(Icons.favorite, Icons.favorite_border,
                    _likeCount.toString(), _toggleLike, Colors.red, _isLiked),
                const SizedBox(width: 24),
                _buildInteractionButton(Icons.comment, Icons.comment_outlined,
                    '18', _toggleComments, Colors.grey, _isCommentsVisible),
                const Spacer(),
                _buildInteractionButton(
                    Icons.bookmark,
                    Icons.bookmark_border,
                    _isSaved ? 'Saved' : 'Save',
                    _toggleSave,
                    const Color(0xFF43A047),
                    _isSaved),
              ],
            ),
          ),
          _isCommentsVisible ? buildCommentsSection() : SizedBox.shrink(),
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

  Widget _buildInteractionButton(IconData activeIcon, IconData inactiveIcon,
      String text, VoidCallback onPressed, Color IconColor,
      [bool isActive = false]) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(isActive ? activeIcon : inactiveIcon,
              size: 20, color: isActive ? IconColor : Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isActive ? IconColor : Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1; // 좋아요 상태에 따라 카운트 증감
    });
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
  }

  void _toggleComments() {
    setState(() {
      _isCommentsVisible = !_isCommentsVisible;
    });
  }

  Widget buildCommentsSection() {
    // 예제 댓글 데이터
    List<Map<String, dynamic>> comments = [
      {
        "name": "Minkyu Park",
        "time": "5분 전",
        "profileImage": "https://via.placeholder.com/150",
        "comment":
            "As someone deeply fascinated by both theoretical and applied physics, I find the potential of quantum computing truly revolutionary.",
      },
      {
        "name": "Jadestar Min",
        "time": "39분 전",
        "profileImage": "https://via.placeholder.com/150",
        "comment":
            "The notion that quantum computers could one day solve complex problems, which are currently beyond the reach of classical computers, in mere seconds is mind-blowing.",
      },
      // 추가 댓글 데이터...
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Write a comment...",
              suffixIcon: Icon(Icons.send),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20), // 테두리의 둥근 모서리
                borderSide:
                    BorderSide(color: Colors.grey, width: 1), // 테두리 색상과 두께
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                    color: Colors.grey, width: 1), // 활성화 상태에서의 테두리 색상과 두께
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                    color: Color(0xFF43A047),
                    width: 2), // 포커스를 받았을 때의 테두리 색상과 두께
              ),
              filled: false,
              fillColor: Colors.grey[200],
            ),
            cursorColor: const Color(0xFF43A047),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                comments.map((comment) => buildCommentItem(comment)).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(comment['profileImage']),
            radius: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['name'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8), // 이름과 시간 사이 간격 조정
                    Text(
                      comment['time'],
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600], // 시간 표시 색상 조정
                        fontSize: 12, // 시간 표시 크기 조정
                      ),
                    ),
                  ],
                ),
                Text(
                  comment['comment'],
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
