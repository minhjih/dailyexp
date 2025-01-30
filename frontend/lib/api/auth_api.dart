import 'package:dio/dio.dart';
import '../models/user.dart';
import 'dart:convert'; // jsonEncode를 위해 추가
import 'package:shared_preferences/shared_preferences.dart';

class AuthAPI {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000',
    contentType: 'application/json',
    validateStatus: (status) => status! < 500, // 4xx 에러도 처리
  ));

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
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

  static Future<User> getCurrentUser(String token) async {
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

  static Future<Map<String, dynamic>> signup(
      Map<String, dynamic> signupData) async {
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
}
