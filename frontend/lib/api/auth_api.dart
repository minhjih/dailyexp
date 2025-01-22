import 'package:dio/dio.dart';
import '../models/user.dart';

class AuthAPI {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000', // 실제 서버 URL로 변경 필요
    contentType: 'application/json',
  ));

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': email, // FastAPI는 username으로 받음
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('로그인 실패: ${e.toString()}');
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
}
