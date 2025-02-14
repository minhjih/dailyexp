import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../workspace/paper_discussion_screen.dart';
import '../../models/paper.dart';
import '../../api/auth_api.dart';

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
      final loadedPapers =
          await AuthAPI().getWorkspacePapers(widget.workspace['id']);
      setState(() {
        papers = loadedPapers;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading workspace papers: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load papers: $e')),
        );
      }
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
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: papers.length,
                      itemBuilder: (context, index) {
                        final workspacePaper = papers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(workspacePaper['paper']['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(workspacePaper['paper']['authors']
                                    .join(', ')),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${workspacePaper['status']}',
                                  style: TextStyle(
                                    color: workspacePaper['status'] == 'active'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateTime.parse(workspacePaper['paper']
                                          ['published_date'])
                                      .year
                                      .toString(),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaperDiscussionScreen(
                                    workspaceId: widget.workspace['id'],
                                    paper:
                                        Paper.fromJson(workspacePaper['paper']),
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
}
