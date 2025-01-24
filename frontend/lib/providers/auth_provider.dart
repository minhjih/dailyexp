import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/auth_api.dart';
import '../screens/main/main_screen.dart';

class AuthProvider with ChangeNotifier {
  final String baseUrl = 'http://10.0.2.2:8000'; // Android 에뮬레이터용 URL로 수정
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthAPI.login(email, password);
      _token = response['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      _user = await AuthAPI.getCurrentUser(_token!);
      notifyListeners(); // 인증 상태 변경 알림
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      try {
        _user = await AuthAPI.getCurrentUser(_token!);
        notifyListeners();
      } catch (e) {
        logout();
      }
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthAPI.signup(
        email: email,
        password: password,
        fullName: fullName,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
