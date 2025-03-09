import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/workspace.dart';
import '../../api/auth_api.dart';
import '../../theme/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceDetailScreen({Key? key, required this.workspace})
      : super(key: key);

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  late Workspace _workspace;
  bool isJoining = false;

  @override
  void initState() {
    super.initState();
    _workspace = widget.workspace;
  }

  Future<void> _refreshWorkspace() async {
    try {
      final updatedWorkspace = await AuthAPI().getWorkspace(_workspace.id);
      if (mounted) {
        setState(() {
          _workspace = updatedWorkspace;
        });
      }
    } catch (e) {
      print('Error refreshing workspace: $e');
    }
  }

  Future<void> _joinWorkspace() async {
    setState(() {
      isJoining = true;
    });

    try {
      final updatedWorkspace = await AuthAPI().joinWorkspace(_workspace.id);
      if (mounted) {
        setState(() {
          _workspace = updatedWorkspace;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined workspace')),
        );
        Navigator.pop(context, true); // 목록 새로고침을 위해 true 반환
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join workspace: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _workspace.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 워크스페이스 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.group_work_outlined,
                          color: Colors.green[700], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _workspace.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${_workspace.memberCount} members · ${_workspace.papers.length} papers',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isJoining ? null : _joinWorkspace,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isJoining
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Join Workspace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 멤버 섹션
            Text(
              'Members',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _workspace.members.length,
              itemBuilder: (context, index) {
                final member = _workspace.members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: member.user.profileImageUrl != null
                        ? (() {
                            final String imageUrl =
                                member.user.profileImageUrl!;
                            // 이미지 URL이 http로 시작하지 않으면 .env 파일의 API_URL을 추가
                            final String apiUrl =
                                dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
                            final String fullUrl = imageUrl.startsWith('http')
                                ? imageUrl
                                : '$apiUrl$imageUrl';
                            return NetworkImage(fullUrl);
                          })()
                        : null,
                    child: member.user.profileImageUrl == null
                        ? Text(member.user.fullName[0])
                        : null,
                  ),
                  title: Text(member.user.fullName),
                  subtitle: Text(member.user.institution ?? ''),
                );
              },
            ),

            const SizedBox(height: 24),

            // 논문 섹션
            Text(
              'Recent Papers',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _workspace.papers.length,
              itemBuilder: (context, index) {
                final workspacePaper = _workspace.papers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(workspacePaper.paper.title),
                    subtitle: Text(workspacePaper.paper.authors.join(', ')),
                    trailing: Text(
                        DateTime.parse(workspacePaper.paper.publishedDate)
                            .year
                            .toString()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
