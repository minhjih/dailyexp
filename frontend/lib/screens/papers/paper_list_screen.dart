import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../api/auth_api.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/papers/paper_search_screen.dart';
import '../../widgets/workspace_selection_sheet.dart';

class PaperListScreen extends StatefulWidget {
  final Function(ScrollDirection) onScroll;

  const PaperListScreen({
    super.key,
    required this.onScroll,
  });

  @override
  _PaperListScreenState createState() => _PaperListScreenState();
}

class _PaperListScreenState extends State<PaperListScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true; // 상태 유지

  List<dynamic> searchResults = [];
  List<dynamic> recommendedPapers = [];
  List<dynamic> trendingPapers = [];
  bool isLoading = true;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? selectedPaper;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection !=
        ScrollDirection.idle) {
      widget.onScroll(_scrollController.position.userScrollDirection);
    }
  }

  Future<void> _loadInitialPapers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 사용자의 연구 분야 기반 추천 논문
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final researchField = userProvider.user?.researchField ?? '';
      final recommended =
          await AuthAPI().searchArxivPapers('cat:$researchField');

      // 트렌딩 논문 (예: physics, cs.AI, math 등의 인기 분야)
      final trending =
          await AuthAPI().searchArxivPapers('cat:physics+OR+cat:cs.AI');

      setState(() {
        recommendedPapers = recommended.take(3).toList(); // 2개에서 3개로 변경
        trendingPapers = trending.take(3).toList(); // 3개만 표시
        isLoading = false;
      });
    } catch (e) {
      print('Error loading papers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _searchPapers(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      isSearching = true;
    });

    try {
      final results = await AuthAPI().searchArxivPapers(query);
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error searching papers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatSummary(String summary) {
    return summary.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // 검색창 (고정)
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search arXiv papers...',
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
                  onChanged: _searchPapers,
                ),
              ),
              if (isSearching)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      isSearching = false;
                      searchResults = [];
                    });
                  },
                ),
            ],
          ),
        ),
        // 내용 부분
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : selectedPaper != null
                  ? _buildPaperDetail()
                  : isSearching
                      ? ListView.builder(
                          controller: _scrollController,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final paper = searchResults[index];
                            return _buildPaperCard(
                              paper['title'],
                              paper['authors'].join(', '),
                              paper['published_date'],
                              paper['categories'].join(', '),
                              paperData: paper,
                            );
                          },
                        )
                      : ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Recommended Papers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recommended for You',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _loadInitialPapers();
                                  },
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (recommendedPapers.isEmpty && !isLoading)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Click refresh to load recommendations',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else
                              ...recommendedPapers
                                  .map((paper) => _buildPaperCard(
                                        paper['title'],
                                        paper['authors'].join(', '),
                                        paper['published_date'],
                                        paper['categories'].join(', '),
                                        paperData: paper,
                                      )),
                            const SizedBox(height: 32),

                            // Trending Papers
                            Text(
                              'Trending Papers',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...trendingPapers.map((paper) => _buildPaperCard(
                                  paper['title'],
                                  paper['authors'].join(', '),
                                  paper['published_date'],
                                  paper['categories'].join(', '),
                                  rank: '#${trendingPapers.indexOf(paper) + 1}',
                                  paperData: paper,
                                )),
                          ],
                        ),
        ),
      ],
    );
  }

  Widget _buildPaperDetail() {
    return Column(
      children: [
        // 헤더 (고정)
        Container(
          padding: const EdgeInsets.all(16),
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
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedPaper = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedPaper!['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_to_photos_outlined),
                onPressed: () => _showWorkspaceSelection(),
                color: const Color(0xFF43A047),
              ),
            ],
          ),
        ),
        // 내용 (스크롤)
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Authors: ${selectedPaper!['authors'].join(', ')}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Published: ${selectedPaper!['published_date']}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Categories: ${selectedPaper!['categories'].join(', ')}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Abstract',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatSummary(selectedPaper!['summary']),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Related Posts',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: 포스트 작성 기능 구현
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.add,
                              size: 20, color: Color(0xFF00BFA5)),
                          const SizedBox(width: 4),
                          Text(
                            'New Post',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF00BFA5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 임시 메시지 (나중에 실제 포스트로 대체)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Posts about this paper will appear here.',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32), // 하단 여백 추가
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showWorkspaceSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => WorkspaceSelectionSheet(
        onWorkspaceSelected: (workspace) async {
          try {
            await AuthAPI().addPaperToWorkspace(
              workspace['id'],
              selectedPaper!,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Paper added to ${workspace['name']}',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: const Color(0xFF43A047),
              ),
            );
            Navigator.pop(context);
          } catch (e) {
            print('Error adding paper to workspace: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to add paper to workspace',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPaperCard(
      String title, String authors, String publishedDate, String categories,
      {String? rank, Map<String, dynamic>? paperData}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedPaper = paperData;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                authors,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                publishedDate,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                categories,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
