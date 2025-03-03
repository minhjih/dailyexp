import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';

class PostAPI {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000',
    contentType: 'application/json',
    validateStatus: (status) => status! < 500,
  ));

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 피드 포스트 가져오기 (팔로우한 사용자의 포스트)
  Future<List<Post>> getFeedPosts({int skip = 0, int limit = 20}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.get(
        '/posts/feed',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> postsJson = response.data;
        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch posts');
      }
    } catch (e) {
      // 404 에러인 경우 빈 리스트 반환 (팔로우한 사용자가 없는 경우)
      print('Error fetching feed posts: $e');
      return [];
    }
  }

  // 특정 사용자의 포스트 가져오기
  Future<List<Post>> getUserPosts(int userId,
      {int skip = 0, int limit = 100}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.get(
        '/posts',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: {
          'user_id': userId,
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> postsJson = response.data;
        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch user posts');
      }
    } catch (e) {
      // 개발 중에는 더미 데이터 반환
      print('Error fetching user posts: $e');
      return _getDummyPosts();
    }
  }

  // 포스트 생성
  Future<Post> createPost(Post post) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.post(
        '/posts',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: post.toJson(),
      );

      if (response.statusCode == 201) {
        return Post.fromJson(response.data);
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // 포스트 좋아요
  Future<void> likePost(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.post(
        '/posts/$postId/like',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  // 포스트 좋아요 취소
  Future<void> unlikePost(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.delete(
        '/posts/$postId/like',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to unlike post');
      }
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  // 포스트 저장
  Future<void> savePost(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.post(
        '/posts/$postId/save',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to save post');
      }
    } catch (e) {
      throw Exception('Failed to save post: $e');
    }
  }

  // 포스트 저장 취소
  Future<void> unsavePost(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.delete(
        '/posts/$postId/save',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to unsave post');
      }
    } catch (e) {
      throw Exception('Failed to unsave post: $e');
    }
  }

  // 댓글 작성
  Future<Comment> addComment(int postId, String content,
      {int? parentId}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final data = {
        'content': content,
        'post_id': postId,
      };

      if (parentId != null) {
        data['parent_id'] = parentId;
      }

      final response = await _dio.post(
        '/posts/$postId/comments',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );

      if (response.statusCode == 201) {
        return Comment.fromJson(response.data);
      } else {
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // 댓글 목록 가져오기
  Future<List<Comment>> getComments(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.get(
        '/posts/$postId/comments',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> commentsJson = response.data;
        return commentsJson.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch comments');
      }
    } catch (e) {
      // 개발 중에는 빈 리스트 반환
      print('Error fetching comments: $e');
      return [];
    }
  }

  // 개발용 더미 포스트 데이터
  List<Post> _getDummyPosts() {
    return List.generate(
      10,
      (index) => Post(
        id: index + 1,
        authorId: index % 3 + 1,
        authorName: '사용자 ${index % 3 + 1}',
        authorProfileImage: 'https://i.pravatar.cc/150?img=${index % 10 + 1}',
        title: '포스트 제목 ${index + 1}',
        content:
            '이것은 포스트 내용입니다. 여기에 포스트의 자세한 내용이 들어갑니다. 이 포스트는 개발 중에 사용되는 더미 데이터입니다.',
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now().subtract(Duration(days: index)),
        paperTitle: index % 2 == 0 ? '관련 논문 제목 ${index + 1}' : null,
        keyInsights: index % 2 == 0 ? ['주요 인사이트 1', '주요 인사이트 2'] : null,
        likeCount: index * 5,
        saveCount: index * 2,
        commentCount: index * 3,
        isLiked: index % 2 == 0,
        isSaved: index % 3 == 0,
      ),
    );
  }
}
