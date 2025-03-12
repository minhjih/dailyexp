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
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다. 다시 로그인해주세요.');
      }

      // 팔로잉 목록 가져오기
      final followingIds = await getFollowingIds();

      // 사용자 검색 - 기존 엔드포인트 사용
      final response = await _dio.get(
        '/workspaces/users/search', // 기존에 있는 엔드포인트로 변경
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        queryParameters: {'query': query},
      );

      if (response.statusCode != 200) {
        throw Exception('사용자 검색 실패: ${response.statusCode}');
      }

      // 검색 결과에 팔로잉 정보 추가
      final List<User> users = (response.data as List).map((json) {
        final user = User.fromJson(json);
        // 팔로잉 여부 설정
        final isFollowing = followingIds.contains(user.id);

        // 새 User 객체 생성하여 isFollowing 속성 설정
        return User(
          id: user.id,
          email: user.email,
          fullName: user.fullName,
          institution: user.institution,
          department: user.department,
          researchField: user.researchField,
          researchInterests: user.researchInterests,
          bio: user.bio,
          externalLinks: user.externalLinks,
          profileImageUrl: user.profileImageUrl,
          createdAt: user.createdAt,
          isFollowing: isFollowing,
        );
      }).toList();

      return users;
    } catch (e) {
      print('사용자 검색 중 오류 발생: $e');
      throw Exception('사용자 검색 중 오류 발생: $e');
    }
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

  Future<void> addPaperToWorkspace(
      int workspaceId, Map<String, dynamic> paperData) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/workspaces/$workspaceId/papers',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: paperData,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add paper to workspace');
      }
    } catch (e) {
      throw Exception('Failed to add paper to workspace: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getWorkspacePapers(int workspaceId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/workspaces/$workspaceId/papers',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      print('Error getting workspace papers: $e');
      throw Exception('Failed to load workspace papers');
    }
  }

  // 워크스페이스 생성
  Future<Map<String, dynamic>> createWorkspace(
      Map<String, dynamic> workspaceData) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('인증 토큰이 없습니다. 다시 로그인해주세요.');
      }

      final response = await _dio.post(
        '/workspaces/new', // 새로운 워크스페이스 생성 엔드포인트
        data: workspaceData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('워크스페이스 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('워크스페이스 생성 중 오류 발생: $e');
    }
  }

  // 프로필 사진 업로드
  Future<String> uploadProfileImage(dynamic imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다. 다시 로그인해주세요.');
      }

      print('API URL: ${_dio.options.baseUrl}');

      // FormData 생성
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/profile/me/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Profile image upload response: ${response.data}');
        // 백엔드에서 반환하는 상대 경로 사용
        final relativeUrl = response.data['profile_image_url'];
        print('Relative profile image URL: $relativeUrl');

        // .env 파일의 API_URL을 사용하여 전체 URL 구성
        final apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:8000';
        final fullUrl = '$apiUrl$relativeUrl';
        print('Full profile image URL: $fullUrl');

        return fullUrl;
      } else {
        throw Exception('프로필 사진 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('프로필 사진 업로드 중 오류 발생: $e');
    }
  }

  // 모든 사용자 목록 가져오기
  Future<List<User>> getAllUsers() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await _dio.get(
        '/users/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data;
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch users: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }
}
