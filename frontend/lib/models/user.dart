class User {
  final int? id;
  final String email;
  final String fullName;
  final String? institution;
  final String? department;
  final String? researchField;
  final List<String> researchInterests;
  final String? bio;
  final Map<String, String>? externalLinks;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final bool isFollowing;

  User({
    this.id,
    required this.email,
    required this.fullName,
    this.institution,
    this.department,
    this.researchField,
    required this.researchInterests,
    this.bio,
    this.externalLinks,
    this.profileImageUrl,
    this.createdAt,
    this.isFollowing = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      institution: json['institution'],
      department: json['department'],
      researchField: json['research_field'],
      researchInterests: json['research_interests'] != null
          ? List<String>.from(json['research_interests'])
          : [],
      bio: json['bio'],
      externalLinks: json['external_links'] != null
          ? Map<String, String>.from(json['external_links'])
          : null,
      profileImageUrl: json['profile_image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      isFollowing: json['is_following'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'created_at': createdAt?.toIso8601String(),
      'institution': institution,
      'department': department,
      'research_field': researchField,
      'research_interests': researchInterests,
      'bio': bio,
      'external_links': externalLinks,
      'profile_image_url': profileImageUrl,
      'is_following': isFollowing,
    };
  }
}
