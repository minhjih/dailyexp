import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/auth_api.dart';

class AuthProvider with ChangeNotifier {
  final String baseUrl = 'http://localhost:8000'; // 실제 서버 URL로 변경 필요
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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        // 토큰 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        // 사용자 정보 가져오기
        _user = await AuthAPI.getCurrentUser(_token!);
      } else {
        throw Exception('로그인 실패');
      }
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
