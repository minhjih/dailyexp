import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaperDetailScreen extends StatelessWidget {
  final Map<String, dynamic> paper;

  const PaperDetailScreen({
    Key? key,
    required this.paper,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paper['title'],
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Authors: ${paper['authors'].join(', ')}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Published: ${paper['published_date']}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Categories: ${paper['categories'].join(', ')}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Abstract',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              paper['summary'],
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // TODO: PDF 열기 기능 구현
              },
              child: Text(
                'View PDF',
                style: GoogleFonts.poppins(),
              ),
            ),
            // TODO: 나중에 댓글/포스트 섹션 추가
          ],
        ),
      ),
    );
  }
}
