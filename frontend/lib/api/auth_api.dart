import 'package:dio/dio.dart';
import '../models/user.dart';
import 'dart:convert'; // jsonEncode를 위해 추가

class AuthAPI {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000', // localhost 대신 10.0.2.2 사용
    contentType: 'application/json',
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
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Error response: ${e.response?.data}');
      }
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

  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post('/auth/signup', data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      });
      return response.data;
    } catch (e) {
      throw Exception('회원가입 실패: ${e.toString()}');
    }
  }
}
