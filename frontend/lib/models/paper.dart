class Paper {
  final int id;
  final String ieeeId;
  final String title;
  final String abstract;
  final List<dynamic> authors;
  final DateTime publishedDate;
  final Map<String, dynamic>? aiSummary;
  final String? coreClaims;
  final String? methodology;
  final String? keyFindings;
  final Map<String, dynamic>? visualElements;
  final String? futureResearch;
  final int userId;

  Paper({
    required this.id,
    required this.ieeeId,
    required this.title,
    required this.abstract,
    required this.authors,
    required this.publishedDate,
    this.aiSummary,
    this.coreClaims,
    this.methodology,
    this.keyFindings,
    this.visualElements,
    this.futureResearch,
    required this.userId,
  });

  factory Paper.fromJson(Map<String, dynamic> json) {
    return Paper(
      id: json['id'],
      ieeeId: json['ieee_id'],
      title: json['title'],
      abstract: json['abstract'],
      authors: json['authors'],
      publishedDate: DateTime.parse(json['published_date']),
      aiSummary: json['ai_summary'],
      coreClaims: json['core_claims'],
      methodology: json['methodology'],
      keyFindings: json['key_findings'],
      visualElements: json['visual_elements'],
      futureResearch: json['future_research'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ieee_id': ieeeId,
      'title': title,
      'abstract': abstract,
      'authors': authors,
      'published_date': publishedDate.toIso8601String(),
      'ai_summary': aiSummary,
      'core_claims': coreClaims,
      'methodology': methodology,
      'key_findings': keyFindings,
      'visual_elements': visualElements,
      'future_research': futureResearch,
      'user_id': userId,
    };
  }
}
