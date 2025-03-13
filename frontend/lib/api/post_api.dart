import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../models/comment.dart';

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

        // 디버깅: 백엔드에서 받은 원본 데이터 확인
        for (var postJson in postsJson) {
          print(
              '백엔드 응답 - 포스트 ID: ${postJson['id']}, 작성자 이미지: ${postJson['author_profile_image']}');
        }

        return postsJson.map((json) => Post.fromJson(json)).toList();
      } else {
        print(
            'Error fetching feed posts: ${response.statusCode} - ${response.data}');
        // 404 에러인 경우 빈 리스트 반환 (팔로우한 사용자가 없는 경우)
        if (response.statusCode == 404) {
          return [];
        }
        throw Exception('Failed to fetch posts: ${response.statusMessage}');
      }
    } catch (e) {
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

      // 백엔드 라우터 형식에 맞게 수정
      // GET /posts/?user_id=1&skip=0&limit=100
      // user_id는 필수 파라미터입니다
      if (userId <= 0) {
        throw Exception('유효한 사용자 ID가 필요합니다');
      }

      final response = await _dio.get(
        '/posts/',
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
        print(
            'Error fetching user posts: ${response.statusCode} - ${response.data}');
        // 404 에러인 경우 빈 리스트 반환
        if (response.statusCode == 404) {
          return [];
        }
        throw Exception(
            'Failed to fetch user posts: ${response.statusMessage}');
      }
    } catch (e) {
      // 에러 발생 시 빈 리스트 반환
      print('Error fetching user posts: $e');
      return [];
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

  // 댓글 가져오기
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
      print('Error fetching comments: $e');
      return [];
    }
  }

  // 댓글 추가
  Future<Comment> addComment(int postId, String content) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      print('댓글 추가 요청: 포스트 ID=$postId, 내용=$content');

      // 백엔드 API 요구사항에 맞게 요청 본문 구성
      // PostCommentCreate 스키마는 content와 post_id 필드가 모두 필요함
      // post_id는 URL 경로의 값과 동일해야 함
      final response = await _dio.post(
        '/posts/$postId/comments',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'content': content,
          'post_id': postId, // URL 경로의 post_id와 동일한 값 사용
        },
      );

      print('댓글 추가 응답: 상태 코드=${response.statusCode}, 데이터=${response.data}');

      // 응답 데이터 구조 자세히 로깅
      print('응답 데이터 타입: ${response.data.runtimeType}');
      if (response.data is Map) {
        response.data.forEach((key, value) {
          print('  $key: $value (${value.runtimeType})');
        });
      }

      if (response.statusCode == 201) {
        try {
          final comment = Comment.fromJson(response.data);
          print('댓글 파싱 성공: id=${comment.id}, authorId=${comment.authorId}');
          return comment;
        } catch (parseError) {
          print('댓글 파싱 오류: $parseError');
          rethrow;
        }
      } else {
        print('댓글 추가 실패: ${response.statusCode} - ${response.data}');
        throw Exception('Failed to add comment: ${response.statusMessage}');
      }
    } catch (e) {
      print('댓글 추가 중 오류 발생: $e');
      throw Exception('Failed to add comment: $e');
    }
  }
}
