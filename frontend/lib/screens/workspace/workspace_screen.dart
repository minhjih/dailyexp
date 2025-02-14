import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import '../../theme/colors.dart';
import './workspace_detail_screen.dart';
import '../../api/auth_api.dart';
import '../../models/workspace.dart';
import 'dart:math' show min;
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkspaceScreen extends StatefulWidget {
  final Function(ScrollDirection) onScroll;
  final MotionTabBarController? tabController;
  final Function(Map<String, dynamic>) onWorkspaceSelected;

  const WorkspaceScreen({
    super.key,
    required this.onScroll,
    this.tabController,
    required this.onWorkspaceSelected,
  });

  @override
  _WorkspaceScreenState createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  List<Workspace> workspaces = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadWorkspaces();
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

  Future<void> _loadWorkspaces() async {
    try {
      setState(() {
        isLoading = true;
      });

      final loadedWorkspaces = await AuthAPI().getMyWorkspaces();
      print('Loaded workspaces count: ${loadedWorkspaces.length}');

      setState(() {
        workspaces = loadedWorkspaces;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading workspaces: $e');
      setState(() {
        isLoading = false;
        workspaces = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadWorkspaces,
      child: Column(
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
            ),
          ),
          // Workspaces 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Workspaces',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: New workspace 생성
                  },
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF43A047),
                  ),
                  label: Text(
                    'New',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF43A047),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Workspace 목록
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : workspaces.isEmpty
                    ? const Center(child: Text('No workspaces found'))
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: workspaces.length,
                        itemBuilder: (context, index) {
                          final workspace = workspaces[index];
                          print('Building workspace card: ${workspace.name}');
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (widget.tabController != null) {
                                  widget.onWorkspaceSelected
                                      .call(workspace.toJson());
                                  widget.tabController!
                                      .animateTo(widget.tabController!.index);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            workspace.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: workspace.isPublic
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.blue.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            workspace.isPublic
                                                ? 'Public'
                                                : 'Private',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: workspace.isPublic
                                                  ? Colors.green
                                                  : Colors.blue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${workspace.memberCount} members · ${workspace.papers.length} papers',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Member avatars
                                    SizedBox(
                                      height: 24,
                                      child: Stack(
                                        children: [
                                          for (var i = 0;
                                              i <
                                                  min(3,
                                                      workspace.members.length);
                                              i++)
                                            Positioned(
                                              left: i * 16.0,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      workspace.members[i].user
                                                              .profileImageUrl ??
                                                          'https://via.placeholder.com/150',
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (workspace.members.length > 3)
                                            Positioned(
                                              left: 48,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey[200],
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '+${workspace.members.length - 3}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                      ),
          ),
        ],
      ),
    );
  }
}
