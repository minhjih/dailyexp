import 'package:dio/dio.dart';
import '../models/user.dart';

class AuthAPI {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8000', // localhost 대신 10.0.2.2 사용
    contentType: 'application/json',
  ));

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final formData = FormData.fromMap({
        'grant_type': 'password', // OAuth2 요구사항
        'username': email,
        'password': password,
        'scope': '', // 선택적
        'client_id': '', // 선택적
        'client_secret': '' // 선택적
      });

      final response = await _dio.post(
        '/auth/login',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
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
