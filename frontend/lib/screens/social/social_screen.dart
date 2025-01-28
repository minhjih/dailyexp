import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialScreen extends StatefulWidget {
  final ScrollController scrollController;

  const SocialScreen({
    super.key,
    required this.scrollController,
  });

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  bool isResearcherMode = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 탭 버튼
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isResearcherMode = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isResearcherMode ? Colors.green : Colors.grey[200],
                    foregroundColor:
                        isResearcherMode ? Colors.white : Colors.grey[600],
                    elevation: isResearcherMode ? 1 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Researchers',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isResearcherMode = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !isResearcherMode ? Colors.green : Colors.grey[200],
                    foregroundColor:
                        !isResearcherMode ? Colors.white : Colors.grey[600],
                    elevation: !isResearcherMode ? 1 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Workspaces',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 검색창
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: isResearcherMode
                  ? 'Search researchers...'
                  : 'Search workspaces...',
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
        // 콘텐츠 섹션
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  isResearcherMode
                      ? 'Recommended Researchers'
                      : 'Recommended Workspaces',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isResearcherMode) ...[
                _buildResearcherCard(
                  'Dr. Sarah Chen',
                  'AI Research Lead at Stanford',
                  '12 papers in AI & Healthcare',
                ),
                _buildResearcherCard(
                  'Prof. James Wilson',
                  'Quantum Computing - MIT',
                  '8 papers in Quantum Computing',
                ),
                _buildResearcherCard(
                  'Dr. Michael Park',
                  '5G Network Specialist - IBM',
                  '15 papers in Network Security',
                ),
              ] else ...[
                _buildWorkspaceCard(
                  'AI Research Group',
                  'Stanford University',
                  '15 members',
                ),
                _buildWorkspaceCard(
                  'Quantum Computing Lab',
                  'MIT',
                  '8 members',
                ),
                _buildWorkspaceCard(
                  'Network Security Team',
                  'IBM Research',
                  '12 members',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResearcherCard(String name, String position, String papers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  position,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  papers,
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () {},
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceCard(String name, String institution, String members) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.groups_outlined, color: Colors.green[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  institution,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  members,
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_outlined),
            onPressed: () {},
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(context, shrinkOffset, overlapsContent) => tabBar;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) => false;
}
