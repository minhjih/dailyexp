import 'package:flutter/material.dart';

class Comment {
  final int id;
  final String content;
  final int authorId;
  final String? authorName;
  final String? authorProfileImage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.content,
    required this.authorId,
    this.authorName,
    this.authorProfileImage,
    required this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // 백엔드에서 user_id 또는 author_id로 반환할 수 있으므로 둘 다 처리
    final authorId = json['user_id'] ?? json['author_id'];

    // 디버깅을 위한 로그 추가
    print('Comment.fromJson: $json');
    print('authorId: $authorId');

    if (authorId == null) {
      throw Exception('Comment.fromJson: authorId is null. JSON: $json');
    }

    return Comment(
      id: json['id'],
      content: json['content'],
      authorId: authorId,
      authorName: json['user_name'] ?? json['author_name'],
      authorProfileImage:
          json['user_profile_image'] ?? json['author_profile_image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'author_profile_image': authorProfileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
