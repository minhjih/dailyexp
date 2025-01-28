import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import '../../theme/colors.dart';
import './workspace_detail_screen.dart';

class WorkspaceScreen extends StatelessWidget {
  final ScrollController scrollController;
  final MotionTabBarController? tabController;
  final Function(Map<String, dynamic>)? onWorkspaceSelected;

  const WorkspaceScreen({
    super.key,
    required this.scrollController,
    this.tabController,
    this.onWorkspaceSelected,
  });

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
          child: GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: 4, // 임시 데이터
            itemBuilder: (context, index) {
              final workspaces = [
                {
                  'name': 'Quantum Research',
                  'isPrivate': true,
                  'members': 5,
                  'papers': 12
                },
                {
                  'name': 'ML Study Group',
                  'isPrivate': false,
                  'members': 8,
                  'papers': 23
                },
                {
                  'name': 'Climate Research',
                  'isPrivate': true,
                  'members': 4,
                  'papers': 8
                },
                {
                  'name': 'AI Ethics',
                  'isPrivate': false,
                  'members': 12,
                  'papers': 31
                },
              ];

              final workspace = workspaces[index];

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    // Navigator.push 대신 TabController를 통해 화면 전환
                    if (tabController != null) {
                      // 현재 워크스페이스 정보를 저장
                      onWorkspaceSelected?.call(workspace);
                      // 워크스페이스 상세 화면으로 전환
                      tabController!.animateTo(tabController!.index);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                workspace['name'] as String,
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
                                color: (workspace['isPrivate'] as bool)
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                (workspace['isPrivate'] as bool)
                                    ? 'Private'
                                    : 'Public',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: (workspace['isPrivate'] as bool)
                                      ? Colors.blue
                                      : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${workspace['members']} members · ${workspace['papers']} papers',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 24,
                          child: Stack(
                            children: [
                              for (var i = 0; i < 3; i++)
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
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                          'https://via.placeholder.com/150',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              if ((workspace['members'] as int) > 3)
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
                                        '+${(workspace['members'] as int) - 3}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
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
    );
  }
}
