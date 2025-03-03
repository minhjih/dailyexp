import 'package:flutter/material.dart';
import 'user.dart';

class Post {
  final int id;
  final int authorId;
  final String? authorName;
  final String? authorProfileImage;
  final String title;
  final String content;
  final String? paperTitle;
  final List<String>? keyInsights;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? paperId;
  final int likeCount;
  final int saveCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.authorId,
    this.authorName,
    this.authorProfileImage,
    required this.title,
    required this.content,
    this.paperTitle,
    this.keyInsights,
    required this.createdAt,
    this.updatedAt,
    this.paperId,
    this.likeCount = 0,
    this.saveCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.comments = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      authorProfileImage: json['author_profile_image'],
      title: json['title'],
      content: json['content'],
      paperTitle: json['paper_title'],
      keyInsights: json['key_insights'] != null
          ? List<String>.from(json['key_insights'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      paperId: json['paper_id'],
      likeCount: json['like_count'] ?? 0,
      saveCount: json['save_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      comments: json['comments'] != null
          ? List<Comment>.from(json['comments'].map((x) => Comment.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'content': content,
    };

    if (paperTitle != null) data['paper_title'] = paperTitle;
    if (keyInsights != null) data['key_insights'] = keyInsights;
    if (paperId != null) data['paper_id'] = paperId;

    return data;
  }
}

class Comment {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? parentId;
  final String? userName;
  final String? userProfileImage;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
    this.userName,
    this.userProfileImage,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      parentId: json['parent_id'],
      userName: json['user_name'],
      userProfileImage: json['user_profile_image'],
      replies: json['replies'] != null
          ? List<Comment>.from(json['replies'].map((x) => Comment.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'post_id': postId,
      'parent_id': parentId,
    };
  }
}
