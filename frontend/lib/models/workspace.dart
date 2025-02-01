import 'user.dart';
import 'paper.dart';

class Workspace {
  final int id;
  final String name;
  final String description;
  final String researchField;
  final List<String> researchTopics;
  final int ownerId;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int memberCount;
  final List<WorkspaceMember> members;
  final List<WorkspacePaper> papers;

  Workspace({
    required this.id,
    required this.name,
    required this.description,
    required this.researchField,
    required this.researchTopics,
    required this.ownerId,
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
    this.memberCount = 1,
    required this.members,
    required this.papers,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      researchField: json['research_field'],
      researchTopics: List<String>.from(json['research_topics']),
      ownerId: json['owner_id'],
      isPublic: json['is_public'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      memberCount: json['member_count'] ?? 1,
      members: (json['members'] as List)
          .map((m) => WorkspaceMember.fromJson(m))
          .toList(),
      papers: (json['papers'] as List)
          .map((p) => WorkspacePaper.fromJson(p))
          .toList(),
    );
  }
}

class WorkspaceMember {
  final int id;
  final int userId;
  final String role;
  final DateTime joinedAt;
  final User user;

  WorkspaceMember({
    required this.id,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.user,
  });

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      id: json['id'],
      userId: json['user_id'],
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
      user: User.fromJson(json['user']),
    );
  }
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
    return WorkspacePaper(
      id: json['id'],
      paperId: json['paper_id'],
      addedAt: DateTime.parse(json['added_at']),
      status: json['status'],
      paper: Paper.fromJson(json['paper']),
    );
  }
}
