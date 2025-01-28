import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaperListScreen extends StatelessWidget {
  final ScrollController scrollController;

  const PaperListScreen({
    super.key,
    required this.scrollController,
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
              hintText: 'Search IEEE papers...',
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
        // 논문 목록
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100,
            ),
            children: [
              // Recommended for You 섹션
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
                      // TODO: 추천 논문 새로고침
                    },
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Featured Paper 추가
              Row(
                children: [
                  Text(
                    'Featured Paper',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildPaperCard(
                'Artificial Intelligence in Healthcare: Current Applications and Future Prospects',
                'IEEE Journal of Biomedical and Health Informatics',
                '1.2k',
                '342',
              ),
              const SizedBox(height: 16),
              // 두 번째 추천 논문 추가
              _buildPaperCard(
                'Machine Learning for Medical Image Analysis: A Comprehensive Review',
                'IEEE Transactions on Medical Imaging',
                '956',
                '287',
              ),
              const SizedBox(height: 32),
              // Trending Papers 섹션
              Text(
                'Trending Papers',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildPaperCard(
                'Deep Learning Approaches in Edge Computing',
                'IEEE Transactions on Neural Networks',
                '2.3k',
                '567',
                rank: '#1',
              ),
              _buildPaperCard(
                'Quantum Computing: A Survey',
                'IEEE Computer',
                '1.8k',
                '421',
                rank: '#2',
              ),
              _buildPaperCard(
                '5G Network Security Challenges',
                'IEEE Communications Surveys & Tutorials',
                '1.5k',
                '289',
                rank: '#3',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaperCard(
      String title, String journal, String views, String likes,
      {String? rank}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                if (rank != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rank,
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              journal,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.visibility_outlined,
                    color: Colors.grey[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  '$views views',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.favorite_border, color: Colors.grey[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  '$likes likes',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
