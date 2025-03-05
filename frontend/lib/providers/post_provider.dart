import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/post.dart';
import '../api/post_api.dart';

class PostProvider with ChangeNotifier {
  final PostAPI _postAPI = PostAPI();
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMorePosts = true;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get hasMorePosts => _hasMorePosts;

  // 팔로우한 사용자의 포스트 가져오기
  Future<void> fetchFeedPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePosts = true;
    }

    if (_isLoading || (!_hasMorePosts && !refresh)) return;

    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      notifyListeners();

      final newPosts =
          await _postAPI.getFeedPosts(skip: (_currentPage - 1) * 20);

      if (refresh) {
        _posts = newPosts;
      } else {
        _posts = [..._posts, ...newPosts];
      }

      _currentPage++;
      _hasMorePosts = newPosts.isNotEmpty;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 포스트 좋아요 토글
  Future<void> toggleLike(int postId) async {
    try {
      final currentPost = _posts.firstWhere((post) => post.id == postId);
      final isCurrentlyLiked = currentPost.isLiked;

      // 좋아요 상태 즉시 업데이트 (낙관적 UI 업데이트)
      _updatePostLikeStatus(postId, !isCurrentlyLiked);

      // API 호출
      if (isCurrentlyLiked) {
        await _postAPI.unlikePost(postId);
      } else {
        await _postAPI.likePost(postId);
      }
    } catch (e) {
      // 에러 발생 시 원래 상태로 복원
      developer.log('Error toggling like: $e', name: 'PostProvider');
    }
  }

  void _updatePostLikeStatus(int postId, bool isLiked) {
    _posts = _posts.map((post) {
      if (post.id == postId) {
        return Post(
          id: post.id,
          authorId: post.authorId,
          authorName: post.authorName,
          authorProfileImage: post.authorProfileImage,
          title: post.title,
          content: post.content,
          paperTitle: post.paperTitle,
          keyInsights: post.keyInsights,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          paperId: post.paperId,
          likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
          saveCount: post.saveCount,
          commentCount: post.commentCount,
          isLiked: isLiked,
          isSaved: post.isSaved,
          comments: post.comments,
        );
      }
      return post;
    }).toList();

    notifyListeners();
  }

  // 포스트 저장 토글
  Future<void> toggleSave(int postId) async {
    try {
      final currentPost = _posts.firstWhere((post) => post.id == postId);
      final isCurrentlySaved = currentPost.isSaved;

      // 저장 상태 즉시 업데이트 (낙관적 UI 업데이트)
      _updatePostSaveStatus(postId, !isCurrentlySaved);

      // API 호출
      if (isCurrentlySaved) {
        await _postAPI.unsavePost(postId);
      } else {
        await _postAPI.savePost(postId);
      }
    } catch (e) {
      // 에러 발생 시 원래 상태로 복원
      developer.log('Error toggling save: $e');
    }
  }

  void _updatePostSaveStatus(int postId, bool isSaved) {
    _posts = _posts.map((post) {
      if (post.id == postId) {
        return Post(
          id: post.id,
          authorId: post.authorId,
          authorName: post.authorName,
          authorProfileImage: post.authorProfileImage,
          title: post.title,
          content: post.content,
          paperTitle: post.paperTitle,
          keyInsights: post.keyInsights,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          paperId: post.paperId,
          likeCount: post.likeCount,
          saveCount: isSaved ? post.saveCount + 1 : post.saveCount - 1,
          commentCount: post.commentCount,
          isLiked: post.isLiked,
          isSaved: isSaved,
          comments: post.comments,
        );
      }
      return post;
    }).toList();

    notifyListeners();
  }

  // 댓글 추가
  Future<void> addComment(int postId, String content) async {
    try {
      final newComment = await _postAPI.addComment(postId, content);

      _posts = _posts.map((post) {
        if (post.id == postId) {
          final updatedComments = [...post.comments, newComment];
          return Post(
            id: post.id,
            authorId: post.authorId,
            authorName: post.authorName,
            authorProfileImage: post.authorProfileImage,
            title: post.title,
            content: post.content,
            paperTitle: post.paperTitle,
            keyInsights: post.keyInsights,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            paperId: post.paperId,
            likeCount: post.likeCount,
            saveCount: post.saveCount,
            commentCount: post.commentCount + 1,
            isLiked: post.isLiked,
            isSaved: post.isSaved,
            comments: updatedComments,
          );
        }
        return post;
      }).toList();

      notifyListeners();
    } catch (e) {
      // 에러 처리
      developer.log('Error adding comment: $e');
    }
  }

  // 댓글 가져오기
  Future<void> fetchComments(int postId) async {
    try {
      final comments = await _postAPI.getComments(postId);

      _posts = _posts.map((post) {
        if (post.id == postId) {
          return Post(
            id: post.id,
            authorId: post.authorId,
            authorName: post.authorName,
            authorProfileImage: post.authorProfileImage,
            title: post.title,
            content: post.content,
            paperTitle: post.paperTitle,
            keyInsights: post.keyInsights,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            paperId: post.paperId,
            likeCount: post.likeCount,
            saveCount: post.saveCount,
            commentCount: comments.length,
            isLiked: post.isLiked,
            isSaved: post.isSaved,
            comments: comments,
          );
        }
        return post;
      }).toList();

      notifyListeners();
    } catch (e) {
      // 에러 처리
      developer.log('Error fetching comments: $e');
    }
  }

  // 사용자의 포스트 가져오기
  List<Post> _userPosts = [];
  bool _isLoadingUserPosts = false;
  bool _hasErrorUserPosts = false;

  List<Post> get userPosts => _userPosts;
  bool get isLoadingUserPosts => _isLoadingUserPosts;
  bool get hasErrorUserPosts => _hasErrorUserPosts;

  Future<void> fetchUserPosts(int userId) async {
    try {
      _isLoadingUserPosts = true;
      _hasErrorUserPosts = false;
      notifyListeners();

      final posts = await _postAPI.getUserPosts(userId);
      _userPosts = posts;
    } catch (e) {
      _hasErrorUserPosts = true;
      developer.log('Error fetching user posts: $e');
    } finally {
      _isLoadingUserPosts = false;
      notifyListeners();
    }
  }
}
