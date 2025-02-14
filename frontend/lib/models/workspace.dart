import 'user.dart';
import 'paper.dart';

class Workspace {
  final int id;
  final String name;
  final String description;
  final String researchField;
  final List<String> researchTopics;
  final int ownerId;
  final User owner;
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
    required this.owner,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.memberCount,
    required this.members,
    required this.papers,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing workspace: ${json['name']}');

      final members = (json['members'] as List?)?.map((memberJson) {
            try {
              return WorkspaceMember.fromJson(memberJson);
            } catch (e) {
              print('Error parsing member: $e');
              rethrow;
            }
          }).toList() ??
          [];

      final papers = (json['papers'] as List?)?.map((paperJson) {
            try {
              return WorkspacePaper.fromJson(paperJson);
            } catch (e) {
              print('Error parsing paper: $e');
              rethrow;
            }
          }).toList() ??
          [];

      return Workspace(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        researchField: json['research_field'],
        researchTopics: List<String>.from(json['research_topics']),
        ownerId: json['owner_id'],
        owner: User.fromJson(json['owner']),
        isPublic: json['is_public'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        memberCount: json['member_count'],
        members: members,
        papers: papers,
      );
    } catch (e, stackTrace) {
      print('Error parsing workspace: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'research_field': researchField,
      'research_topics': researchTopics,
      'owner_id': ownerId,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'member_count': memberCount,
      'members': members.map((m) => m.toJson()).toList(),
      'papers': papers.map((p) => p.toJson()).toList(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'user': user.toJson(),
    };
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
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paper_id': paperId,
      'added_at': addedAt.toIso8601String(),
      'status': status,
      'paper': paper.toJson(),
    };
  }
}
