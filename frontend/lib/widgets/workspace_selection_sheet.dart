import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/auth_api.dart';

class WorkspaceSelectionSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onWorkspaceSelected;

  const WorkspaceSelectionSheet({
    super.key,
    required this.onWorkspaceSelected,
  });

  @override
  State<WorkspaceSelectionSheet> createState() =>
      _WorkspaceSelectionSheetState();
}

class _WorkspaceSelectionSheetState extends State<WorkspaceSelectionSheet> {
  List<Map<String, dynamic>> workspaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkspaces();
  }

  Future<void> _loadWorkspaces() async {
    try {
      final loadedWorkspaces = await AuthAPI().getMyWorkspaces();
      setState(() {
        workspaces = loadedWorkspaces.map((w) => w.toJson()).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading workspaces: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6, // 화면 높이의 60%로 제한
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add to Workspace',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (workspaces.isEmpty)
            Center(
              child: Text(
                'No workspaces found',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            )
          else
            Expanded(
              // Expanded로 감싸서 남은 공간 채우기
              child: SingleChildScrollView(
                // 스크롤 가능하게 만들기
                child: Column(
                  children: workspaces
                      .map((workspace) => ListTile(
                            title: Text(
                              workspace['name'],
                              style: GoogleFonts.poppins(),
                            ),
                            trailing:
                                const Icon(Icons.add, color: Color(0xFF43A047)),
                            onTap: () => widget.onWorkspaceSelected(workspace),
                          ))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
