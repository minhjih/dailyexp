import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workspace;
  final Function onBack;

  const WorkspaceDetailScreen({
    super.key,
    required this.workspace,
    required this.onBack,
  });

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  List<Map<String, dynamic>> papers = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadWorkspacePapers();
  }

  Future<void> _loadWorkspacePapers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: API로 해당 워크스페이스의 논문 목록 가져오기
      // final papers = await AuthAPI().getWorkspacePapers(widget.workspace['id']);
      setState(() {
        papers = []; // 임시로 빈 배열
        isLoading = false;
      });
    } catch (e) {
      print('Error loading workspace papers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addPaper() {
    // TODO: PaperListScreen에서 논문 추가 기능 구현 예정
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coming soon: Add papers from Explore tab',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF43A047),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더
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
                onPressed: () => widget.onBack(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.workspace['name'] ?? 'Workspace',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${papers.length} papers',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addPaper,
                color: const Color(0xFF43A047),
              ),
            ],
          ),
        ),
        // 논문 목록
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : papers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article_outlined,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No papers yet',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _addPaper,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Paper'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF43A047),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: papers.length,
                      itemBuilder: (context, index) {
                        final paper = papers[index];
                        return _buildPaperCard(paper);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildPaperCard(Map<String, dynamic> paper) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: 논문 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paper['title'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                paper['authors'].join(', '),
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                paper['published_date'],
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
