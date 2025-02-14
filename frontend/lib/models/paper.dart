class Paper {
  final int id;
  final String title;
  final List<String> authors;
  final String abstract;
  final String publishedDate;
  final String arxivId;
  final String url;
  final List<String> categories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? userId;

  Paper({
    required this.id,
    required this.title,
    required this.authors,
    required this.abstract,
    required this.publishedDate,
    required this.arxivId,
    required this.url,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      id: json['id'],
      title: json['title'],
      authors: List<String>.from(json['authors']),
      abstract: json['abstract'],
      publishedDate: json['published_date'],
      arxivId: json['arxiv_id'],
      url: json['url'],
      categories: List<String>.from(json['categories']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'abstract': abstract,
      'published_date': publishedDate,
      'arxiv_id': arxivId,
      'url': url,
      'categories': categories,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  DateTime get publishedDateTime => DateTime.parse(publishedDate);
}

class WorkspacePaper {
  final int id;
  final int paperId;
  final DateTime addedAt;
  final String status;
  final Paper paper;

  WorkspacePaper({
    required this.id,
    required this.paperId,
    required this.addedAt,
    required this.status,
    required this.paper,
  });

  factory WorkspacePaper.fromJson(Map<String, dynamic> json) {
    try {
      return WorkspacePaper(
        id: json['id'],
        paperId: json['paper_id'],
        addedAt: DateTime.parse(json['added_at']),
        status: json['status'],
        paper: Paper.fromJson(json['paper']),
      );
    } catch (e) {
      print('Error parsing WorkspacePaper: $e');
      print('Raw JSON: $json'); // 디버그를 위한 로그 추가
      rethrow;
    }
  }
}
