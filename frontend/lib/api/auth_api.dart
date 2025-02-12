import 'package:dio/dio.dart';
import '../models/user.dart';
import 'dart:convert'; // jsonEncode를 위해 추가
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/workspace.dart';

class AuthAPI {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000',
    contentType: 'application/json',
    validateStatus: (status) => status! < 500,
  ));

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // URL-encoded form data 형식으로 변경
      final data = {
        'username': email, // FastAPI는 'username' 필드를 기대함
        'password': password,
        'grant_type': 'password', // OAuth2 필수 파라미터
      };

      final response = await _dio.post(
        '/auth/login',
        data: data,
        options: Options(
          contentType:
              Headers.formUrlEncodedContentType, // form-urlencoded 형식 지정
          validateStatus: (status) => status! < 500, // 4xx 에러도 처리하기 위해
        ),
      );

      if (response.statusCode == 401) {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다');
      }

      return response.data;
    } catch (e) {
      //if (e is DioException) {
      //  print('Status code: ${e.response?.statusCode}');
      //  print('Error response: ${e.response?.data}');
      //}
      throw Exception('로그인 실패: $e');
    }
  }

  Future<User> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(
        '/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('사용자 정보 조회 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> signupData) async {
    try {
      print('Sending signup data: $signupData');

      final response = await _dio.post(
        '/auth/signup',
        data: signupData,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 400) {
        final error = response.data['detail'] ?? '회원가입 실패';
        throw Exception(error);
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('회원가입 실패: 상태 코드 ${response.statusCode}');
      }

      if (response.data == null) {
        throw Exception('서버 응답이 비어있습니다');
      }

      return response.data;
    } on DioException catch (e) {
      print('DioError: ${e.message}');
      print('DioError type: ${e.type}');
      print('DioError response: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? '회원가입 실패');
      }
      throw Exception('네트워크 오류: ${e.message}');
    } catch (e) {
      print('General error: $e');
      throw Exception('회원가입 실패: $e');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.get(
        '/profile/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<Map<String, dynamic>> getProfileStats() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.get(
        '/profile/me/stats',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to fetch profile stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch profile stats: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProfileById(int userId) async {
    try {
      final response = await _dio.get(
        '/profile/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<void> followUser(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      await _dio.post(
        '/profile/$userId/follow',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  Future<List<int>> getFollowingIds() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.get(
        '/profile/me/following',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> followingList = response.data;
        return followingList.map((user) => user['id'] as int).toList();
      } else {
        throw Exception('Failed to fetch following list');
      }
    } catch (e) {
      throw Exception('Failed to fetch following list: $e');
    }
  }

  Future<List<Workspace>> getRecommendedWorkspaces({
    String? researchField,
    List<String>? interests,
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/workspaces/recommended',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        queryParameters: {
          'research_field': researchField,
          'interests': interests,
        },
      );

      return (response.data as List)
          .map((json) => Workspace.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recommended workspaces: $e');
    }
  }

  Future<Workspace> joinWorkspace(int workspaceId) async {
    final token = await _getToken();
    final response = await _dio.post(
      '/workspaces/$workspaceId/join',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to join workspace');
    }
    return Workspace.fromJson(response.data);
  }

  Future<Workspace> getWorkspace(int workspaceId) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/workspaces/$workspaceId',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return Workspace.fromJson(response.data);
  }

  Future<List<Workspace>> getMyWorkspaces() async {
    final token = await _getToken();
    final response = await _dio.get(
      '/workspaces/my',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return (response.data as List)
        .map((json) => Workspace.fromJson(json))
        .toList();
  }

  Future<List<User>> searchUsers(String query) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/workspaces/users/search',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
      queryParameters: {'query': query},
    );
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<List<Workspace>> searchWorkspaces(String query) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/workspaces/search',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
      queryParameters: {'query': query},
    );
    return (response.data as List)
        .map((json) => Workspace.fromJson(json))
        .toList();
  }

  Future<List<dynamic>> searchArxivPapers(String query) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/papers/search',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
      queryParameters: {'query': query},
    );
    return response.data;
  }
}
