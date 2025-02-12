import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaperSearchScreen extends StatelessWidget {
  final List<dynamic> searchResults;
  final String searchQuery;

  const PaperSearchScreen({
    Key? key,
    required this.searchResults,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Results: $searchQuery',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final paper = searchResults[index];
          return _buildPaperCard(
            paper['title'],
            paper['authors'].join(', '),
            paper['published_date'],
            paper['categories'].join(', '),
          );
        },
      ),
    );
  }

  Widget _buildPaperCard(
      String title, String authors, String publishedDate, String categories) {
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
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              authors,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              publishedDate,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              categories,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
