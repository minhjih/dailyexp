import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/auth_api.dart';
import '../screens/main/main_screen.dart';

class AuthProvider with ChangeNotifier {
  final AuthAPI _authAPI = AuthAPI();
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
      final response = await _authAPI.login(email, password);
      _token = response['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);

      _user = await _authAPI.getCurrentUser(_token!);
      notifyListeners();
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
        _user = await _authAPI.getCurrentUser(_token!);
        notifyListeners();
      } catch (e) {
        logout();
      }
    }
  }

  Future<void> signup(Map<String, dynamic> signupData) async {
    try {
      final response = await _authAPI.signup(signupData);

      if (response == null || !response.containsKey('email')) {
        throw Exception('Invalid response from server');
      }

      // 회원가입 성공 메시지만 반환
      return;
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
  }
}
